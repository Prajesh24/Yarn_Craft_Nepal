import { CartModel, ICart } from '../models/cart.model';

export class CartRepository {
  async getCartByUserId(userId: string): Promise<ICart | null> {
    return await CartModel.findOne({ userId }).exec();
  }

  async createCart(data: any): Promise<ICart> {
    return await CartModel.create(data);
  }

  async updateCart(id: string, data: any): Promise<ICart | null> {
    return await CartModel.findByIdAndUpdate(id, data, { new: true }).exec();
  }
}
