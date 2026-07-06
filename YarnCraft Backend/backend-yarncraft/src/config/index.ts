import dotenv from 'dotenv';
dotenv.config();

export const PORT:           number = process.env.PORT ? parseInt(process.env.PORT) : 5051;
export const MONGODB_URI:    string = process.env.MONGODB_URI    || 'mongodb://localhost:27017/yarncraft_db';
export const JWT_SECRET:     string = process.env.JWT_SECRET     || 'yarncraft_secret_key';
export const JWT_EXPIRES_IN: string = process.env.JWT_EXPIRES_IN || '30d';
export const CLIENT_URL:     string = process.env.CLIENT_URL     || 'http://localhost:3000';
// Public base URL where the backend serves the password-reset web page.
// The reset link emailed to users points here: `${APP_BASE_URL}/reset-password/<token>`.
export const APP_BASE_URL:   string = process.env.APP_BASE_URL   || `http://localhost:${PORT}`;
export const OTP_EXPIRES_MIN: number = process.env.OTP_EXPIRES_MIN
  ? parseInt(process.env.OTP_EXPIRES_MIN)
  : 15;

export const SMTP = {
  host: process.env.SMTP_HOST || 'smtp.gmail.com',
  port: process.env.SMTP_PORT ? parseInt(process.env.SMTP_PORT) : 587,
  user: process.env.SMTP_USER || '',
  pass: process.env.SMTP_PASS || '',
};