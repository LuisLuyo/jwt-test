import { Router } from 'express';
const router = Router();

import { getPrueba, generateToken, validateToken, verifyToken } from '../controllers/index.controller';

router.get('/api/Prueba', getPrueba);
router.post('/api/arquitectura/global/generateToken', generateToken);
router.post('/api/arquitectura/global/validateToken', verifyToken, validateToken);

export default router;