"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const database_1 = require("../database");
const jsonwebtoken_1 = __importDefault(require("jsonwebtoken"));
exports.getPrueba = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        return res.status(200).json({ text: 'api works!' });
    }
    catch (e) {
        console.log(e);
        return res.status(500).json('Internal Server error');
    }
});
exports.generateToken = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const { usuario, clave } = req.body;
        const response = yield database_1.pool.query('SELECT usuario, estado FROM SIGV_SEGURIDAD.USUARIO WHERE USUARIO = $1 AND CLAVE = $2;', [usuario, clave]);
        const rows = response.rows;
        if (!isEmptyObject(response.rows)) {
            console.log(response.rows);
            const token = jsonwebtoken_1.default.sign({ response }, process.env['TOKEN_KEY'] || '', { expiresIn: process.env['TOKEN_EXP'] });
            res.status(200);
            res.setHeader('jwt', token);
            return res.json({
                message: 'Token generated successfully!',
                body: { usuario: response.rows }
            });
        }
        else {
            return res.status(401).json({
                message: 'Error en usuario/contraseña, volver a intentar, falso!',
                body: {}
            });
        }
    }
    catch (e) {
        console.log(e);
        return res.status(500).json('Internal Server error');
    }
});
exports.validateToken = (req, res) => {
    jsonwebtoken_1.default.verify(req.params.token, process.env['TOKEN_KEY'] || '', (err, authData) => {
        if (err) {
            return res.status(403).json({
                message: 'El Token de la petición es inválido.'
            });
        }
        else {
            return res.json({
                message: 'Access all!',
                authData
            });
        }
    });
};
function isEmptyObject(obj) {
    for (var key in obj) {
        if (Object.prototype.hasOwnProperty.call(obj, key)) {
            return false;
        }
    }
    return true;
}
exports.verifyToken = (req, res, next) => {
    const bearerHeader = req.headers['authorization'];
    if (typeof bearerHeader !== 'undefined') {
        //const bearer = bearerHeader.split(' ');
        //const bearerToken = bearer[1];
        //req.params.token = bearerToken;
        req.params.token = bearerHeader;
        next();
    }
    else {
        res.status(403).json({
            message: 'No se ha encontrado Token en la petición.'
        });
    }
};
