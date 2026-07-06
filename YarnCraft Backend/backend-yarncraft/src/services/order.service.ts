import { OrderRepository } from '../repositories/order.repository';
import { CreateOrderType } from '../types/order.type';
import { HttpError } from '../errors/http-error';

const orderRepository = new OrderRepository();

export class OrderService {
  async createOrder(userId: string, data: CreateOrderType) {
    const count = await orderRepository.count();
    const orderNumber = `YC-${1000 + count + 1}`;

    return await orderRepository.create({
      userId,
      orderNumber,
      items: data.items,
      subtotal: data.subtotal,
      deliveryFee: data.deliveryFee ?? 0,
      total: data.total,
      paymentMethod: data.paymentMethod ?? 'cashOnDelivery',
      status: 'processing',
    });
  }

  async getUserOrders(userId: string) {
    return await orderRepository.getByUserId(userId);
  }

  async markReceived(userId: string, orderId: string) {
    const order = await orderRepository.getById(orderId);
    if (!order || String(order.userId) !== userId) {
      throw new HttpError(404, 'Order not found.');
    }
    if (order.status === 'delivered') return order;
    if (order.status === 'cancelled') {
      throw new HttpError(400, 'Cancelled orders cannot be marked as received.');
    }
    const updated = await orderRepository.updateStatus(orderId, 'delivered');
    if (!updated) throw new HttpError(500, 'Unable to update order.');
    return updated;
  }

  async cancelOrder(userId: string, orderId: string) {
    const order = await orderRepository.getById(orderId);
    if (!order || order.userId !== userId) {
      throw new HttpError(404, 'Order not found.');
    }
    if (order.status === 'delivered') {
      throw new HttpError(400, 'Delivered orders cannot be cancelled.');
    }
    if (order.status === 'cancelled') {
      return order;
    }
    const updated = await orderRepository.updateStatus(orderId, 'cancelled');
    if (!updated) throw new HttpError(500, 'Unable to cancel order.');
    return updated;
  }
}
