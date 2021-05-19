import fs from 'fs';
import express, { Application } from 'express';
import './utils/config';
import indexRoutes from './routes/index';
import cors from 'cors';
import http from 'https';
import https from 'https';
const app: Application = express();

// Certificate
const privateKey = fs.readFileSync('/etc/letsencrypt/live/frances1720.com/privkey.pem', 'utf8');
const certificate = fs.readFileSync('/etc/letsencrypt/live/frances1720.com/cert.pem', 'utf8');
const ca = fs.readFileSync('/etc/letsencrypt/live/frances1720.com/chain.pem', 'utf8');

const credentials = {
	key: privateKey,
	cert: certificate,
	ca: ca
};

// middlewares
app.use(express.json());
app.use(express.urlencoded({extended: false}));
app.use(cors({
    exposedHeaders: ['jwt'],
  }));
// Routes
app.use(indexRoutes);

export const httpServer = http.createServer(app);
export const httpsServer = https.createServer(credentials, app);