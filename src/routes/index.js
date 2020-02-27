const { Router } = require('express');
const router = Router();

const { getPrueba } = require('../controllers/index.controller');

router.get('/Prueba', getPrueba);

module.exports = router;