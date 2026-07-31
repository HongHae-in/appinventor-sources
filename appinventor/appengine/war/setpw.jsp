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
    <title>MIT App Inventor - ${setyourpassword}</title>
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
      .header { text-align: center; margin-bottom: 32px; }
      .header h1 { font-size: 28px; font-weight: 400; line-height: 1.3; }

      .md3-field { position: relative; margin-bottom: 4px; margin-top: 8px; }
      .md3-field input {
        width: 100%; height: 56px; padding: 24px 16px 8px;
        border: 1px solid var(--md-sys-color-outline);
        border-radius: var(--md-sys-shape-corner-small);
        background: transparent; font-size: 16px; outline: none;
        transition: border 0.2s;
      }
      .md3-field input:focus { border-width: 2px; border-color: var(--md-sys-color-primary); padding: 23px 15px 7px; }
      .md3-field.error input { border-color: var(--md-sys-color-error); }

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
        margin-bottom: 20px;
        margin-left: 16px;
        min-height: 18px;
        display: none;
      }
      .error-text.visible { display: block; }

      .btn-primary {
        width: 100%; height: 48px; border: none; border-radius: 24px;
        background: var(--md-sys-color-primary); color: var(--md-sys-color-on-primary);
        font-size: 14px; font-weight: 500; cursor: pointer; transition: box-shadow 0.2s;
      }
      .btn-primary:hover { box-shadow: 0 1px 3px rgba(0,0,0,0.3), 0 4px 8px rgba(0,0,0,0.2); }
    </style>
  </head>
<body>
  <div class="page-container">
    <div class="login-surface">
      <div class="header">
        <h1>${setyourpassword}</h1>
      </div>
      <form id="passwordForm" method=POST action="<%= request.getRequestURI() %>" novalidate>
        <div class="md3-field" id="passwordField">
          <input type=password name=password id="passwordInput" value="" placeholder=" " autocomplete="new-password">
          <label>${password}</label>
        </div>
        <div id="passwordError" class="error-text"></div>
        <input type=hidden name=locale value="<%= locale %>">
        <button type=submit class="btn-primary">${setpassword}</button>
      </form>
    </div>
  </div>

  <script>
    const form = document.getElementById('passwordForm');
    const passwordInput = document.getElementById('passwordInput');
    const passwordField = document.getElementById('passwordField');
    const passwordError = document.getElementById('passwordError');

    form.addEventListener('submit', (e) => {
      if (passwordInput.value.trim() === '') {
        e.preventDefault();
        passwordError.textContent = '${StringEscapeUtils.escapeEcmaScript(passwordEmptyError)}';
        passwordField.classList.add('error');
        passwordError.classList.add('visible');
      }
    });

    passwordInput.addEventListener('input', () => {
      passwordField.classList.remove('error');
      passwordError.classList.remove('visible');
    });
  </script>
</body></html>
