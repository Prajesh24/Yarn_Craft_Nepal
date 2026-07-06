import { OrderModel, IOrder } from '../models/order.model';

export class OrderRepository {
  async create(data: Partial<IOrder>): Promise<IOrder> {
    return await OrderModel.create(data);
  }

  async getByUserId(userId: string): Promise<IOrder[]> {
    return await OrderModel.find({ userId }).sort({ createdAt: -1 }).exec();
  }

  async getById(id: string): Promise<IOrder | null> {
    return await OrderModel.findById(id).exec();
  }

  async updateStatus(id: string, status: string): Promise<IOrder | null> {
    return await OrderModel.findByIdAndUpdate(
      id,
      { status },
      { new: true }
    ).exec();
  }

  async count(): Promise<number> {
    return await OrderModel.countDocuments().exec();
  }
}
