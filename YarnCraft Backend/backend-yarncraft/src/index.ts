import express, { Request, Response, NextFunction } from 'express';
import cors from 'cors';
import path from 'path';

import { PORT, CLIENT_URL } from './config';
import { connectDatabase } from './database/mongodb';

import authRoutes from './routes/auth.route';
import productRoutes from './routes/product.route';
import cartRoutes from './routes/cart.route';
import favouriteRoutes from './routes/favourite.route';
import orderRoutes from './routes/order.route';
import adminRoutes from './routes/admin/admin.route';
import resetWebRoutes from './routes/reset_web.route';
import { HttpError } from './errors/http-error';

const app = express();

// ── Middleware ────────────────────────────────────────────────────────────────

app.use(cors({
  origin: [
    CLIENT_URL,
    'http://localhost:3000',
    'http://localhost:5051',
    'http://10.0.2.2:5051',
    // Flutter desktop / mobile dev clients have no fixed web origin,
    // so reflect any origin during development.
    /.*/,
  ],
  credentials: true,
}));

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Serve uploaded images statically
app.use('/uploads', express.static(path.join(__dirname, '..', 'uploads')));

// ── Routes ────────────────────────────────────────────────────────────────────
// All API routes live under /api/v1 — this matches the Flutter client's
// ApiEndpoints.baseUrl (".../api/v1") + endpoint paths ("/auth/login", etc.).

app.use('/api/v1/auth', authRoutes);
app.use('/api/v1/products', productRoutes);
app.use('/api/v1/cart', cartRoutes);
app.use('/api/v1/favourites', favouriteRoutes);
app.use('/api/v1/orders', orderRoutes);
app.use('/api/v1/admin/users', adminRoutes);

// Password-reset web page (served at the root so emailed links are clean:
// http://localhost:5051/reset-password/<token>)
app.use('/', resetWebRoutes);

// Health check
app.get('/health', (_req, res) => {
  res.json({ success: true, message: 'YarnCraft Nepal API is running 🧶' });
});

// 404 handler
app.use((_req, res) => {
  res.status(404).json({ success: false, message: 'Route not found.' });
});

// Global error handler — converts thrown errors (e.g. Multer, HttpError) into JSON.
app.use((err: Error, _req: Request, res: Response, _next: NextFunction) => {
  if (err instanceof HttpError) {
    return res.status(err.statusCode).json({ success: false, message: err.message });
  }
  return res
    .status(500)
    .json({ success: false, message: err.message || 'Internal Server Error' });
});

// ── Start ─────────────────────────────────────────────────────────────────────

async function bootstrap() {
  await connectDatabase();
  app.listen(PORT, () => {
    console.log(` Server running on http://localhost:${PORT}`);
    console.log(` API base:  http://localhost:${PORT}/api/v1`);
  });
}

bootstrap();
