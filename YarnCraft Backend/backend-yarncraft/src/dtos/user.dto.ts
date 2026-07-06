import z from 'zod';
import { UserSchema } from '../types/user.type';

// ── Register ──────────────────────────────────────────────────────────────────
// Flutter sends: { name, email, password, confirmPassword, imageUrl?, role? }

export const CreateUserDTO = UserSchema.extend({
  confirmPassword: z.string().min(6, 'Confirm password must be at least 6 characters'),
}).refine((data) => data.password === data.confirmPassword, {
  message: 'Passwords do not match',
  path:    ['confirmPassword'],
});

export type CreateUserDTO = z.infer<typeof CreateUserDTO>;

// ── Login ─────────────────────────────────────────────────────────────────────
// Flutter sends: { email, password }

export const LoginDTO = z.object({
  email:    z.string().email('Invalid email address'),
  password: z.string().min(6, 'Password must be at least 6 characters'),
});

export type LoginDTO = z.infer<typeof LoginDTO>;

// ── Forgot password ───────────────────────────────────────────────────────────
// Flutter sends: { email_or_phone }

export const ForgotPasswordDTO = z.object({
  email_or_phone: z.string().min(1, 'Email or phone is required'),
});

export type ForgotPasswordDTO = z.infer<typeof ForgotPasswordDTO>;

// ── Reset password ────────────────────────────────────────────────────────────
// Flutter sends: { token, new_password, confirm_password }

export const ResetPasswordDTO = z.object({
  token:            z.string().min(1, 'Reset token is required'),
  new_password:     z.string().min(6, 'Password must be at least 6 characters'),
  confirm_password: z.string().min(6),
}).refine((data) => data.new_password === data.confirm_password, {
  message: 'Passwords do not match',
  path:    ['confirm_password'],
});

export type ResetPasswordDTO = z.infer<typeof ResetPasswordDTO>;

// ── Update profile ────────────────────────────────────────────────────────────
// Flutter sends: { name?, imageUrl? }

export const UpdateUserDTO = UserSchema.partial();
export type UpdateUserDTO = z.infer<typeof UpdateUserDTO>;

// ── Change password ───────────────────────────────────────────────────────────
// Flutter sends: { current_password, new_password }

export const ChangePasswordDTO = z.object({
  current_password: z.string().min(6),
  new_password:     z.string().min(6, 'Password must be at least 6 characters'),
}).refine((data) => data.current_password !== data.new_password, {
  message: 'New password must differ from current password',
  path:    ['new_password'],
});

export type ChangePasswordDTO = z.infer<typeof ChangePasswordDTO>;