import z from 'zod';

// Matches Flutter AuthApiModel: name, email, password, imageUrl, role
export const UserSchema = z.object({
  name:     z.string().min(2, 'Name must be at least 2 characters'),
  email:    z.string().email('Invalid email address'),
  password: z.string().min(6, 'Password must be at least 6 characters'),
  imageUrl: z.string().optional(),
  role:     z.enum(['user', 'admin']).default('user'),
});

export type UserType = z.infer<typeof UserSchema>;