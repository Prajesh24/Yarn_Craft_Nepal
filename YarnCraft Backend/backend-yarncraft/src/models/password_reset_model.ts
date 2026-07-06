import mongoose, { Document, Schema } from 'mongoose';
import { OTP_EXPIRES_MIN } from '../config';

export interface IPasswordReset extends Document {
  email:     string;
  otp:       string;           // 6-digit code shown to the user
  token:     string;           // hashed version stored in DB
  expiresAt: Date;
  used:      boolean;
}

const passwordResetSchema: Schema = new Schema<IPasswordReset>(
  {
    email:     { type: String, required: true, lowercase: true },
    otp:       { type: String, required: true },   // hashed
    token:     { type: String, required: true },   // raw token for deep-link flow
    expiresAt: { type: Date,   required: true },
    used:      { type: Boolean, default: false },
  },
  { timestamps: true }
);

// Auto-delete expired documents from MongoDB
passwordResetSchema.index({ expiresAt: 1 }, { expireAfterSeconds: 0 });

export const PasswordResetModel = mongoose.model<IPasswordReset>(
  'PasswordReset',
  passwordResetSchema
);