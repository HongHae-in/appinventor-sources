<%@page import="org.apache.commons.lang3.StringEscapeUtils"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!doctype html>
<%
   String locale = StringEscapeUtils.escapeHtml4((String) request.getAttribute("locale"));
   if (locale == null) {
       locale = "en";
   }
%>
<html lang="<%= locale %>">
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>MIT App Inventor - ${linksent}</title>
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
        --md-sys-color-surface-container-lowest: #FFFFFF;
        --md-sys-shape-corner-extra-large: 28px;
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
      .header { text-align: center; margin-bottom: 24px; }
      .header h1 { font-size: 28px; font-weight: 400; line-height: 1.3; }
      .icon-container {
        text-align: center;
        margin-bottom: 24px;
        color: var(--md-sys-color-primary);
      }
      .icon-container .material-symbols-outlined {
        font-size: 48px;
      }
      .message {
        font-size: 14px;
        color: var(--md-sys-color-on-surface-variant);
        line-height: 1.6;
        text-align: center;
        margin-bottom: 32px;
      }
      .btn-primary {
        width: 100%; height: 48px; border: none; border-radius: 24px;
        background: var(--md-sys-color-primary); color: var(--md-sys-color-on-primary);
        font-size: 14px; font-weight: 500; cursor: pointer; transition: box-shadow 0.2s;
        display: flex; align-items: center; justify-content: center; text-decoration: none;
      }
      .btn-primary:hover { box-shadow: 0 1px 3px rgba(0,0,0,0.3), 0 4px 8px rgba(0,0,0,0.2); }
    </style>
  </head>
<body>
  <div class="page-container">
    <div class="login-surface">
      <div class="icon-container">
        <span class="material-symbols-outlined">mark_email_read</span>
      </div>
      <div class="header">
        <h1>${linksent}</h1>
      </div>
      <div class="message">
        ${checkemail}
      </div>
      <a href="/login?locale=<%= locale %>" class="btn-primary">${backToLogin}</a>
    </div>
  </div>
</body></html>
