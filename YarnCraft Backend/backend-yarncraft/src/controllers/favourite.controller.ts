import { Request, Response } from 'express';
import z from 'zod';
import { FavouriteService } from '../services/favourite.service';

const favouriteService = new FavouriteService();

const UpdateFavouritesSchema = z.object({
  productIds: z.array(z.string().min(1)),
});

export class FavouriteController {
  async getFavourites(req: Request, res: Response) {
    try {
      const userId = String(req.user?._id);
      const favourite = await favouriteService.getByUserId(userId);
      return res.status(200).json({ success: true, data: favourite });
    } catch (error: any) {
      return res
        .status(error.statusCode ?? 500)
        .json({ success: false, message: error.message || 'Internal Server Error' });
    }
  }

  async updateFavourites(req: Request, res: Response) {
    try {
      const userId = String(req.user?._id);
      const parsed = UpdateFavouritesSchema.safeParse(req.body);
      if (!parsed.success) {
        return res
          .status(400)
          .json({ success: false, message: z.prettifyError(parsed.error) });
      }
      const favourite = await favouriteService.upsert(userId, parsed.data.productIds);
      return res
        .status(200)
        .json({ success: true, data: favourite, message: 'Favourites updated' });
    } catch (error: any) {
      return res
        .status(error.statusCode ?? 500)
        .json({ success: false, message: error.message || 'Internal Server Error' });
    }
  }
}
