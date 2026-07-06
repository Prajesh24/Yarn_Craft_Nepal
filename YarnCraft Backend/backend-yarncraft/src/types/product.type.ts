import z from 'zod';

export const ProductSchema = z.object({
  name: z.string().min(2),
  description: z.string().optional(),
  location: z.string().optional(),
  category: z.string().optional(),
  price: z.number().nonnegative(),
  quantity: z.number().int().nonnegative(),
  imageUrl: z.string().optional(),
  images: z.array(z.string()).optional(),
  colors: z.array(z.string()).optional(),
});

export type ProductType = z.infer<typeof ProductSchema>;
