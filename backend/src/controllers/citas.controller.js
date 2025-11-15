import { pool } from '../db.js';

const baseQuery = `
  SELECT c.*,
         p.nombre AS nombre_paciente,
         p.apellido AS apellido_paciente,
         CONCAT(p.nombre, ' ', p.apellido) AS paciente,
         p.telefono,
         p.correo
  FROM citas c
  JOIN pacientes p ON p.cedula = c.cedula
`;

async function getNextNumeroCita() {
  const [[row]] = await pool.query(
    `SELECT LPAD(IFNULL(MAX(CAST(numero_cita AS UNSIGNED)), 0) + 1, 1, '0') AS numero`,
  );
  return row?.numero ?? '1';
}

export async function getCitas(_, res) {
  try {
    const [rows] = await pool.query(baseQuery);
    res.json(rows);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
}

export async function getCita(req, res) {
  try {
    const [rows] = await pool.query(`${baseQuery} WHERE c.id_cita = ?`, [req.params.id]);
    if (!rows.length) return res.status(404).json({ message: 'Cita no encontrada' });
    res.json(rows[0]);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
}

export async function createCita(req, res) {
  try {
    const numeroCita = req.body.numero_cita ?? (await getNextNumeroCita());
    const fechaRegistro =
        req.body.fecha_registro ?? new Date().toISOString().slice(0, 19).replace('T', ' ');

    await pool.query(
      `INSERT INTO citas (
        numero_cita, cedula, fecha_cita, hora, observaciones,
        tipo_cita, estado, fecha_registro
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        numeroCita,
        req.body.cedula,
        req.body.fecha_cita,
        req.body.hora,
        req.body.observaciones,
        req.body.tipo_cita,
        req.body.estado,
        fechaRegistro,
      ],
    );
    res.status(201).json({ message: 'Cita creada', numero_cita: numeroCita });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
}

export async function getNextNumeroCitaController(_, res) {
  try {
    const numero = await getNextNumeroCita();
    res.json({ numero });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
}

export async function updateCita(req, res) {
  try {
    const [result] = await pool.query('UPDATE citas SET ? WHERE id_cita = ?', [
      req.body,
      req.params.id,
    ]);
    if (!result.affectedRows) return res.status(404).json({ message: 'Cita no encontrada' });
    res.json({ message: 'Cita actualizada' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
}

export async function deleteCita(req, res) {
  try {
    const [result] = await pool.query('DELETE FROM citas WHERE id_cita = ?', [req.params.id]);
    if (!result.affectedRows) return res.status(404).json({ message: 'Cita no encontrada' });
    res.json({ message: 'Cita eliminada' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
}

