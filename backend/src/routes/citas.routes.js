import { Router } from 'express';
import {
  getCitas,
  getCita,
  createCita,
  updateCita,
  deleteCita,
  getNextNumeroCitaController,
} from '../controllers/citas.controller.js';

const router = Router();

router.get('/', getCitas);
router.get('/next/numero', getNextNumeroCitaController);
router.get('/:id', getCita);
router.post('/', createCita);
router.put('/:id', updateCita);
router.delete('/:id', deleteCita);

export default router;

