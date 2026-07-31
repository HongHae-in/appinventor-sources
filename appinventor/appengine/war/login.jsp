<%@page import="javax.servlet.http.HttpServletRequest"%>
<%@page import="com.google.appinventor.server.util.UriBuilder"%>
<%@page import="org.apache.commons.lang3.StringEscapeUtils"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!doctype html>
<%
   String error = StringEscapeUtils.escapeHtml4(request.getParameter("error"));
   String useGoogleLabel = (String) request.getAttribute("useGoogleLabel");
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
        --md-sys-color-primary-container: #EADDFF;
        --md-sys-color-on-primary-container: #21005D;
        --md-sys-color-secondary: #625B71;
        --md-sys-color-on-secondary: #FFFFFF;
        --md-sys-color-secondary-container: #E8DEF8;
        --md-sys-color-on-secondary-container: #1D192B;
        --md-sys-color-surface: #FEF7FF;
        --md-sys-color-on-surface: #1D1B20;
        --md-sys-color-surface-variant: #E7E0EC;
        --md-sys-color-on-surface-variant: #49454F;
        --md-sys-color-outline: #79747E;
        --md-sys-color-outline-variant: #CAC4D0;
        --md-sys-color-error: #B3261E;
        --md-sys-color-on-error: #FFFFFF;
        --md-sys-color-error-container: #F9DEDC;
        --md-sys-color-on-error-container: #410E0B;
        --md-sys-color-surface-container-lowest: #FFFFFF;
        --md-sys-color-surface-container-low: #F7F2FA;
        --md-sys-color-surface-container: #F3EDF7;
        --md-sys-color-inverse-surface: #322F35;
        --md-sys-color-inverse-on-surface: #F5EFF7;
        --md-sys-shape-corner-extra-large: 28px;
        --md-sys-shape-corner-large: 16px;
        --md-sys-shape-corner-medium: 12px;
        --md-sys-shape-corner-small: 8px;
      }

      * { margin: 0; padding: 0; box-sizing: border-box; }

      body {
        font-family: 'Google Sans', 'Noto Sans SC', 'Segoe UI', system-ui, sans-serif;
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

      .header {
        text-align: center;
        margin-bottom: 32px;
      }

      .header h1 {
        font-size: 28px;
        font-weight: 400;
        color: var(--md-sys-color-on-surface);
        line-height: 1.3;
        letter-spacing: 0;
      }

      .header .subtitle {
        font-size: 14px;
        color: var(--md-sys-color-on-surface-variant);
        margin-top: 8px;
        line-height: 1.5;
      }

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

      .form-section {
        margin-bottom: 8px;
      }

      .md3-field {
        position: relative;
        margin-bottom: 20px;
      }

      .md3-field input {
        width: 100%;
        height: 56px;
        padding: 24px 16px 8px;
        border: 1px solid var(--md-sys-color-outline);
        border-radius: var(--md-sys-shape-corner-small);
        background: transparent;
        font-size: 16px;
        font-family: inherit;
        color: var(--md-sys-color-on-surface);
        outline: none;
        transition: border-color 0.2s;
      }

      .md3-field input:hover {
        border-color: var(--md-sys-color-on-surface);
      }

      .md3-field input:focus {
        border-width: 2px;
        border-color: var(--md-sys-color-primary);
        padding: 23px 15px 7px;
      }

      .md3-field label {
        position: absolute;
        left: 16px;
        top: 50%;
        transform: translateY(-50%);
        font-size: 16px;
        color: var(--md-sys-color-on-surface-variant);
        pointer-events: none;
        transition: all 0.2s ease;
        background: var(--md-sys-color-surface-container-lowest);
        padding: 0 4px;
      }

      .md3-field input:focus + label,
      .md3-field input:not(:placeholder-shown) + label {
        top: 0;
        font-size: 12px;
        color: var(--md-sys-color-primary);
      }

      .btn-primary {
        width: 100%;
        height: 48px;
        border: none;
        border-radius: 20px;
        background: var(--md-sys-color-primary);
        color: var(--md-sys-color-on-primary);
        font-size: 14px;
        font-weight: 500;
        font-family: inherit;
        letter-spacing: 0.1px;
        cursor: pointer;
        position: relative;
        overflow: hidden;
        transition: box-shadow 0.2s;
        margin-top: 8px;
      }

      .btn-primary::before {
        content: '';
        position: absolute;
        inset: 0;
        background: var(--md-sys-color-on-primary);
        opacity: 0;
        transition: opacity 0.2s;
      }

      .btn-primary:hover::before { opacity: 0.08; }
      .btn-primary:hover { box-shadow: 0 1px 3px rgba(0,0,0,0.3), 0 1px 2px rgba(0,0,0,0.24); }
      .btn-primary:active::before { opacity: 0.12; }

      .text-action {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        height: 40px;
        padding: 0 12px;
        border-radius: 20px;
        border: none;
        background: transparent;
        color: var(--md-sys-color-primary);
        font-size: 14px;
        font-weight: 500;
        font-family: inherit;
        letter-spacing: 0.1px;
        text-decoration: none;
        cursor: pointer;
        position: relative;
        overflow: hidden;
        transition: background 0.2s;
      }

      .text-action::before {
        content: '';
        position: absolute;
        inset: 0;
        background: var(--md-sys-color-primary);
        opacity: 0;
        transition: opacity 0.2s;
      }

      .text-action:hover::before { opacity: 0.08; }
      .text-action:active::before { opacity: 0.12; }

      .divider-section {
        display: flex;
        align-items: center;
        margin: 16px 0;
        gap: 16px;
      }

      .divider-section::before,
      .divider-section::after {
        content: '';
        flex: 1;
        height: 1px;
        background: var(--md-sys-color-outline-variant);
      }

      .divider-section span {
        font-size: 12px;
        font-weight: 500;
        color: var(--md-sys-color-on-surface-variant);
        letter-spacing: 0.5px;
      }

      .btn-outlined {
        width: 100%;
        height: 48px;
        border: 1px solid var(--md-sys-color-outline);
        border-radius: 20px;
        background: transparent;
        color: var(--md-sys-color-primary);
        font-size: 14px;
        font-weight: 500;
        font-family: inherit;
        letter-spacing: 0.1px;
        cursor: pointer;
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 10px;
        position: relative;
        overflow: hidden;
        transition: border-color 0.2s, background 0.2s;
        text-decoration: none;
      }

      .btn-outlined::before {
        content: '';
        position: absolute;
        inset: 0;
        background: var(--md-sys-color-primary);
        opacity: 0;
        transition: opacity 0.2s;
      }

      .btn-outlined:hover {
        border-color: var(--md-sys-color-on-surface);
        background: rgba(103, 80, 164, 0.04);
      }

      .btn-outlined:hover::before { opacity: 0.08; }

      .lang-chips {
        display: flex;
        justify-content: center;
        gap: 8px;
        margin-top: 24px;
      }

      .lang-chip {
        display: inline-flex;
        align-items: center;
        height: 32px;
        padding: 0 16px;
        border-radius: 8px;
        border: 1px solid var(--md-sys-color-outline);
        background: transparent;
        color: var(--md-sys-color-on-surface-variant);
        font-size: 14px;
        font-weight: 500;
        font-family: inherit;
        text-decoration: none;
        cursor: pointer;
        position: relative;
        overflow: hidden;
        transition: background 0.2s, border-color 0.2s, color 0.2s;
      }

      .lang-chip::before {
        content: '';
        position: absolute;
        inset: 0;
        background: var(--md-sys-color-on-surface);
        opacity: 0;
        transition: opacity 0.2s;
      }

      .lang-chip:hover::before { opacity: 0.08; }
      .lang-chip:active::before { opacity: 0.12; }

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

      <form method=POST action="/login">
        <div class="form-section">
          <div class="md3-field">
            <input type=text name=email value="" size="35" placeholder=" " autocomplete="email">
            <label>${emailAddressLabel}</label>
          </div>
          <div class="md3-field">
            <input type=password name=password value="" size="35" placeholder=" " autocomplete="current-password">
            <label>${passwordLabel}</label>
          </div>
        </div>

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
        <div style="text-align:center;margin-top:12px;">
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
</body></html>
