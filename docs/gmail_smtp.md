Gmail SMTP setup for Taskflow

Overview
- This project uses Action Mailer for Devise password reset emails.
- Use Gmail SMTP with an App Password (recommended) for development/production.

Required environment variables
- GMAIL_SMTP_USERNAME: your Gmail address (e.g. user@gmail.com)
- GMAIL_SMTP_PASSWORD: Gmail App Password (16-char) — do NOT use your main account password
- GMAIL_SMTP_ADDRESS: optional, defaults to smtp.gmail.com
- GMAIL_SMTP_PORT: optional, defaults to 587
- GMAIL_SMTP_DOMAIN: optional, defaults to your host (example.com)
- DEFAULT_FROM_EMAIL: email used as Devise `mailer_sender` (e.g. no-reply@yourdomain.com)
- HOSTNAME: app host used in mailer URLs (production)

How to create a Gmail App Password
1. Enable 2-Step Verification on your Google account.
2. Go to Google Account > Security > App passwords.
3. Create an App Password for "Mail" and copy the generated 16-character password.

Example .env (development)

GMAIL_SMTP_USERNAME=youremail@gmail.com
GMAIL_SMTP_PASSWORD=abcdefghijklmnop
GMAIL_SMTP_ADDRESS=smtp.gmail.com
GMAIL_SMTP_PORT=587
GMAIL_SMTP_DOMAIN=localhost
DEFAULT_FROM_EMAIL=no-reply@localhost
HOSTNAME=localhost:3000

Commands
- Start dev server (ensure env vars are set):

```bash
# using direnv or export
export GMAIL_SMTP_USERNAME=youremail@gmail.com
export GMAIL_SMTP_PASSWORD=abcdefghijklmnop
export DEFAULT_FROM_EMAIL=no-reply@localhost
export HOSTNAME=localhost:3000
bundle install
bin/rails db:setup
bin/rails server
```

Notes
- For development email previews without sending, consider adding `letter_opener` gem and switching `delivery_method` to `:letter_opener` in `config/environments/development.rb`.
- Never commit credentials. Use secrets manager or CI/CD environment variables for production.
