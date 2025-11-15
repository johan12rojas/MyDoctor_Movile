import { Router } from 'express';
import { createUser, getUsers, updateUser } from '../controllers/users.controller.js';

const router = Router();

router.get('/', getUsers);
router.post('/', createUser);
router.put('/:cedula', updateUser);

export default router;

