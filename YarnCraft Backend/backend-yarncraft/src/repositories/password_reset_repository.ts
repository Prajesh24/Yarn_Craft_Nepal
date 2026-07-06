import { PasswordResetModel, IPasswordReset } from '../models/password_reset_model';
import { OTP_EXPIRES_MIN } from '../config';

export class PasswordResetRepository {
  /** Delete any existing unused tokens for this email, then create a fresh one. */
  async createReset(
    email: string,
    otp:   string,
    token: string
  ): Promise<IPasswordReset> {
    // Invalidate old records for this email
    await PasswordResetModel.deleteMany({ email });

    const expiresAt = new Date(Date.now() + OTP_EXPIRES_MIN * 60 * 1000);

    return await PasswordResetModel.create({ email, otp, token, expiresAt });
  }

  /** Find a valid (not used, not expired) record by raw OTP code. */
  async findValidByOtp(
    email: string,
    otp:   string
  ): Promise<IPasswordReset | null> {
    return await PasswordResetModel.findOne({
      email,
      otp,
      used:      false,
      expiresAt: { $gt: new Date() },
    }).exec();
  }

  /** Find a valid record by the raw deep-link token. */
  async findValidByToken(token: string): Promise<IPasswordReset | null> {
    return await PasswordResetModel.findOne({
      token,
      used:      false,
      expiresAt: { $gt: new Date() },
    }).exec();
  }

  /** Mark a reset record as used so it cannot be reused. */
  async markUsed(id: string): Promise<void> {
    await PasswordResetModel.findByIdAndUpdate(id, { used: true }).exec();
  }
}