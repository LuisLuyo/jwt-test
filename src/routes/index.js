const { Router } = require('express');
const router = Router();

const { getPrueba, generateToken, validateToken, verifyToken } = require('../controllers/index.controller');

router.get('/api/Prueba', getPrueba);
router.post('/api/arquitectura/global/generateToken', generateToken);
router.post('/api/arquitectura/global/validateToken', verifyToken, validateToken);

module.exports = router;