import { Router } from 'express';
import { OrderController } from '../controllers/order.controller';
import { authorizedMiddleware } from '../middlewears/authorized.middlewear';

const router = Router();
const orderController = new OrderController();

router.use(authorizedMiddleware);

router.post('/', orderController.createOrder);
router.get('/', orderController.getMyOrders);
router.patch('/:id/cancel', orderController.cancelOrder);
router.patch('/:id/received', orderController.markReceived);

export default router;
