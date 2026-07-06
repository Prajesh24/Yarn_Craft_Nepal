import { Request, Response, NextFunction } from 'express';
import z from 'zod';

import { CreateUserDTO, UpdateUserDTO } from '../../dtos/user.dto';
import { AdminUserService } from '../../services/admin/admin.service';
import { QueryParams } from '../../types/query.type';

const adminUserService = new AdminUserService();

export class AdminUserController {
  async createUser(req: Request, res: Response, _next: NextFunction) {
    try {
      const parsedData = CreateUserDTO.safeParse(req.body);
      if (!parsedData.success) {
        return res.status(400).json({ success: false, message: z.prettifyError(parsedData.error) });
      }
      if (req.file) {
        parsedData.data.imageUrl = `/uploads/${req.file.filename}`;
      }
      const newUser = await adminUserService.createUser(parsedData.data);
      return res.status(201).json({ success: true, message: 'User Created', data: newUser });
    } catch (error: any) {
      return res.status(error.statusCode ?? 500).json({ success: false, message: error.message || 'Internal Server Error' });
    }
  }

  async getAllUsers(req: Request, res: Response, _next: NextFunction) {
    try {
      const { page, size, search }: QueryParams = req.query;
      const { users, pagination } = await adminUserService.getAllUsers(page, size, search);
      return res.status(200).json({ success: true, data: users, pagination, message: 'All Users Retrieved' });
    } catch (error: any) {
      return res.status(error.statusCode ?? 500).json({ success: false, message: error.message || 'Internal Server Error' });
    }
  }

  async getUserById(req: Request<{ id: string }>, res: Response, _next: NextFunction) {
    try {
      const user = await adminUserService.getUserById(req.params.id);
      return res.status(200).json({ success: true, data: user, message: 'Single User Retrieved' });
    } catch (error: any) {
      return res.status(error.statusCode ?? 500).json({ success: false, message: error.message || 'Internal Server Error' });
    }
  }

  async updateUser(req: Request<{ id: string }>, res: Response, _next: NextFunction) {
    try {
      const parsedData = UpdateUserDTO.safeParse(req.body);
      if (!parsedData.success) {
        return res.status(400).json({ success: false, message: z.prettifyError(parsedData.error) });
      }
      if (req.file) {
        parsedData.data.imageUrl = `/uploads/${req.file.filename}`;
      }
      const updatedUser = await adminUserService.updateUser(req.params.id, parsedData.data);
      return res.status(200).json({ success: true, message: 'User Updated', data: updatedUser });
    } catch (error: any) {
      return res.status(error.statusCode ?? 500).json({ success: false, message: error.message || 'Internal Server Error' });
    }
  }

  async deleteUser(req: Request<{ id: string }>, res: Response, _next: NextFunction) {
    try {
      const deleted = await adminUserService.deleteUser(req.params.id);
      if (!deleted) {
        return res.status(404).json({ success: false, message: 'User not found' });
      }
      return res.status(200).json({ success: true, message: 'User Deleted' });
    } catch (error: any) {
      return res.status(error.statusCode ?? 500).json({ success: false, message: error.message || 'Internal Server Error' });
    }
  }
}
