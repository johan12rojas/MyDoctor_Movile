import { pool } from '../db.js';

const baseQuery = `
  SELECT pg.*, c.numero_cita, p.nombre, p.apellido
  FROM pagos pg
  LEFT JOIN citas c ON c.id_cita = pg.id_cita
  LEFT JOIN pacientes p ON p.cedula = pg.cedula
`;

export async function getPagos(_, res) {
  try {
    const [rows] = await pool.query(baseQuery);
    res.json(rows);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
}

export async function getPago(req, res) {
  try {
    const [rows] = await pool.query(`${baseQuery} WHERE pg.id_pago = ?`, [req.params.id]);
    if (!rows.length) return res.status(404).json({ message: 'Pago no encontrado' });
    res.json(rows[0]);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
}

export async function createPago(req, res) {
  try {
    await pool.query(
      `INSERT INTO pagos (
        id_cita, cedula, valor_total, metodo_pago, entidad, fecha_pago
      ) VALUES (?, ?, ?, ?, ?, ?)`,
      [
        req.body.id_cita,
        req.body.cedula,
        req.body.valor_total,
        req.body.metodo_pago,
        req.body.entidad,
        req.body.fecha_pago,
      ],
    );

    await pool.query(
      `UPDATE pacientes
       SET estado_pago = 'Pagado', metodo_pago = ?, fecha_pago = ?
       WHERE cedula = ?`,
      [req.body.metodo_pago, req.body.fecha_pago, req.body.cedula],
    );

    res.status(201).json({ message: 'Pago registrado' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
}

export async function updatePago(req, res) {
  try {
    const [result] = await pool.query('UPDATE pagos SET ? WHERE id_pago = ?', [
      req.body,
      req.params.id,
    ]);
    if (!result.affectedRows) return res.status(404).json({ message: 'Pago no encontrado' });
    res.json({ message: 'Pago actualizado' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
}

export async function deletePago(req, res) {
  try {
    const [result] = await pool.query('DELETE FROM pagos WHERE id_pago = ?', [req.params.id]);
    if (!result.affectedRows) return res.status(404).json({ message: 'Pago no encontrado' });
    res.json({ message: 'Pago eliminado' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
}

