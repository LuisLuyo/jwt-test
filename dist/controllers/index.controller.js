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
const OutputResponse_1 = require("../class/OutputResponse");
exports.generateToken = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const { usuario, clave } = req.body;
        const response = yield database_1.pool.query('SELECT usuario, estado FROM SIGV_SEGURIDAD.USUARIO WHERE USUARIO = $1 AND CLAVE = $2;', [usuario.toUpperCase(), clave.toUpperCase()]);
        const rows = response.rows;
        if (!isEmptyObject(response.rows)) {
            const token = jsonwebtoken_1.default.sign({ response }, process.env['TOKEN_KEY'] || '', { expiresIn: process.env['TOKEN_EXP'] });
            const data = new OutputResponse_1.OutputResponse("Success", "Success", "200", "00", "Token generado satisfactoriamente.", "El Token se ha creado correctamente con el usuario y la clave ingresada.");
            res.status(200);
            res.setHeader('jwt', token);
            return res.json(data);
        }
        else {
            const data = new OutputResponse_1.OutputResponse("Warning", "Unauthorized", "401", "01", "Usuario/clave incorrecto, volver a intentar.", "Las credenciales del usuario/clave son inválidos.");
            res.status(401);
            return res.json(data);
        }
    }
    catch (e) { //console.error(e.stack);
        const message = new String(e.message);
        const description = new String(e.code + ': ' + e.routine + ' - ' + e.hint);
        const data = new OutputResponse_1.OutputResponse("Error", "Fatal", "500", "02", message.toString(), description.toString());
        res.status(500);
        return res.json(data);
    }
});
exports.validateToken = (req, res) => {
    jsonwebtoken_1.default.verify(req.params.token, process.env['TOKEN_KEY'] || '', (err, authData) => {
        if (err) { //console.log(err.stack);
            const message = new String("El Token de la petición es inválido.");
            const description = new String(err.name + ': ' + err.message);
            const data = new OutputResponse_1.OutputResponse("Warning", "Forbidden", "403", "03", message.toString(), description.toString());
            res.status(403);
            return res.json(data);
        }
        else {
            //console.log(authData);
            const data = new OutputResponse_1.OutputResponse("Success", "Success", "200", "00", "Token autenticado correctamente.", "Token autenticado correctamente.");
            res.status(200);
            return res.json(data);
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
    const bearerHeader = req.headers['jwt'];
    if (typeof bearerHeader !== 'undefined') {
        req.params.token = bearerHeader.toString();
        next();
    }
    else {
        const data = new OutputResponse_1.OutputResponse("Warning", "Forbidden", "403", "04", "No se ha encontrado Token en la petición.", "Ingrese un valor en el parámetro jwt del Header.");
        res.status(403);
        return res.json(data);
    }
};
