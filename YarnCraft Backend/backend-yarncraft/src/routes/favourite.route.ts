import { Router } from 'express';
import { FavouriteController } from '../controllers/favourite.controller';
import { authorizedMiddleware } from '../middlewears/authorized.middlewear';

const router = Router();
const favouriteController = new FavouriteController();

router.get('/', authorizedMiddleware, favouriteController.getFavourites);
router.put('/', authorizedMiddleware, favouriteController.updateFavourites);

export default router;
