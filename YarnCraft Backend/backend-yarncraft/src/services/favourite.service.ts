import { FavouriteRepository } from '../repositories/favourite.repository';
import { HttpError } from '../errors/http-error';

const favouriteRepository = new FavouriteRepository();

export class FavouriteService {
  async getByUserId(userId: string) {
    let favourite = await favouriteRepository.getByUserId(userId);
    if (!favourite) {
      favourite = await favouriteRepository.create({ userId, productIds: [] });
    }
    return favourite;
  }

  async upsert(userId: string, productIds: string[]) {
    // De-duplicate while preserving order.
    const unique = Array.from(new Set(productIds));

    const existing = await favouriteRepository.getByUserId(userId);
    if (existing) {
      const updated = await favouriteRepository.update(existing._id.toString(), {
        productIds: unique,
      });
      if (!updated) {
        throw new HttpError(500, 'Unable to update favourites');
      }
      return updated;
    }
    return await favouriteRepository.create({ userId, productIds: unique });
  }
}
