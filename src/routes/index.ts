import { Router } from 'express';
const router = Router();

import { generateToken, validateToken, verifyToken } from '../controllers/index.controller';

router.post('/api/arquitectura/token/generateToken', generateToken);
router.post('/api/arquitectura/token/validateToken', verifyToken, validateToken);

export default router;