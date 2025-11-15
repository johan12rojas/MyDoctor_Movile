import express from 'express';
import cors from 'cors';
import 'dotenv/config';

import authRoutes from './routes/auth.routes.js';
import pacientesRoutes from './routes/pacientes.routes.js';
import citasRoutes from './routes/citas.routes.js';
import pagosRoutes from './routes/pagos.routes.js';
import usersRoutes from './routes/users.routes.js';
import catalogosRoutes from './routes/catalogos.routes.js';

const app = express();

app.use(cors());
app.use(express.json());

app.use('/api/auth', authRoutes);
app.use('/api/pacientes', pacientesRoutes);
app.use('/api/citas', citasRoutes);
app.use('/api/pagos', pagosRoutes);
app.use('/api/users', usersRoutes);
app.use('/api/catalogos', catalogosRoutes);

app.get('/', (_, res) => res.json({ status: 'API running' }));

const port = process.env.API_PORT || process.env.PORT || 3000;
app.listen(port, () => {
  console.log(`Servidor listo en http://localhost:${port}`);
});

