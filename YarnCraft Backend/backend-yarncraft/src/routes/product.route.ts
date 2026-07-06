import { Router } from 'express';
import { ProductController } from '../controllers/product.controller';
import { authorizedMiddleware, adminMiddleware } from '../middlewears/authorized.middlewear';
import { uploads } from '../middlewears/upload.middlewear';

const router = Router();
const productController = new ProductController();

// Public — anyone can browse products
router.get('/', productController.getProducts);
router.get('/:id', productController.getProductById);

// Admin only — create / update / delete
router.post(
  '/',
  authorizedMiddleware,
  adminMiddleware,
  uploads.single('imageUrl'),
  productController.createProduct,
);
router.put(
  '/:id',
  authorizedMiddleware,
  adminMiddleware,
  uploads.single('imageUrl'),
  productController.updateProduct,
);
router.delete(
  '/:id',
  authorizedMiddleware,
  adminMiddleware,
  productController.deleteProduct,
);

export default router;
