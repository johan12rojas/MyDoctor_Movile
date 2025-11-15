import { Router } from 'express';
import {
  getPagos,
  getPago,
  createPago,
  updatePago,
  deletePago,
} from '../controllers/pagos.controller.js';

const router = Router();

router.get('/', getPagos);
router.get('/:id', getPago);
router.post('/', createPago);
router.put('/:id', updatePago);
router.delete('/:id', deletePago);

export default router;

