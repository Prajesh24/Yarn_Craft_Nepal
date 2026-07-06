import nodemailer, { Transporter } from 'nodemailer';
import { SMTP } from '../config';

class EmailService {
  private transporter: Transporter | null = null;
  private usingEthereal = false;

  /**
   * Lazily build (and memoise) a transporter.
   * - If real SMTP credentials are configured (e.g. a Gmail App Password),
   *   email is delivered to the recipient's real inbox.
   * - Otherwise we auto-create a free Ethereal test account so the flow still
   *   works end-to-end and we get a clickable preview URL in the server log.
   */
  private async getTransporter(): Promise<Transporter> {
    if (this.transporter) return this.transporter;

    if (SMTP.user && SMTP.pass) {
      this.transporter = nodemailer.createTransport({
        host:   SMTP.host,
        port:   SMTP.port,
        secure: SMTP.port === 465,
        auth: { user: SMTP.user, pass: SMTP.pass },
      });
      this.usingEthereal = false;
      console.log(`📧 Email: using real SMTP (${SMTP.host}) as ${SMTP.user}`);
    } else {
      const testAccount = await nodemailer.createTestAccount();
      this.transporter = nodemailer.createTransport({
        host:   'smtp.ethereal.email',
        port:   587,
        secure: false,
        auth: { user: testAccount.user, pass: testAccount.pass },
      });
      this.usingEthereal = true;
      console.log(
        '📧 Email: no SMTP_USER/SMTP_PASS set — using Ethereal test inbox.\n' +
        '   Add a Gmail App Password to .env to deliver to a real inbox.'
      );
    }

    return this.transporter;
  }

  private get from(): string {
    return `"YarnCraft Nepal" <${SMTP.user || 'no-reply@yarncraft.np'}>`;
  }

  /** Send a clickable password-reset link. Returns the preview URL when on Ethereal. */
  async sendPasswordResetLink(email: string, resetUrl: string): Promise<void> {
    const html = `
      <div style="font-family:sans-serif;max-width:480px;margin:auto;padding:32px;
                  background:#f8f9fa;border-radius:12px;">
        <div style="text-align:center;margin-bottom:24px;">
          <h2 style="color:#1B6B61;margin:0;">YarnCraft Nepal</h2>
          <p style="color:#6B7280;font-size:14px;margin-top:4px;">Authentic Nepali Textiles</p>
        </div>

        <div style="background:#fff;border-radius:12px;padding:32px;
                    box-shadow:0 2px 8px rgba(0,0,0,0.06);">
          <h3 style="color:#111827;margin-top:0;">Reset Your Password</h3>
          <p style="color:#6B7280;font-size:14px;line-height:1.6;">
            We received a request to reset your YarnCraft Nepal password.
            Click the button below to choose a new one. This link expires in
            <strong>15 minutes</strong>.
          </p>

          <div style="text-align:center;margin:28px 0;">
            <a href="${resetUrl}"
               style="background:#1B6B61;color:#fff;text-decoration:none;
                      font-weight:700;font-size:15px;padding:14px 28px;
                      border-radius:10px;display:inline-block;">
              Reset Password
            </a>
          </div>

          <p style="color:#9CA3AF;font-size:12px;line-height:1.5;">
            If the button doesn't work, copy and paste this link into your browser:<br>
            <a href="${resetUrl}" style="color:#1B6B61;word-break:break-all;">${resetUrl}</a>
          </p>

          <p style="color:#9CA3AF;font-size:12px;margin-top:24px;">
            If you didn't request a password reset, you can safely ignore this email.
            Your password won't change.
          </p>
        </div>
      </div>
    `;

    try {
      const transporter = await this.getTransporter();
      const info = await transporter.sendMail({
        from:    this.from,
        to:      email,
        subject: 'YarnCraft Nepal — Reset Your Password',
        html,
      });

      if (this.usingEthereal) {
        const preview = nodemailer.getTestMessageUrl(info);
        console.log(`📬 [Ethereal] Reset email preview: ${preview}`);
      } else {
        console.log(`📬 Reset email sent to ${email}`);
      }
    } catch (err) {
      console.error('❌ Failed to send reset email:', err);
    }
  }

  async sendWelcomeEmail(email: string, name: string): Promise<void> {
    const html = `
      <div style="font-family:sans-serif;max-width:480px;margin:auto;padding:32px;">
        <h2 style="color:#1B6B61;">Welcome, ${name}!</h2>
        <p style="color:#6B7280;">
          Your YarnCraft Nepal account is ready.
          Start exploring authentic Nepali textiles and hand-spun yarns.
        </p>
        <p style="color:#9CA3AF;font-size:12px;margin-top:32px;">— The YarnCraft Nepal Team</p>
      </div>
    `;

    try {
      const transporter = await this.getTransporter();
      const info = await transporter.sendMail({
        from:    this.from,
        to:      email,
        subject: 'Welcome to YarnCraft Nepal! 🧶',
        html,
      });
      if (this.usingEthereal) {
        console.log(`📬 [Ethereal] Welcome email preview: ${nodemailer.getTestMessageUrl(info)}`);
      }
    } catch (err) {
      console.error('❌ Failed to send welcome email:', err);
    }
  }
}

export const emailService = new EmailService();
