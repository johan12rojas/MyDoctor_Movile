import { pool } from '../db.js';

export async function getPacientes(_, res) {
  try {
    const [rows] = await pool.query('SELECT * FROM pacientes');
    res.json(rows);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
}

export async function getPaciente(req, res) {
  try {
    const [rows] = await pool.query('SELECT * FROM pacientes WHERE cedula = ?', [
      req.params.cedula,
    ]);
    if (!rows.length) return res.status(404).json({ message: 'Paciente no encontrado' });
    res.json(rows[0]);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
}

export async function createPaciente(req, res) {
  try {
    await pool.query('INSERT INTO pacientes SET ?', [req.body]);
    res.status(201).json({ message: 'Paciente creado' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
}

export async function updatePaciente(req, res) {
  try {
    const [result] = await pool.query('UPDATE pacientes SET ? WHERE cedula = ?', [
      req.body,
      req.params.cedula,
    ]);
    if (!result.affectedRows) {
      return res.status(404).json({ message: 'Paciente no encontrado' });
    }
    res.json({ message: 'Paciente actualizado' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
}

export async function deletePaciente(req, res) {
  try {
    const [result] = await pool.query('DELETE FROM pacientes WHERE cedula = ?', [
      req.params.cedula,
    ]);
    if (!result.affectedRows) {
      return res.status(404).json({ message: 'Paciente no encontrado' });
    }
    res.json({ message: 'Paciente eliminado' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
}

