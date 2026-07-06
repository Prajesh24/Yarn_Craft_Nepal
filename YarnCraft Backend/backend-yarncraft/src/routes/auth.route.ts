import { Router } from 'express';

import { AuthController }        from '../controllers/auth.controller';
import { authorizedMiddleware } from '../middlewears/authorized.middlewear';
import { uploads } from '../middlewears/upload.middlewear';


const router         = Router();
const authController = new AuthController();

// ── Public routes (no token needed) ──────────────────────────────────────────
router.post('/register',         authController.register);
router.post('/login',            authController.login);
router.post('/forgot-password',  authController.forgotPassword);
router.post('/reset-password',   authController.resetPassword);

// ── Protected routes (Bearer token required) ──────────────────────────────────
router.get ('/me',               authorizedMiddleware, authController.getProfile);
router.patch('/me/update',       authorizedMiddleware, uploads.single('image'), authController.updateProfile);
router.post('/change-password',  authorizedMiddleware, authController.changePassword);
router.post('/logout',           authorizedMiddleware, authController.logout);

export default router;