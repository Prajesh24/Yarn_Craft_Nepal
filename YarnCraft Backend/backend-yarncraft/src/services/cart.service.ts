import { CartRepository } from '../repositories/cart.repository';
import { HttpError } from '../errors/http-error';

const cartRepository = new CartRepository();

export class CartService {
  async getCartByUserId(userId: string) {
    let cart = await cartRepository.getCartByUserId(userId);
    if (!cart) {
      cart = await cartRepository.createCart({ userId, items: [] });
    }
    return cart;
  }

  async upsertCart(userId: string, items: any[]) {
    const existingCart = await cartRepository.getCartByUserId(userId);
    if (existingCart) {
      const updatedCart = await cartRepository.updateCart(existingCart._id.toString(), { items });
      if (!updatedCart) {
        throw new HttpError(500, 'Unable to update cart');
      }
      return updatedCart;
    }
    return await cartRepository.createCart({ userId, items });
  }
}
