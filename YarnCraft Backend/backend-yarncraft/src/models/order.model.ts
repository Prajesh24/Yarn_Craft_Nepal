import mongoose, { Document, Schema } from 'mongoose';

export type OrderStatus = 'processing' | 'inTransit' | 'delivered' | 'cancelled';

export interface IOrderItem {
  productId: string;
  name: string;
  price: number;
  quantity: number;
  imageUrl?: string;
  color?: string;
  size?: string;
}

export interface IOrder extends Document {
  _id: mongoose.Types.ObjectId;
  userId: string;
  orderNumber: string;
  items: IOrderItem[];
  subtotal: number;
  deliveryFee: number;
  total: number;
  paymentMethod: string;
  status: OrderStatus;
  createdAt: Date;
  updatedAt: Date;
}

const OrderItemSchema = new Schema<IOrderItem>(
  {
    productId: { type: String, required: true },
    name: { type: String, required: true },
    price: { type: Number, required: true },
    quantity: { type: Number, required: true },
    imageUrl: { type: String },
    color: { type: String },
    size: { type: String },
  },
  { _id: false }
);

const OrderSchema: Schema = new Schema<IOrder>(
  {
    userId: { type: String, required: true, index: true },
    orderNumber: { type: String, required: true, unique: true },
    items: { type: [OrderItemSchema], required: true },
    subtotal: { type: Number, required: true },
    deliveryFee: { type: Number, default: 0 },
    total: { type: Number, required: true },
    paymentMethod: { type: String, default: 'cashOnDelivery' },
    status: {
      type: String,
      enum: ['processing', 'inTransit', 'delivered', 'cancelled'],
      default: 'processing',
    },
  },
  { timestamps: true }
);

export const OrderModel = mongoose.model<IOrder>('Order', OrderSchema);
