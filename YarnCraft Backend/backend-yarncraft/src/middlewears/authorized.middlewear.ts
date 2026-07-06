import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';

import { JWT_SECRET }      from '../config';
import { UserRepository }  from '../repositories/user.repository';
import { HttpError }       from '../errors/http-error';

const userRepository = new UserRepository();

export const authorizedMiddleware = async (
  req:  Request,
  res:  Response,
  next: NextFunction
): Promise<void> => {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      throw new HttpError(401, 'Unauthorized — JWT missing or malformed.');
    }

    const token = authHeader.split(' ')[1];
    if (!token) {
      throw new HttpError(401, 'Unauthorized — Token not found.');
    }

    const decoded = jwt.verify(token, JWT_SECRET) as Record<string, any>;
    if (!decoded?.id) {
      throw new HttpError(401, 'Unauthorized — Invalid token payload.');
    }

    const user = await userRepository.getUserById(decoded.id);
    if (!user) {
      throw new HttpError(401, 'Unauthorized — User no longer exists.');
    }

    req.user = user;
    next();
  } catch (err: any) {
    // Handle JWT-specific errors gracefully
    if (err.name === 'TokenExpiredError') {
      res.status(401).json({ success: false, message: 'Token expired. Please sign in again.' });
      return;
    }
    if (err.name === 'JsonWebTokenError') {
      res.status(401).json({ success: false, message: 'Invalid token.' });
      return;
    }
    res.status(err.statusCode || 500).json({
      success: false,
      message: err.message || 'Internal Server Error',
    });
  }
};

// ── Admin guard ───────────────────────────────────────────────────────────────
// Must run AFTER authorizedMiddleware (which attaches req.user).
export const adminMiddleware = async (
  req:  Request,
  res:  Response,
  next: NextFunction
): Promise<void> => {
  try {
    if (!req.user) {
      throw new HttpError(401, 'Unauthorized — no user info.');
    }
    if ((req.user as any).role !== 'admin') {
      throw new HttpError(403, 'Forbidden — admin access only.');
    }
    next();
  } catch (err: any) {
    res.status(err.statusCode || 500).json({
      success: false,
      message: err.message || 'Internal Server Error',
    });
  }
};