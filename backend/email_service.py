import os
import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
import logging
from dotenv import load_dotenv

logger = logging.getLogger("email_service")
logging.basicConfig(level=logging.INFO)

def send_email(to_email: str, subject: str, text_content: str, html_content: str = None) -> bool:
    """
    Sends an email using configured SMTP settings.
    If SMTP settings are not configured, prints the email to console for development.
    """
    load_dotenv()
    smtp_host = os.getenv("SMTP_HOST", "").strip()
    smtp_port = int(os.getenv("SMTP_PORT", "587"))
    smtp_user = os.getenv("SMTP_USER", "").strip()
    smtp_password = os.getenv("SMTP_PASSWORD", "").strip()
    smtp_from_email = os.getenv("SMTP_FROM_EMAIL", smtp_user or "noreply@loginapp.com").strip()
    smtp_from_name = os.getenv("SMTP_FROM_NAME", "Login App").replace('"', '').strip()
    smtp_use_tls = os.getenv("SMTP_USE_TLS", "true").lower() in ("true", "1", "yes")
    smtp_use_ssl = os.getenv("SMTP_USE_SSL", "false").lower() in ("true", "1", "yes")

    # Check if SMTP is configured
    if not smtp_host or not smtp_user:
        print("\n" + "=" * 60)
        print(f"[DEV EMAIL SIMULATION]")
        print(f"To: {to_email}")
        print(f"Subject: {subject}")
        print("-" * 60)
        print(text_content)
        print("=" * 60 + "\n")
        logger.info(f"Simulated email sent to {to_email} (SMTP not configured in .env)")
        return True

    try:
        msg = MIMEMultipart("alternative")
        msg["Subject"] = subject
        msg["From"] = f"{smtp_from_name} <{smtp_from_email}>"
        msg["To"] = to_email

        msg.attach(MIMEText(text_content, "plain"))
        if html_content:
            msg.attach(MIMEText(html_content, "html"))

        if smtp_use_ssl:
            server = smtplib.SMTP_SSL(smtp_host, smtp_port, timeout=12)
        else:
            server = smtplib.SMTP(smtp_host, smtp_port, timeout=12)
            if smtp_use_tls:
                server.starttls()

        if smtp_password:
            server.login(smtp_user, smtp_password)

        server.sendmail(smtp_from_email, [to_email], msg.as_string())
        server.quit()
        logger.info(f"Email successfully delivered to {to_email}")
        return True

    except Exception as e:
        logger.error(f"Failed to send email to {to_email}: {e}")
        # Print fallback to console so development is never blocked
        print("\n" + "=" * 60)
        print(f"[EMAIL DISPATCH FAILED - CONSOLE FALLBACK]")
        print(f"To: {to_email}")
        print(f"Subject: {subject}")
        print(f"Error: {e}")
        print("-" * 60)
        print(text_content)
        print("=" * 60 + "\n")
        return False



def send_registration_confirmation(to_email: str, name: str = "User"):
    """
    Sends registration confirmation email stating 'You have successfully registered.'
    """
    subject = "Welcome to Login App - Registration Successful"
    text_content = f"""Hello {name},

You have successfully registered.

Thank you for joining our platform! You can now log in using your registered credentials.

Best regards,
Login App Team
"""

    html_content = f"""
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="utf-8">
        <style>
            body {{ font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f4f6f9; margin: 0; padding: 20px; }}
            .card {{ max-width: 520px; margin: 0 auto; background: #ffffff; border-radius: 16px; overflow: hidden; box-shadow: 0 4px 20px rgba(0,0,0,0.08); }}
            .header {{ background: linear-gradient(135deg, #4361EE, #3A0CA3); color: white; padding: 30px 20px; text-align: center; }}
            .header h1 {{ margin: 0; font-size: 24px; font-weight: 700; }}
            .content {{ padding: 30px 24px; color: #333333; line-height: 1.6; font-size: 15px; }}
            .badge {{ display: inline-block; background-color: #e8f5e9; color: #2e7d32; padding: 8px 16px; border-radius: 20px; font-weight: 600; margin: 15px 0; }}
            .footer {{ background: #f8fafc; padding: 15px; text-align: center; font-size: 12px; color: #888888; border-top: 1px solid #eeeeee; }}
        </style>
    </head>
    <body>
        <div class="card">
            <div class="header">
                <h1>Welcome to Login App</h1>
            </div>
            <div class="content">
                <p>Hello <strong>{name}</strong>,</p>
                <div class="badge">🎉 You have successfully registered.</div>
                <p>Your account has been created. When you log in for the first time, you will receive a secure OTP on this email address to verify your identity.</p>
                <p>We're thrilled to have you on board!</p>
            </div>
            <div class="footer">
                &copy; Login App. All rights reserved.
            </div>
        </div>
    </body>
    </html>
    """
    return send_email(to_email, subject, text_content, html_content)


def send_login_otp(to_email: str, name: str = "User", otp: str = ""):
    """
    Sends email with 6-digit OTP verification code for first-time login.
    """
    subject = f"{otp} is your Login Verification Code"
    text_content = f"""Hello {name},

Your verification code for logging in is: {otp}

This OTP is valid for 10 minutes. Please do not share this code with anyone.

Best regards,
Login App Team
"""

    html_content = f"""
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="utf-8">
        <style>
            body {{ font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f4f6f9; margin: 0; padding: 20px; }}
            .card {{ max-width: 520px; margin: 0 auto; background: #ffffff; border-radius: 16px; overflow: hidden; box-shadow: 0 4px 20px rgba(0,0,0,0.08); }}
            .header {{ background: linear-gradient(135deg, #4361EE, #3A0CA3); color: white; padding: 30px 20px; text-align: center; }}
            .header h1 {{ margin: 0; font-size: 24px; font-weight: 700; }}
            .content {{ padding: 30px 24px; color: #333333; line-height: 1.6; font-size: 15px; text-align: center; }}
            .otp-box {{ display: inline-block; background: #f0f4ff; border: 2px dashed #4361EE; color: #4361EE; font-size: 32px; font-weight: 800; letter-spacing: 8px; padding: 14px 28px; border-radius: 12px; margin: 20px 0; }}
            .note {{ font-size: 13px; color: #666666; margin-top: 10px; }}
            .footer {{ background: #f8fafc; padding: 15px; text-align: center; font-size: 12px; color: #888888; border-top: 1px solid #eeeeee; }}
        </style>
    </head>
    <body>
        <div class="card">
            <div class="header">
                <h1>Email Verification</h1>
            </div>
            <div class="content">
                <p>Hello <strong>{name}</strong>,</p>
                <p>Use the following One-Time Password (OTP) to complete your first-time login verification:</p>
                <div class="otp-box">{otp}</div>
                <p class="note">⏱️ This code will expire in <strong>10 minutes</strong>.<br>If you did not attempt to log in, please ignore this email.</p>
            </div>
            <div class="footer">
                &copy; Login App. All rights reserved.
            </div>
        </div>
    </body>
    </html>
    """
    return send_email(to_email, subject, text_content, html_content)

