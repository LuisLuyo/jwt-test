const { Router } = require('express');
const router = Router();

const { getPrueba,getUsuario,getToken } = require('../controllers/index.controller');

router.get('/Prueba', getPrueba);
router.get('/getusuario', getUsuario);
router.post('/getToken', getToken);

module.exports = router;