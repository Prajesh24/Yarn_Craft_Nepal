import z from 'zod';

export const OrderItemSchema = z.object({
  productId: z.string().min(1),
  name: z.string().min(1),
  price: z.number().nonnegative(),
  quantity: z.number().int().min(1),
  imageUrl: z.string().optional(),
  color: z.string().optional(),
  size: z.string().optional(),
});

export const CreateOrderSchema = z.object({
  items: z.array(OrderItemSchema).min(1, 'Order must contain at least one item'),
  subtotal: z.number().nonnegative(),
  deliveryFee: z.number().nonnegative().default(0),
  total: z.number().nonnegative(),
  paymentMethod: z.string().optional(),
});

export type CreateOrderType = z.infer<typeof CreateOrderSchema>;
