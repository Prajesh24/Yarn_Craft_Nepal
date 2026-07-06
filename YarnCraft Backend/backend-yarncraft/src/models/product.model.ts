import mongoose, { Document, Schema } from 'mongoose';
import { ProductType } from '../types/product.type';

const ProductSchema: Schema = new Schema<ProductType>(
  {
    name: { type: String, required: true },
    description: { type: String },
    location: { type: String, default: 'Nepal' },
    category: { type: String, default: 'Other', index: true },
    price: { type: Number, required: true },
    quantity: { type: Number, required: true },
    imageUrl: { type: String },
    images: { type: [String], default: [] },
    colors: { type: [String], default: [] },
  },
  { timestamps: true }
);

export interface IProduct extends ProductType, Document {
  _id: mongoose.Types.ObjectId;
  createdAt: Date;
  updatedAt: Date;
}

export const ProductModel = mongoose.model<IProduct>('Product', ProductSchema);
