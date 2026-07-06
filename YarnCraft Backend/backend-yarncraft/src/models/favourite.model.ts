import mongoose, { Document, Schema } from 'mongoose';

export interface IFavourite extends Document {
  _id: mongoose.Types.ObjectId;
  userId: string;
  productIds: string[];
  createdAt: Date;
  updatedAt: Date;
}

const FavouriteSchema: Schema = new Schema<IFavourite>(
  {
    userId: { type: String, required: true, unique: true, index: true },
    productIds: [{ type: String }],
  },
  { timestamps: true }
);

export const FavouriteModel = mongoose.model<IFavourite>(
  'Favourite',
  FavouriteSchema
);
