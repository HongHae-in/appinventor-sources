<%@page import="javax.servlet.http.HttpServletRequest"%>
<%@page import="com.google.appinventor.server.util.UriBuilder"%>
<%@page import="org.apache.commons.lang3.StringEscapeUtils"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!doctype html>
<%
   String error = StringEscapeUtils.escapeHtml4(request.getParameter("error"));
   String locale = StringEscapeUtils.escapeHtml4(request.getParameter("locale"));
   String redirect = StringEscapeUtils.escapeHtml4(request.getParameter("redirect"));
   String repo = StringEscapeUtils.escapeHtml4((String) request.getAttribute("repo"));
   String autoload = StringEscapeUtils.escapeHtml4((String) request.getAttribute("autoload"));
   String galleryId = StringEscapeUtils.escapeHtml4((String) request.getAttribute("galleryId"));
   String newGalleryId = StringEscapeUtils.escapeHtml4(request.getParameter("ng"));
   String uiPreference = StringEscapeUtils.escapeHtml4(request.getParameter("ui"));
   if (locale == null) {
       locale = "en";
   }
%>
<html lang="<%= locale %>">
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <meta HTTP-EQUIV="pragma" CONTENT="no-cache"/>
    <meta HTTP-EQUIV="Cache-Control" CONTENT="no-cache, must-revalidate"/>
    <meta HTTP-EQUIV="expires" CONTENT="0"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>MIT App Inventor</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Google+Sans:wght@400;500;700&family=Noto+Sans+SC:wght@400;500;700&display=swap" rel="stylesheet">
    <link href="https://fonts.googleapis.com/icon?family=Material+Symbols+Outlined" rel="stylesheet">
    <style>
      :root {
        --md-sys-color-primary: #6750A4;
        --md-sys-color-on-primary: #FFFFFF;
        --md-sys-color-surface: #FEF7FF;
        --md-sys-color-on-surface: #1D1B20;
        --md-sys-color-on-surface-variant: #49454F;
        --md-sys-color-outline: #79747E;
        --md-sys-color-outline-variant: #CAC4D0;
        --md-sys-color-error: #B3261E;
        --md-sys-color-error-container: #F9DEDC;
        --md-sys-color-on-error-container: #410E0B;
        --md-sys-color-surface-container-lowest: #FFFFFF;
        --md-sys-shape-corner-extra-large: 28px;
        --md-sys-shape-corner-medium: 12px;
        --md-sys-shape-corner-small: 8px;
      }

      * { margin: 0; padding: 0; box-sizing: border-box; }

      body {
        font-family: 'Google Sans', 'Noto Sans SC', sans-serif;
        background: var(--md-sys-color-surface);
        color: var(--md-sys-color-on-surface);
        min-height: 100vh;
        display: flex;
        flex-direction: column;
      }

      .page-container {
        flex: 1;
        display: flex;
        align-items: flex-start;
        justify-content: center;
        padding: 48px 24px 32px;
      }

      .login-surface {
        width: 100%;
        max-width: 480px;
        background: var(--md-sys-color-surface-container-lowest);
        border-radius: var(--md-sys-shape-corner-extra-large);
        padding: 40px 48px 36px;
        border: 1px solid var(--md-sys-color-outline-variant);
      }

      .header { text-align: center; margin-bottom: 32px; }
      .header h1 { font-size: 28px; font-weight: 400; line-height: 1.3; }

      .error-banner {
        background: var(--md-sys-color-error-container);
        color: var(--md-sys-color-on-error-container);
        border-radius: var(--md-sys-shape-corner-medium);
        padding: 14px 18px;
        margin-bottom: 24px;
        font-size: 14px;
        font-weight: 500;
        display: flex;
        align-items: center;
        gap: 10px;
      }
      .error-banner::before {
        content: 'error';
        font-family: 'Material Symbols Outlined';
        font-size: 20px;
      }

      .md3-field { position: relative; margin-bottom: 4px; margin-top: 16px; }
      .md3-field input {
        width: 100%; height: 56px; padding: 24px 16px 8px;
        border: 1px solid var(--md-sys-color-outline);
        border-radius: var(--md-sys-shape-corner-small);
        background: transparent; font-size: 16px; outline: none;
        transition: border 0.2s;
      }
      .md3-field input:focus { border-width: 2px; border-color: var(--md-sys-color-primary); padding: 23px 15px 7px; }
      .md3-field.error input { border-color: var(--md-sys-color-error); }
      .md3-field.error input:focus { border-color: var(--md-sys-color-error); }

      .md3-field label {
        position: absolute; left: 16px; top: 50%; transform: translateY(-50%);
        font-size: 16px; color: var(--md-sys-color-on-surface-variant);
        pointer-events: none; transition: all 0.2s ease;
        background: var(--md-sys-color-surface-container-lowest); padding: 0 4px;
      }
      .md3-field input:focus + label, .md3-field input:not(:placeholder-shown) + label {
        top: 0; font-size: 12px; color: var(--md-sys-color-primary);
      }
      .md3-field.error label { color: var(--md-sys-color-error); }

      .error-text {
        color: var(--md-sys-color-error);
        font-size: 12px;
        margin-bottom: 8px;
        margin-left: 16px;
        min-height: 18px;
        display: none;
      }
      .error-text.visible { display: block; }

      .btn-primary {
        width: 100%; height: 48px; border: none; border-radius: 24px;
        background: var(--md-sys-color-primary); color: var(--md-sys-color-on-primary);
        font-size: 14px; font-weight: 500; cursor: pointer; transition: box-shadow 0.2s;
        margin-top: 16px;
      }
      .btn-primary:hover { box-shadow: 0 1px 3px rgba(0,0,0,0.3), 0 4px 8px rgba(0,0,0,0.2); }

      .text-action {
        display: inline-flex; align-items: center; justify-content: center;
        height: 40px; padding: 0 16px; border-radius: 20px;
        color: var(--md-sys-color-primary); font-size: 14px; font-weight: 500;
        text-decoration: none; transition: background 0.2s, box-shadow 0.2s;
        margin-top: 12px;
      }
      .text-action:hover {
        background: rgba(103, 80, 164, 0.08);
        box-shadow: 0 1px 3px rgba(0,0,0,0.1), 0 2px 4px rgba(0,0,0,0.1);
      }

      .lang-chips { display: flex; justify-content: center; gap: 8px; margin-top: 24px; }
      .lang-chip {
        display: inline-flex; align-items: center; height: 32px; padding: 0 16px;
        border-radius: 8px; border: 1px solid var(--md-sys-color-outline);
        color: var(--md-sys-color-on-surface-variant); font-size: 14px; font-weight: 500;
        text-decoration: none; transition: background 0.2s;
      }
      .lang-chip:hover { background: rgba(29, 27, 32, 0.08); }
    </style>
  </head>
<body>
  <div class="page-container">
    <div class="login-surface">
      <div class="header">
        <h1>${pleaselogin}</h1>
      </div>

<% if (error != null) { %>
      <div class="error-banner"><%= error %></div>
<% } %>

      <form id="loginForm" method=POST action="/login" novalidate>
        <div class="md3-field" id="emailField">
          <input type=text name=email id="emailInput" value="" placeholder=" " autocomplete="email">
          <label>${emailAddressLabel}</label>
        </div>
        <div id="emailError" class="error-text"></div>

        <div class="md3-field" id="passwordField">
          <input type=password name=password id="passwordInput" value="" placeholder=" " autocomplete="current-password">
          <label>${passwordLabel}</label>
        </div>
        <div id="passwordError" class="error-text"></div>

<% if (locale != null && !locale.equals("")) { %>
        <input type=hidden name=locale value="<%= locale %>">
<% }
   if (repo != null && !repo.equals("")) { %>
        <input type=hidden name=repo value="<%= repo %>">
<% }
   if (autoload != null && !autoload.equals("")) { %>
        <input type=hidden name=autoload value="<%= autoload %>">
<% }
   if (galleryId != null && !galleryId.equals("")) { %>
        <input type=hidden name=galleryId value="<%= galleryId %>">
<% }
   if (newGalleryId != null && !newGalleryId.equals("")) { %>
        <input type=hidden name=ng value="<%= newGalleryId %>">
<% }
   if (uiPreference != null && !uiPreference.equals("")) { %>
        <input type=hidden name=ui value="<%= uiPreference %>">
<% }
   if (redirect != null && !redirect.equals("")) { %>
        <input type=hidden name=redirect value="<%= redirect %>">
<% } %>

        <button type=submit class="btn-primary">${login}</button>
        <div style="text-align:center;">
          <a href="/login/sendlink?locale=<%= locale %>" class="text-action">${passwordclickhereLabel}</a>
        </div>
      </form>

      <div class="lang-chips">
        <a class="lang-chip" href="<%= new UriBuilder("/login")
                             .add("locale", "zh_CN")
                             .add("repo", repo)
                             .add("autoload", autoload)
                             .add("galleryId", galleryId)
                             .add("ui", uiPreference)
                             .add("redirect", redirect).build() %>">&#20013;&#25991;</a>
        <a class="lang-chip" href="<%= new UriBuilder("/login")
                             .add("locale", "en")
                             .add("repo", repo)
                             .add("autoload", autoload)
                             .add("galleryId", galleryId)
                             .add("ng", newGalleryId)
                             .add("ui", uiPreference)
                             .add("redirect", redirect).build() %>">English</a>
      </div>

      <div style="text-align:center;margin-top:20px;">
        <a href="https://github.com/HongHae-in/appinventor-sources" target="_blank" style="font-size:12px;color:var(--md-sys-color-on-surface-variant);text-decoration:none;">GitHub</a>
      </div>
    </div>
  </div>

  <script>
    const form = document.getElementById('loginForm');
    const emailInput = document.getElementById('emailInput');
    const emailField = document.getElementById('emailField');
    const emailError = document.getElementById('emailError');
    const passwordInput = document.getElementById('passwordInput');
    const passwordField = document.getElementById('passwordField');
    const passwordError = document.getElementById('passwordError');

    const validateEmail = (email) => {
      return String(email).toLowerCase().match(/^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/);
    };

    form.addEventListener('submit', (e) => {
      let hasError = false;

      const emailValue = emailInput.value.trim();
      if (emailValue === '') {
        emailError.textContent = '${StringEscapeUtils.escapeEcmaScript(emailEmptyError)}';
        emailField.classList.add('error');
        emailError.classList.add('visible');
        hasError = true;
      } else if (!validateEmail(emailValue)) {
        emailError.textContent = '${StringEscapeUtils.escapeEcmaScript(emailFormatError)}';
        emailField.classList.add('error');
        emailError.classList.add('visible');
        hasError = true;
      }

      if (passwordInput.value.trim() === '') {
        passwordError.textContent = '${StringEscapeUtils.escapeEcmaScript(passwordEmptyError)}';
        passwordField.classList.add('error');
        passwordError.classList.add('visible');
        hasError = true;
      }

      if (hasError) e.preventDefault();
    });

    [emailInput, passwordInput].forEach(input => {
      input.addEventListener('input', () => {
        const field = input.closest('.md3-field');
        const error = field.nextElementSibling;
        field.classList.remove('error');
        if (error && error.classList.contains('error-text')) error.classList.remove('visible');
      });
    });
  </script>
</body></html>
