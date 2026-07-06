import { Request, Response } from 'express';
import z from 'zod';
import { OrderService } from '../services/order.service';
import { CreateOrderSchema } from '../types/order.type';

const orderService = new OrderService();

export class OrderController {
  async createOrder(req: Request, res: Response) {
    try {
      const userId = String(req.user?._id);
      const parsed = CreateOrderSchema.safeParse(req.body);
      if (!parsed.success) {
        return res
          .status(400)
          .json({ success: false, message: z.prettifyError(parsed.error) });
      }
      const order = await orderService.createOrder(userId, parsed.data);
      return res
        .status(201)
        .json({ success: true, data: order, message: 'Order placed' });
    } catch (error: any) {
      return res
        .status(error.statusCode ?? 500)
        .json({ success: false, message: error.message || 'Internal Server Error' });
    }
  }

  async getMyOrders(req: Request, res: Response) {
    try {
      const userId = String(req.user?._id);
      const orders = await orderService.getUserOrders(userId);
      return res.status(200).json({ success: true, data: orders });
    } catch (error: any) {
      return res
        .status(error.statusCode ?? 500)
        .json({ success: false, message: error.message || 'Internal Server Error' });
    }
  }

  async markReceived(req: Request<{ id: string }>, res: Response) {
    try {
      const userId = String(req.user?._id);
      const order = await orderService.markReceived(userId, req.params.id);
      return res
        .status(200)
        .json({ success: true, data: order, message: 'Order marked as received' });
    } catch (error: any) {
      return res
        .status(error.statusCode ?? 500)
        .json({ success: false, message: error.message || 'Internal Server Error' });
    }
  }

  async cancelOrder(req: Request<{ id: string }>, res: Response) {
    try {
      const userId = String(req.user?._id);
      const order = await orderService.cancelOrder(userId, req.params.id);
      return res
        .status(200)
        .json({ success: true, data: order, message: 'Order cancelled' });
    } catch (error: any) {
      return res
        .status(error.statusCode ?? 500)
        .json({ success: false, message: error.message || 'Internal Server Error' });
    }
  }
}
