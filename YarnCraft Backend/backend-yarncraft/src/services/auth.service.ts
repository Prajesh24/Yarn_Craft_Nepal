import bcryptjs from 'bcryptjs';
import jwt      from 'jsonwebtoken';
import crypto   from 'crypto';

import { UserRepository }          from '../repositories/user.repository';
import { PasswordResetRepository } from '../repositories/password_reset_repository';
import { PasswordResetModel }      from '../models/password_reset_model';
import { emailService }            from './email.service';

import {
  CreateUserDTO,
  LoginDTO,
  ForgotPasswordDTO,
  ResetPasswordDTO,
  UpdateUserDTO,
  ChangePasswordDTO,
} from '../dtos/user.dto';

import { HttpError }                   from '../errors/http-error';
import { JWT_SECRET, JWT_EXPIRES_IN, APP_BASE_URL }  from '../config';

const userRepository          = new UserRepository();
const passwordResetRepository = new PasswordResetRepository();

export class AuthService {

  // ── REGISTER ───────────────────────────────────────────────────────────────

  async register(data: CreateUserDTO) {
    const existing = await userRepository.getUserByEmail(data.email);
    if (existing) {
      throw new HttpError(409, 'An account with this email already exists.');
    }

    const hashedPassword = await bcryptjs.hash(data.password, 12);

    const user = await userRepository.createUser({
      name:     data.name,
      email:    data.email,
      password: hashedPassword,
      imageUrl: data.imageUrl ?? undefined,
      role:     data.role    ?? 'user',
    });

    // Send welcome email (non-blocking — won't fail the request)
    emailService.sendWelcomeEmail(user.email, user.name);

    return user;
  }

  // ── LOGIN ──────────────────────────────────────────────────────────────────

  async login(data: LoginDTO) {
    const user = await userRepository.getUserByEmail(data.email);
    if (!user) {
      throw new HttpError(404, 'No account found with this email.');
    }

    const isValid = await bcryptjs.compare(data.password, user.password);
    if (!isValid) {
      throw new HttpError(401, 'Invalid credentials.');
    }

    const token = jwt.sign(
      { id: user._id },
      JWT_SECRET,
      { expiresIn: JWT_EXPIRES_IN as any }
    );

    return { token, user };
  }

  // ── GET PROFILE ────────────────────────────────────────────────────────────

  async getProfile(userId: string) {
    const user = await userRepository.getUserById(userId);
    if (!user) throw new HttpError(404, 'User not found.');
    return user;
  }

  // ── UPDATE PROFILE ─────────────────────────────────────────────────────────

  async updateProfile(userId: string, data: UpdateUserDTO) {
    if (data.email) {
      const existing = await userRepository.getUserByEmail(data.email);
      if (existing && existing._id.toString() !== String(userId)) {
        throw new HttpError(409, 'Email already in use by another account.');
      }
    }

    if (data.password) {
      data.password = await bcryptjs.hash(data.password, 12);
    }

    const updated = await userRepository.updateUser(userId, data);
    if (!updated) throw new HttpError(404, 'User not found.');
    return updated;
  }

  // ── CHANGE PASSWORD ────────────────────────────────────────────────────────

  async changePassword(userId: string, data: ChangePasswordDTO) {
    // Re-fetch with the password field included
    const fetchedUser = await userRepository.getUserById(userId);
    if (!fetchedUser) throw new HttpError(404, 'User not found.');

    const userWithPass = await userRepository.getUserByEmail(fetchedUser.email);
    if (!userWithPass) throw new HttpError(404, 'User not found.');

    const isValid = await bcryptjs.compare(data.current_password, userWithPass.password);
    if (!isValid) throw new HttpError(401, 'Current password is incorrect.');

    const hashed = await bcryptjs.hash(data.new_password, 12);
    await userRepository.updateUser(userId, { password: hashed });

    return { message: 'Password changed successfully.' };
  }

  // ── FORGOT PASSWORD ────────────────────────────────────────────────────────

  async forgotPassword(data: ForgotPasswordDTO) {
    const user = await userRepository.getUserByEmailOrPhone(data.email_or_phone);

    // Always return success to prevent email enumeration attacks
    if (!user) {
      return { message: 'If an account exists, a reset code has been sent.' };
    }

    // 6-digit OTP kept for backwards compatibility (not used by the link flow)
    const otp = Math.floor(100000 + Math.random() * 900000).toString();

    // 64-char hex token embedded in the emailed reset link
    const token = crypto.randomBytes(32).toString('hex');

    await passwordResetRepository.createReset(user.email, otp, token);

    const resetUrl = `${APP_BASE_URL}/reset-password/${token}`;
    await emailService.sendPasswordResetLink(user.email, resetUrl);

    // Log the link to the console for development convenience
    console.log(`🔗 [DEV] Password reset link for ${user.email}: ${resetUrl}`);

    return { message: 'If an account exists, a reset link has been sent.' };
  }

  // ── RESET PASSWORD ─────────────────────────────────────────────────────────

  async resetPassword(data: ResetPasswordDTO) {
    // Flutter sends either a 6-digit OTP or a 64-char deep-link token
    const isOtp = /^\d{6}$/.test(data.token);

    let resetRecord = null;

    if (isOtp) {
      // OTP flow — search across all valid records (production: also require email)
      resetRecord = await PasswordResetModel.findOne({
        otp:       data.token,
        used:      false,
        expiresAt: { $gt: new Date() },
      }).exec();
    } else {
      // Deep-link token flow
      resetRecord = await passwordResetRepository.findValidByToken(data.token);
    }

    if (!resetRecord) {
      throw new HttpError(400, 'Invalid or expired reset code. Please request a new one.');
    }

    const hashed = await bcryptjs.hash(data.new_password, 12);

    await userRepository.updatePasswordByEmail(resetRecord.email, hashed);
    await passwordResetRepository.markUsed(resetRecord._id as unknown as string);

    return { message: 'Password reset successfully.' };
  }
}