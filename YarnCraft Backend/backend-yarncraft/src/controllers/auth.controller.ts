import { Request, Response } from 'express';
import z from 'zod';

import { AuthService } from '../services/auth.service';
import {
  CreateUserDTO,
  LoginDTO,
  ForgotPasswordDTO,
  ResetPasswordDTO,
  UpdateUserDTO,
  ChangePasswordDTO,
} from '../dtos/user.dto';

const authService = new AuthService();

export class AuthController {

  // ── POST /api/auth/register ────────────────────────────────────────────────

  async register(req: Request, res: Response) {
    try {
      const parsed = CreateUserDTO.safeParse(req.body);
      if (!parsed.success) {
        return res.status(400).json({
          success: false,
          message: z.prettifyError(parsed.error),
        });
      }

      const user = await authService.register(parsed.data);

      return res.status(201).json({
        success: true,
        message: 'Account created successfully.',
        data:    user,
      });
    } catch (error: any) {
      return res.status(error.statusCode ?? 500).json({
        success: false,
        message: error.message || 'Internal Server Error',
      });
    }
  }

  // ── POST /api/auth/login ───────────────────────────────────────────────────

  async login(req: Request, res: Response) {
    try {
      const parsed = LoginDTO.safeParse(req.body);
      if (!parsed.success) {
        return res.status(400).json({
          success: false,
          message: z.prettifyError(parsed.error),
        });
      }

      const { token, user } = await authService.login(parsed.data);

      // Flutter reads: response.data['success'], response.data['data'], response.data['token']
      return res.status(200).json({
        success: true,
        message: 'Login successful.',
        data:    user,
        token,
      });
    } catch (error: any) {
      return res.status(error.statusCode ?? 500).json({
        success: false,
        message: error.message || 'Internal Server Error',
      });
    }
  }

  // ── GET /api/auth/me ───────────────────────────────────────────────────────

  async getProfile(req: Request, res: Response) {
    try {
      const userId = req.user?._id as string;
      if (!userId) {
        return res.status(401).json({ success: false, message: 'Unauthorized.' });
      }

      const user = await authService.getProfile(userId);

      return res.status(200).json({
        success: true,
        message: 'Profile fetched successfully.',
        data:    user,
      });
    } catch (error: any) {
      return res.status(error.statusCode ?? 500).json({
        success: false,
        message: error.message || 'Internal Server Error',
      });
    }
  }

  // ── PATCH /api/auth/me/update ──────────────────────────────────────────────

  async updateProfile(req: Request, res: Response) {
    try {
      const userId = req.user?._id as string;
      if (!userId) {
        return res.status(401).json({ success: false, message: 'Unauthorized.' });
      }

      const parsed = UpdateUserDTO.safeParse(req.body);
      if (!parsed.success) {
        return res.status(400).json({
          success: false,
          message: z.prettifyError(parsed.error),
        });
      }

      // If a file was uploaded, set the imageUrl
      if (req.file) {
        parsed.data.imageUrl = `/uploads/${req.file.filename}`;
      }

      const updated = await authService.updateProfile(userId, parsed.data);

      return res.status(200).json({
        success: true,
        message: 'Profile updated successfully.',
        user:    updated,        // Flutter reads: data['user']
      });
    } catch (error: any) {
      return res.status(error.statusCode ?? 500).json({
        success: false,
        message: error.message || 'Internal Server Error',
      });
    }
  }

  // ── POST /api/auth/change-password ────────────────────────────────────────

  async changePassword(req: Request, res: Response) {
    try {
      const userId = req.user?._id as string;
      if (!userId) {
        return res.status(401).json({ success: false, message: 'Unauthorized.' });
      }

      const parsed = ChangePasswordDTO.safeParse(req.body);
      if (!parsed.success) {
        return res.status(400).json({
          success: false,
          message: z.prettifyError(parsed.error),
        });
      }

      const result = await authService.changePassword(userId, parsed.data);

      return res.status(200).json({ success: true, ...result });
    } catch (error: any) {
      return res.status(error.statusCode ?? 500).json({
        success: false,
        message: error.message || 'Internal Server Error',
      });
    }
  }

  // ── POST /api/auth/forgot-password ───────────────────────────────────────

  async forgotPassword(req: Request, res: Response) {
    try {
      const parsed = ForgotPasswordDTO.safeParse(req.body);
      if (!parsed.success) {
        return res.status(400).json({
          success: false,
          message: z.prettifyError(parsed.error),
        });
      }

      const result = await authService.forgotPassword(parsed.data);

      return res.status(200).json({ success: true, ...result });
    } catch (error: any) {
      return res.status(error.statusCode ?? 500).json({
        success: false,
        message: error.message || 'Internal Server Error',
      });
    }
  }

  // ── POST /api/auth/reset-password ────────────────────────────────────────

  async resetPassword(req: Request, res: Response) {
    try {
      const parsed = ResetPasswordDTO.safeParse(req.body);
      if (!parsed.success) {
        return res.status(400).json({
          success: false,
          message: z.prettifyError(parsed.error),
        });
      }

      const result = await authService.resetPassword(parsed.data);

      return res.status(200).json({ success: true, ...result });
    } catch (error: any) {
      return res.status(error.statusCode ?? 500).json({
        success: false,
        message: error.message || 'Internal Server Error',
      });
    }
  }

  // ── POST /api/auth/logout ─────────────────────────────────────────────────
  // JWT is stateless — logout is handled client-side by deleting the token.
  // This endpoint exists so Flutter can call it without errors.

  async logout(_req: Request, res: Response) {
    return res.status(200).json({
      success: true,
      message: 'Logged out successfully.',
    });
  }
}