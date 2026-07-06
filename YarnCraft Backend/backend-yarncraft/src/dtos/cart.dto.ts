import z from 'zod';
import { CartSchema } from '../types/cart.type';

export const UpdateCartDTO = CartSchema.partial();
export type UpdateCartDTO = z.infer<typeof UpdateCartDTO>;
