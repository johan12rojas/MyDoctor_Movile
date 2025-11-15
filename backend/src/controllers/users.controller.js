import { pool } from '../db.js';

export async function createUser(req, res) {
  const {
    cedula,
    nombre,
    apellido,
    email,
    fecha_nacimiento,
    especializacion,
    telefono,
    password,
    foto_base64,
  } = req.body;

  try {
    await pool.query(
      `INSERT INTO usuarios
        (cedula, nombre, apellido, email, fecha_nacimiento, especializacion, telefono, password_hash, foto_base64)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        cedula,
        nombre,
        apellido,
        email,
        fecha_nacimiento,
        especializacion,
        telefono,
        password,
        foto_base64 ?? null,
      ],
    );

    res.status(201).json({ message: 'Usuario creado correctamente' });
  } catch (error) {
    if (error.code === 'ER_DUP_ENTRY') {
      return res.status(409).json({ message: 'El usuario ya existe' });
    }
    res.status(500).json({ message: error.message });
  }
}

export async function updateUser(req, res) {
  const { cedula } = req.params;

  try {
    const [result] = await pool.query(
      `UPDATE usuarios
       SET nombre = ?, apellido = ?, email = ?, fecha_nacimiento = ?, especializacion = ?, telefono = ?, password_hash = ?, foto_base64 = ?
       WHERE cedula = ?`,
      [
        req.body.nombre,
        req.body.apellido,
        req.body.email,
        req.body.fecha_nacimiento,
        req.body.especializacion,
        req.body.telefono,
        req.body.password,
        req.body.foto_base64 ?? null,
        cedula,
      ],
    );

    if (!result.affectedRows) {
      return res.status(404).json({ message: 'Usuario no encontrado' });
    }

    res.json({ message: 'Usuario actualizado correctamente' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
}

export async function getUsers(_, res) {
  try {
    const [rows] = await pool.query('SELECT * FROM usuarios');
    res.json(rows);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
}

