import { Request, Response } from 'express';
import { CartService } from '../services/cart.service';
import z from 'zod';
import { CartSchema } from '../types/cart.type';

const cartService = new CartService();

export class CartController {
  async getCart(req: Request, res: Response) {
    try {
      const userId = String(req.user?._id);
      const cart = await cartService.getCartByUserId(userId);
      return res.status(200).json({ success: true, data: cart });
    } catch (error: any) {
      return res.status(error.statusCode ?? 500).json({ success: false, message: error.message || 'Internal Server Error' });
    }
  }

  async updateCart(req: Request, res: Response) {
    try {
      const userId = String(req.user?._id);
      const parsedData = CartSchema.partial().safeParse({ ...req.body, userId });
      if (!parsedData.success) {
        return res.status(400).json({ success: false, message: z.prettifyError(parsedData.error) });
      }
      const cart = await cartService.upsertCart(userId, parsedData.data.items || []);
      return res.status(200).json({ success: true, data: cart, message: 'Cart updated' });
    } catch (error: any) {
      return res.status(error.statusCode ?? 500).json({ success: false, message: error.message || 'Internal Server Error' });
    }
  }
}
