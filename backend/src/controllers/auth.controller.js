import { pool } from '../db.js';

export async function login(req, res) {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ message: 'Email y password son obligatorios' });
  }

  try {
    const [rows] = await pool.query('SELECT * FROM usuarios WHERE email = ?', [email]);

    if (!rows.length) {
      return res.status(401).json({ message: 'Credenciales inválidas' });
    }

    const user = rows[0];

    // TODO: reemplazar por comparación con hash bcrypt real
    const passwordMatches = password === user.password_hash;
    if (!passwordMatches) {
      return res.status(401).json({ message: 'Credenciales inválidas' });
    }

    res.json({
      id: user.id_usuario,
      cedula: user.cedula,
      nombre: user.nombre,
      apellido: user.apellido,
      email: user.email,
      fecha_nacimiento: user.fecha_nacimiento,
      especializacion: user.especializacion,
      telefono: user.telefono,
      foto_base64: user.foto_base64,
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
}

