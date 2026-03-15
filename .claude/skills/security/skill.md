# Security Standards: AppIdeaSocialApp

## 1. Environment & Credentials (Project Foundation)
- **Secrets Management:** Never commit secrets, API keys, or credentials to the repository. 
- **Environment Files:** Use '.env.local' or Rails credentials for all sensitive environment variables.
- **Safe Defaults:** Ensure production-level security headers and HTTPS are enforced in configuration.

## 2. Input & Injection Prevention (thoughtbot Integrated)
- **SQL Injection:** Strictly prohibit string interpolation in database queries (e.g., use 'where("name = ?", params[:name])' instead of interpolation).
- **Mass Assignment:** 'params.permit!' is strictly forbidden. Always use Strong Parameters to whitelist specific attributes.
- **Cross-Site Scripting (XSS):** Avoid 'raw' or 'html_safe' with user-provided input. Use 'sanitize' or allow Rails to auto-escape by default.
- **Command Injection:** Never pass user input directly to system shells (e.g., backticks or 'system'). Use array forms for system calls.

## 3. Access Control & Privacy
- **IDOR Protection:** Every controller action must scope resource lookups to the 'current_user' or use an explicit authorization check (e.g., Pundit) to prevent unauthorized access to other users' data.
- **Missing Authentication:** Every controller should require authentication (e.g., 'before_action :authenticate_user!') unless the action is explicitly public.
- **Sensitive Data Exposure:** Ensure sensitive parameters like ':password', ':token', and ':secret' are filtered in 'config.filter_parameters' and whitelisted in JSON responses.

## 4. Session & Request Security
- **CSRF Protection:** Use proper token handling for APIs and ensure Rails form helpers are used to include CSRF tokens.
- **Redirect Security:** Validate and allowlist all redirect URLs to prevent open redirect vulnerabilities.
- **Safe Session Config:** Ensure sessions are configured with 'httponly: true' and 'secure: true' in production environments.