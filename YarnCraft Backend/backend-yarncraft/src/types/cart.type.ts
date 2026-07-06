import z from 'zod';

export const CartItemSchema = z.object({
  productId: z.string().min(1),
  quantity: z.number().int().min(1),
});

export type CartItemType = z.infer<typeof CartItemSchema>;

export const CartSchema = z.object({
  userId: z.string().min(1),
  items: z.array(CartItemSchema),
});

export type CartType = z.infer<typeof CartSchema>;
