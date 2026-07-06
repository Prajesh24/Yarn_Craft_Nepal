import mongoose, { Document, Schema } from 'mongoose';
import { UserType } from '../types/user.type';

const userSchema: Schema = new Schema<UserType>(
  {
    name:     { type: String, required: true, trim: true },
    email:    { type: String, required: true, unique: true, lowercase: true, trim: true },
    password: { type: String, required: true },
    imageUrl: { type: String, default: null },
    role:     { type: String, enum: ['user', 'admin'], default: 'user' },
  },
  { timestamps: true }
);

// Never return the password in JSON responses
userSchema.set('toJSON', {
  transform: (_doc, ret) => {
    delete ret.password;
    return ret;
  },
});

export interface IUser extends UserType, Document {
  _id:       mongoose.Types.ObjectId;
  createdAt: Date;
  updatedAt: Date;
}

export const UserModel = mongoose.model<IUser>('User', userSchema);