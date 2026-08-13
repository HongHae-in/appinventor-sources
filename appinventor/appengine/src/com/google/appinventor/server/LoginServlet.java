// -*- mode: java; c-basic-offset: 2; -*-
// Copyright 2009-2011 Google, All Rights reserved
// Copyright 2011-2019 MIT, All rights reserved
// Released under the MIT License https://raw.github.com/mit-cml/app-inventor/master/mitlicense.txt

package com.google.appinventor.server;


import com.google.appinventor.server.flags.Flag;

import com.google.appinventor.server.storage.StorageIo;
import com.google.appinventor.server.storage.StorageIoInstanceHolder;
import com.google.appinventor.server.storage.StoredData.ProjectNotFoundException;

import com.google.appinventor.server.tokens.Token;
import com.google.appinventor.server.tokens.TokenException;
import com.google.appinventor.server.tokens.TokenProto;

import com.google.appinventor.server.util.PasswordHash;
import com.google.appinventor.server.util.UriBuilder;

import com.google.appinventor.shared.rpc.user.User;

import java.io.IOException;
import java.io.PrintWriter;

import java.net.URLDecoder;
import java.net.URLEncoder;

import java.security.NoSuchAlgorithmException;
import java.security.spec.InvalidKeySpecException;

import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Locale;
import java.util.ResourceBundle;
import java.util.Set;

import java.util.logging.Level;
import java.util.logging.Logger;

import javax.servlet.ServletConfig;
import javax.servlet.ServletException;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.owasp.html.HtmlPolicyBuilder;
import org.owasp.html.PolicyFactory;

/**
 * LoginServlet -- Handle logging someone in using a login name and a password,
 * which is stored hashed (and salted).
 *
 * @author jis@mit.edu (Jeffrey I. Schiller)
 */
@SuppressWarnings("unchecked")
public class LoginServlet extends HttpServlet {

  private final StorageIo storageIo = StorageIoInstanceHolder.getInstance();
  private static final Logger LOG = Logger.getLogger(LoginServlet.class.getName());
  private static final Flag<Boolean> useLocal = Flag.createFlag("auth.uselocal", false);
  private static final String loginUrl = Flag.createFlag("login.url", "").get();

  private final PolicyFactory sanitizer = new HtmlPolicyBuilder().allowElements("p").toFactory();
  private static final boolean DEBUG = Flag.createFlag("appinventor.debugging", false).get();

  private static final Set<LoginListener> loginListeners = new HashSet<>();

  public interface LoginListener {
    void onLogin(User user, TokenProto.token token);
  }

  public static void addLoginListener(LoginListener listener) {
    loginListeners.add(listener);
  }

  public static void removeLoginListener(LoginListener listener) {
    loginListeners.remove(listener);
  }

  public void init(ServletConfig config) throws ServletException {
    super.init(config);
  }

  protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
    resp.setContentType("text/html; charset=utf-8");

    PrintWriter out;
    String [] components = req.getRequestURI().split("/");
    if (DEBUG) {
      LOG.info("requestURI = " + req.getRequestURI());
    }
    String page = getPage(req);

    OdeAuthFilter.UserInfo userInfo = OdeAuthFilter.getUserInfo(req);

    String queryString = req.getQueryString();
    HashMap<String, String> params = getQueryMap(queryString);
    // These params are passed around so they can take effect even if we
    // were not logged in.
    String locale = params.get("locale");
    String repo = params.get("repo");
    String galleryId = params.get("galleryId");
    String redirect = params.get("redirect");
    String autoload = params.get("autoload");
    String newGalleryId = params.get("ng");
    String uiPreference = params.get("ui");

    if (DEBUG) {
      LOG.info("locale = " + locale + " bundle: " + new Locale(locale));
    }
    ResourceBundle bundle;
    if (locale == null) {
      bundle = ResourceBundle.getBundle("com/google/appinventor/server/loginmessages", new Locale("en"));
    } else {
      bundle = ResourceBundle.getBundle("com/google/appinventor/server/loginmessages", new Locale(locale));
    }

    if (page.equals("google")) {
      // Google Login is disabled. Redirect back to login page.
      resp.sendRedirect("/login/?locale=" + sanitizer.sanitize(locale));
      return;
    } else {
      if (!loginUrl.isEmpty() && !page.equals("token")) {
        /* If we have an external login URL specified, then redirect to it. */
        String uri = new UriBuilder(loginUrl)
          .add("locale", locale)
          .add("repo", repo)
          .add("ng", newGalleryId)
          .add("galleryId", galleryId)
          .add("autoload", autoload)
          .add("ui", uiPreference)
          .add("redirect", redirect).build();
        resp.sendRedirect(uri);
        return;
      }
      if (useLocal.get() == false) {
        out = setCookieOutput(userInfo, resp);
        out.println("<html><head><title>Error</title></head>\n");
        out.println("<body><h1>App Inventor is Mis-Configured</h1>\n");
        out.println("<p>This instance of App Inventor has no authentication mechanism configured.</p>\n");
        out.println("</body>\n");
        out.println("</html>\n");
        return;
      }
    }

    // If we get here, local accounts are supported
    // or we are the "token" page

    if (page.equals("token") || page.equals("stoken")) {
      String encodedToken = params.get("token");
      if (encodedToken == null) {
        fail(req, resp, bundle.getString("noAuthToken"), locale);
        return;
      }
      TokenProto.token token = null;
      try {
        if (page.equals("token")) {
          token = Token.verifyToken(encodedToken);
        } else {
          token = Token.verifySToken(encodedToken);
        }
      } catch (TokenException e) {
        fail(req, resp, e.getMessage(), locale);
        return;
      }
      // At this point we have a valid token, so use it to login!
      // need to make sure it is a SSOLOGIN token
      if (token.getCommand() != TokenProto.token.CommandType.SSOLOGIN &&
          token.getCommand() != TokenProto.token.CommandType.SSOLOGIN2 &&
          token.getCommand() != TokenProto.token.CommandType.SSOLOGIN3) {
        fail(req, resp, "Token Valid, but not a SSOLOGIN token.", locale);
        return;
      }
      long offset = System.currentTimeMillis() - token.getTs();
      offset /= 1000;  // Convert to seconds
      if (offset > 120) {       // Two minutes
        fail(req, resp, "Token Expired. Was valid until " +
          new Date(token.getTs()), locale);
        return;
      }
      // At this point we have a valid SSOLOGIN token

      userInfo = new OdeAuthFilter.UserInfo();
      if (token.getCommand() == TokenProto.token.CommandType.SSOLOGIN) {
        userInfo.setUserId(token.getUuid());
      } else if (token.getCommand() == TokenProto.token.CommandType.SSOLOGIN2) { // SSOLOGIN2
        String email = token.getName();
        if (email == null || email.isEmpty()) {
          fail(req, resp, "Failed to provide an Email Address for login.", locale);
          return;
        }
        User user = storageIo.getUserFromEmail(email);
        userInfo.setUserId(user.getUserId());
      } else {                  // SSOLOGIN3
        String uuid = token.getUuid();
        String email = token.getName();
        if (email == null || email.isEmpty() || uuid == null || uuid.isEmpty()) {
          fail(req, resp, "Failed to provide email and uuid, shouldn't happen!", locale);
          return;
        }
        User user = storageIo.getUser(uuid, email);
        userInfo.setUserId(user.getUserId());
        for (LoginListener listener : loginListeners) {
          listener.onLogin(user, token);
        }
      }

      userInfo.setReadOnly(token.getReadOnly());

      // Check to see if this is a one project token
      long oneProjectId = token.getOneProjectId();
      LOG.log(Level.INFO, "oneProjectId = " + oneProjectId);
      if (oneProjectId != 0) {  // It is...
        try {
          userInfo.setUserId(storageIo.getProjectUserId(oneProjectId));
          userInfo.setOneProjectId(oneProjectId);
        } catch (ProjectNotFoundException e) {
          fail(req, resp, e.getMessage(), locale);
        }
      }

      userInfo.setFauxProjectName(token.getDisplayprojectname());

      String fauxUserName = token.getDisplayaccountname();

      userInfo.setFauxAccountName(fauxUserName);

      String newCookie = userInfo.buildCookie(false);
      if (newCookie != null) {
        Cookie cook = new Cookie("AppInventor", newCookie);
        cook.setPath("/");
        resp.addCookie(cook);
      }

      String uri = new UriBuilder("/")
        .add("locale", locale)
        .add("repo", repo)
        .add("ng", newGalleryId)
        .add("galleryId", galleryId)
        .add("autoload", autoload)
        .add("ui", uiPreference)
        .add("redirect", redirect).build();
      resp.sendRedirect(uri);   // This should bring up App Inventor
      return;
    }

    String emailAddress = bundle.getString("emailaddress");
    String passwordLabel = bundle.getString("password");
    String loginLabel = bundle.getString("login");

    req.setCharacterEncoding("UTF-8");
    req.setAttribute("useGoogleLabel", "false");
    req.setAttribute("emailAddressLabel", emailAddress);
    req.setAttribute("passwordLabel", passwordLabel);
    req.setAttribute("loginLabel", loginLabel);
    req.setAttribute("emailEmptyError", bundle.getString("emailEmptyError"));
    req.setAttribute("passwordEmptyError", bundle.getString("passwordEmptyError"));
    req.setAttribute("localeLabel", locale);
    req.setAttribute("pleaselogin", bundle.getString("pleaselogin"));
    req.setAttribute("login", bundle.getString("login"));
    req.setAttribute("autoload", autoload);
    req.setAttribute("repo", repo);
    req.setAttribute("locale", locale);
    req.setAttribute("ng", newGalleryId);
    req.setAttribute("ui", uiPreference);
    req.setAttribute("galleryId", galleryId);
    try {
      req.getRequestDispatcher("/login.jsp").forward(req, resp);
    } catch (ServletException e) {
      throw new IOException(e);
    }
  }

  protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
    req.setCharacterEncoding("UTF-8");
    
    OdeAuthFilter.UserInfo userInfo = OdeAuthFilter.getUserInfo(req);
    if (userInfo == null) {
      userInfo = new OdeAuthFilter.UserInfo();
    }

    String page = getPage(req);
    String locale = req.getParameter("locale");
    String repo = req.getParameter("repo");
    String galleryId = req.getParameter("galleryId");
    String newGalleryId = req.getParameter("ng");
    String redirect = req.getParameter("redirect");
    String autoload = req.getParameter("autoload");
    String uiPreference = req.getParameter("ui");

    if (locale == null || locale.isEmpty()) {
      locale = "en";
    }

    ResourceBundle bundle = ResourceBundle.getBundle("com/google/appinventor/server/loginmessages", new Locale(locale));

    if (DEBUG) {
      LOG.info("doPost: page = " + page + ", locale = " + locale);
    }
    
    String email = req.getParameter("email");
    String password = req.getParameter("password");
    User user = storageIo.getUserFromEmail(email);
    boolean validLogin = false;

    String hash = user.getPassword();
    if ((hash == null) || hash.equals("")) {
      // User is new or hasn't set password, so we "register" them now
      String hashedPassword;
      try {
        hashedPassword = PasswordHash.createHash(password);
        storageIo.setUserPassword(user.getUserId(), hashedPassword);
        validLogin = true;
      } catch (NoSuchAlgorithmException e) {
        fail(req, resp, bundle.getString("systemErrorHashing"), locale);
        return;
      } catch (InvalidKeySpecException e) {
        fail(req, resp, bundle.getString("systemErrorHashing"), locale);
        return;
      }
    } else {
      try {
        validLogin = PasswordHash.validatePassword(password, hash);
      } catch (NoSuchAlgorithmException e) {
      } catch (InvalidKeySpecException e) {
      }
    }

    if (!validLogin) {
      fail(req, resp, bundle.getString("invalidpassword"), locale);
      return;
    }

    if (DEBUG) {
      LOG.info("userInfo = " + userInfo + " user = " + user);
    }
    userInfo.setUserId(user.getUserId());
    userInfo.setIsAdmin(user.getIsAdmin());
    String newCookie = userInfo.buildCookie(false);
    if (DEBUG) {
      LOG.info("newCookie = " + newCookie);
    }
    if (newCookie != null) {
      Cookie cook = new Cookie("AppInventor", newCookie);
      cook.setPath("/");
      resp.addCookie(cook);
    }

    String uri = "/";
    if (redirect != null && !redirect.equals("")) {
      uri = redirect;
    }
    uri = new UriBuilder(uri)
      .add("locale", locale)
      .add("autoload", autoload)
      .add("repo", repo)
      .add("ng", newGalleryId)
      .add("ui", uiPreference)
      .add("galleryId", galleryId).build();
    resp.sendRedirect(uri);
  }

  public void destroy() {
    super.destroy();
  }

  private static HashMap<String, String> getQueryMap(String query)  {
    HashMap<String, String> map = new HashMap<String, String>();
    if (query == null || query.equals("")) {
      return map;               // Empty map
    }
    String[] params = query.split("&");
    for (String param : params)  {
      String [] nvpair = param.split("=");
      if (nvpair.length <= 1) {
        map.put(nvpair[0], "");
      } else
        map.put(nvpair[0], URLDecoder.decode(nvpair[1]));
    }
    return map;
  }

  // Note: Urls in this servlet are of the form /login/<param>/<page>
  // The page identifier is *after* the parameter, if there is one.

  private String getPage(HttpServletRequest req) {
    String [] components = req.getRequestURI().split("/");
    return components[components.length-1];
  }

  private void fail(HttpServletRequest req, HttpServletResponse resp, String error, String locale) throws IOException {
    String sanitizedLocale = sanitizer.sanitize(locale);
    String sanitizedError = sanitizer.sanitize(error);
    resp.sendRedirect("/login/?locale=" + URLEncoder.encode(sanitizedLocale, "UTF-8") +
        "&error=" + URLEncoder.encode(sanitizedError, "UTF-8"));
  }

  private void renewCookie(OdeAuthFilter.UserInfo userInfo, HttpServletResponse resp) {
    if (userInfo != null) {     // if we never had logged in, this will be null!
      String newCookie = userInfo.buildCookie(true);
      if (newCookie != null) {
        Cookie cook = new Cookie("AppInventor", newCookie);
        cook.setPath("/");
        resp.addCookie(cook);
      }
    }
  }

  private PrintWriter setCookieOutput(OdeAuthFilter.UserInfo userInfo, HttpServletResponse resp)
    throws IOException {
    renewCookie(userInfo, resp);
    resp.setContentType("text/html; charset=utf-8");
    PrintWriter out = resp.getWriter();
    return out;
  }

}
