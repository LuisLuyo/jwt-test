const { Router } = require('express');
const router = Router();

const { getPrueba,listUsuario } = require('../controllers/index.controller');

router.get('/Prueba', getPrueba);
router.get('/listUsuario', listUsuario);

module.exports = router;