import { Router, Request, Response } from 'express';

import { PasswordResetRepository } from '../repositories/password_reset_repository';
import { AuthService }             from '../services/auth.service';

const router                  = Router();
const passwordResetRepository = new PasswordResetRepository();
const authService             = new AuthService();

// ── Shared HTML shell ─────────────────────────────────────────────────────────
function page(body: string): string {
  return `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>YarnCraft Nepal — Reset Password</title>
  <style>
    * { box-sizing: border-box; }
    body { margin:0; font-family:-apple-system,Segoe UI,Roboto,sans-serif;
           background:linear-gradient(180deg,#D7E8E4,#F0F5F4 50%,#F5EDD8);
           min-height:100vh; display:flex; align-items:center; justify-content:center; padding:24px; }
    .card { background:#fff; width:100%; max-width:420px; border-radius:20px;
            padding:32px; box-shadow:0 8px 30px rgba(0,0,0,0.08); }
    h1 { color:#1B6B61; font-size:22px; margin:0 0 4px; text-align:center; }
    .sub { color:#6B7280; font-size:14px; text-align:center; margin:0 0 24px; }
    label { display:block; color:#111827; font-size:13px; font-weight:600; margin:16px 0 6px; }
    input { width:100%; padding:14px 16px; border:1px solid #E5E7EB; border-radius:12px;
            font-size:15px; outline:none; }
    input:focus { border-color:#1B6B61; }
    button { width:100%; margin-top:24px; padding:15px; background:#1B6B61; color:#fff;
             border:none; border-radius:12px; font-size:16px; font-weight:600; cursor:pointer; }
    button:hover { background:#155952; }
    .err { color:#DC2626; font-size:13px; margin-top:8px; }
    .icon { width:56px; height:56px; border-radius:50%; background:#E8F5F3;
            display:flex; align-items:center; justify-content:center; margin:0 auto 16px; font-size:26px; }
    .center { text-align:center; }
    .muted { color:#6B7280; font-size:14px; line-height:1.6; }
  </style>
</head>
<body><div class="card">${body}</div></body>
</html>`;
}

function invalidPage(message: string): string {
  return page(`
    <div class="icon">⚠️</div>
    <h1>Link Expired</h1>
    <p class="sub">${message}</p>
    <p class="muted center">Please return to the YarnCraft Nepal app and request a new password reset link.</p>
  `);
}

// ── GET /reset-password/:token — show the reset form ───────────────────────────
router.get('/reset-password/:token', async (req: Request, res: Response) => {
  const token = String(req.params.token);
  const record = await passwordResetRepository.findValidByToken(token);

  if (!record) {
    return res.status(400).send(
      invalidPage('This password reset link is invalid or has already been used.')
    );
  }

  return res.send(page(`
    <div class="icon">🔑</div>
    <h1>Reset Your Password</h1>
    <p class="sub">Choose a new password for your account.</p>
    <form method="POST" action="/reset-password/${token}">
      <label for="new_password">New Password</label>
      <input type="password" id="new_password" name="new_password" placeholder="••••••••" minlength="6" required />
      <label for="confirm_password">Confirm Password</label>
      <input type="password" id="confirm_password" name="confirm_password" placeholder="••••••••" minlength="6" required />
      <button type="submit">Reset Password</button>
    </form>
  `));
});

// ── POST /reset-password/:token — process the new password ─────────────────────
router.post('/reset-password/:token', async (req: Request, res: Response) => {
  const token = String(req.params.token);
  const { new_password, confirm_password } = req.body ?? {};

  if (!new_password || new_password.length < 6) {
    return res.status(400).send(page(`
      <div class="icon">🔑</div>
      <h1>Reset Your Password</h1>
      <p class="err center">Password must be at least 6 characters.</p>
      <form method="POST" action="/reset-password/${token}">
        <label for="new_password">New Password</label>
        <input type="password" id="new_password" name="new_password" minlength="6" required />
        <label for="confirm_password">Confirm Password</label>
        <input type="password" id="confirm_password" name="confirm_password" minlength="6" required />
        <button type="submit">Reset Password</button>
      </form>
    `));
  }

  if (new_password !== confirm_password) {
    return res.status(400).send(page(`
      <div class="icon">🔑</div>
      <h1>Reset Your Password</h1>
      <p class="err center">Passwords do not match. Please try again.</p>
      <form method="POST" action="/reset-password/${token}">
        <label for="new_password">New Password</label>
        <input type="password" id="new_password" name="new_password" minlength="6" required />
        <label for="confirm_password">Confirm Password</label>
        <input type="password" id="confirm_password" name="confirm_password" minlength="6" required />
        <button type="submit">Reset Password</button>
      </form>
    `));
  }

  try {
    await authService.resetPassword({ token, new_password, confirm_password });
    return res.send(page(`
      <div class="icon">✅</div>
      <h1>Password Reset</h1>
      <p class="sub">Your password has been changed successfully.</p>
      <p class="muted center">You can now return to the YarnCraft Nepal app and sign in with your new password.</p>
    `));
  } catch (err: any) {
    return res.status(400).send(
      invalidPage(err?.message || 'This reset link is invalid or has expired.')
    );
  }
});

export default router;
