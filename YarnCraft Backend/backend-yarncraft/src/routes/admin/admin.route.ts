import { Router } from 'express';

import { AdminUserController } from '../../controllers/admin/admin.controller';
import { authorizedMiddleware, adminMiddleware } from '../../middlewears/authorized.middlewear';
import { uploads } from '../../middlewears/upload.middlewear';

const router = Router();
const adminUserController = new AdminUserController();

// All admin routes require a valid token AND an admin role
router.use(authorizedMiddleware);
router.use(adminMiddleware);

router.post('/',    uploads.single('imageUrl'), adminUserController.createUser);
router.get('/',     adminUserController.getAllUsers);
router.get('/:id',  adminUserController.getUserById);
router.put('/:id',  uploads.single('imageUrl'), adminUserController.updateUser);
router.delete('/:id', adminUserController.deleteUser);

export default router;
