import { Router } from 'express';
import { getEntidadesEps, getProcedimientos } from '../controllers/catalogos.controller.js';

const router = Router();

router.get('/eps', getEntidadesEps);
router.get('/procedimientos', getProcedimientos);

export default router;

