import { Router } from 'express';
import {
  getPacientes,
  getPaciente,
  createPaciente,
  updatePaciente,
  deletePaciente,
} from '../controllers/pacientes.controller.js';

const router = Router();

router.get('/', getPacientes);
router.get('/:cedula', getPaciente);
router.post('/', createPaciente);
router.put('/:cedula', updatePaciente);
router.delete('/:cedula', deletePaciente);

export default router;

