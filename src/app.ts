import express, { Application } from 'express';
import './utils/config';
import indexRoutes from './routes/index';
import cors from 'cors';

const app: Application = express();

// middlewares
app.use(express.json());
app.use(express.urlencoded({extended: false}));
app.use(cors({
    exposedHeaders: ['jwt'],
  }));
// Routes
app.use(indexRoutes);

export default app;