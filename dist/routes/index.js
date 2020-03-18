"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const router = express_1.Router();
const index_controller_1 = require("../controllers/index.controller");
router.get('/api/Prueba', index_controller_1.getPrueba);
router.post('/api/arquitectura/global/generateToken', index_controller_1.generateToken);
router.post('/api/arquitectura/global/validateToken', index_controller_1.verifyToken, index_controller_1.validateToken);
exports.default = router;
