import mongoose, { Document, Schema } from 'mongoose';
import { CartType } from '../types/cart.type';

const CartSchema: Schema = new Schema<CartType>(
  {
    userId: { type: String, required: true },
    items: [
      {
        productId: { type: String, required: true },
        quantity: { type: Number, required: true },
      },
    ],
  },
  {
    timestamps: true,
  }
);

export interface ICart extends CartType, Document {
  _id: mongoose.Types.ObjectId;
  createdAt: Date;
  updatedAt: Date;
}

export const CartModel = mongoose.model<ICart>('Cart', CartSchema);
