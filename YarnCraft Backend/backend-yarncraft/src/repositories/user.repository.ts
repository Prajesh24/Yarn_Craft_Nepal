import { QueryFilter } from 'mongoose';
import { UserModel, IUser } from '../models/user.model';
import { UpdateUserDTO } from '../dtos/user.dto';

export class UserRepository {
  async createUser(data: Partial<IUser>): Promise<IUser> {
    return await UserModel.create(data);
  }

  async getUserByEmail(email: string): Promise<IUser | null> {
    // Use .select('+password') so the password is included for auth checks
    return await UserModel.findOne({ email }).select('+password').exec();
  }

  async getUserById(id: string): Promise<IUser | null> {
    return await UserModel.findById(id).exec();
  }

  async getUserByEmailOrPhone(emailOrPhone: string): Promise<IUser | null> {
    return await UserModel.findOne({ email: emailOrPhone })
      .select('+password')
      .exec();
  }

  async updateUser(id: string, data: UpdateUserDTO): Promise<IUser | null> {
    return await UserModel.findByIdAndUpdate(id, data, { new: true }).exec();
  }

  async updatePasswordByEmail(
    email: string,
    hashedPassword: string
  ): Promise<IUser | null> {
    return await UserModel.findOneAndUpdate(
      { email },
      { password: hashedPassword },
      { new: true }
    ).exec();
  }

  // ── Admin: paginated + searchable user listing ──────────────────────────────
  async getAllUsers(
    page: number,
    size: number,
    search?: string
  ): Promise<{ users: IUser[]; total: number }> {
    const filter: QueryFilter<IUser> = {};
    if (search) {
      filter.$or = [
        { name:  { $regex: search, $options: 'i' } },
        { email: { $regex: search, $options: 'i' } },
      ];
    }

    const [users, total] = await Promise.all([
      UserModel.find(filter)
        .skip((page - 1) * size)
        .limit(size)
        .exec(),
      UserModel.countDocuments(filter),
    ]);

    return { users, total };
  }

  // ── Admin: delete a user ────────────────────────────────────────────────────
  async deleteUser(id: string): Promise<boolean> {
    const result = await UserModel.findByIdAndDelete(id).exec();
    return result !== null;
  }
}