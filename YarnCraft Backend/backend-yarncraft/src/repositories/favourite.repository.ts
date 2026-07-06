import { FavouriteModel, IFavourite } from '../models/favourite.model';

export class FavouriteRepository {
  async getByUserId(userId: string): Promise<IFavourite | null> {
    return await FavouriteModel.findOne({ userId }).exec();
  }

  async create(data: { userId: string; productIds: string[] }): Promise<IFavourite> {
    return await FavouriteModel.create(data);
  }

  async update(id: string, data: { productIds: string[] }): Promise<IFavourite | null> {
    return await FavouriteModel.findByIdAndUpdate(id, data, { new: true }).exec();
  }
}
