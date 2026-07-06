import { Router } from 'express';
import { CartController } from '../controllers/cart.controller';
import { authorizedMiddleware } from '../middlewears/authorized.middlewear';

const router = Router();
const cartController = new CartController();

router.get('/', authorizedMiddleware, cartController.getCart);
router.put('/', authorizedMiddleware, cartController.updateCart);

export default router;
