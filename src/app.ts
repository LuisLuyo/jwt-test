import express, { Application } from 'express';
import './utils/config';
import indexRoutes from './routes/index';

const app: Application = express();

// middlewares
app.use(express.json());
app.use(express.urlencoded({extended: false}));

// Routes
app.use(indexRoutes);

export default app;