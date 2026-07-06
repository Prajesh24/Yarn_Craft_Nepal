import express, { Application, Request, Response } from 'express';
import bodyParser from 'body-parser';
import cors from 'cors';
import path from 'path';
import { connectDatabase } from './database/mongodb';
import { PORT } from './config';
import authRoutes from './routes/auth.route';
import adminRoutes from './routes/admin/admin.route';
import productRoutes from './routes/product.route';
import cartRoutes from './routes/cart.route';
import { HttpError } from './errors/http-error';

const app: Application = express();

const corsOptions = {
  origin: ['http://localhost:3000', 'http://localhost:3003', 'http://localhost:3005'],
  optionsSuccessStatus: 200,
  credentials: true,
};

app.use(cors(corsOptions));
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));
app.use('/uploads', express.static(path.join(__dirname, '../uploads')));

app.use('/api/auth', authRoutes);
app.use('/api/admin/users', adminRoutes);
app.use('/api/products', productRoutes);
app.use('/api/cart', cartRoutes);

app.get('/', (req: Request, res: Response) => {
  return res.status(200).json({ success: true, message: 'Welcome to YarnCraft API' });
});

app.use((err: Error, req: Request, res: Response, next: Function) => {
  if (err instanceof HttpError) {
    return res.status(err.statusCode).json({ success: false, message: err.message });
  }
  return res.status(500).json({ success: false, message: err.message || 'Internal Server Error' });
});

export default app;
