import { pool } from '../db.js';

export async function getEntidadesEps(_, res) {
  try {
    const [rows] = await pool.query(
      'SELECT id_eps AS id, nombre, tipo FROM entidades_eps ORDER BY nombre',
    );
    res.json(rows);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
}

export async function getProcedimientos(_, res) {
  try {
    const [rows] = await pool.query(
      'SELECT id_procedimiento AS id, nombre, descripcion FROM procedimientos ORDER BY nombre',
    );
    res.json(rows);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
}

