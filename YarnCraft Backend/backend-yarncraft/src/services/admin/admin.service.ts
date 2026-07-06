import bcryptjs from 'bcryptjs';

import { CreateUserDTO, UpdateUserDTO } from '../../dtos/user.dto';
import { UserRepository } from '../../repositories/user.repository';
import { HttpError } from '../../errors/http-error';

const userRepository = new UserRepository();

export class AdminUserService {
  async createUser(data: CreateUserDTO) {
    const existing = await userRepository.getUserByEmail(data.email);
    if (existing) {
      throw new HttpError(403, 'Email already in use');
    }

    const hashedPassword = await bcryptjs.hash(data.password, 12);

    const newUser = await userRepository.createUser({
      name:     data.name,
      email:    data.email,
      password: hashedPassword,
      imageUrl: data.imageUrl ?? undefined,
      role:     data.role ?? 'user',
    });

    return newUser;
  }

  async getAllUsers(page?: string, size?: string, search?: string) {
    const pageNumber = page ? parseInt(page) : 1;
    const pageSize   = size ? parseInt(size) : 10;

    const { users, total } = await userRepository.getAllUsers(
      pageNumber,
      pageSize,
      search
    );

    const pagination = {
      page:       pageNumber,
      size:       pageSize,
      totalItems: total,
      totalPages: Math.ceil(total / pageSize),
    };

    return { users, pagination };
  }

  async getUserById(id: string) {
    const user = await userRepository.getUserById(id);
    if (!user) {
      throw new HttpError(404, 'User not found');
    }
    return user;
  }

  async updateUser(id: string, updateData: UpdateUserDTO) {
    const user = await userRepository.getUserById(id);
    if (!user) {
      throw new HttpError(404, 'User not found');
    }

    if (updateData.password) {
      updateData.password = await bcryptjs.hash(updateData.password, 12);
    }

    return await userRepository.updateUser(id, updateData);
  }

  async deleteUser(id: string) {
    const user = await userRepository.getUserById(id);
    if (!user) {
      throw new HttpError(404, 'User not found');
    }
    return await userRepository.deleteUser(id);
  }
}
