"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const dotenv_1 = __importDefault(require("dotenv"));
const path_1 = require("path");
let ambiente, path, node_env;
//Load environment variables
path = path_1.resolve('${__dirname}../../src/.env');
dotenv_1.default.config({ path: path });
node_env = new String(process.env['NODE_ENV']);
switch (node_env.toUpperCase()) {
    case "LOCAL":
        path = path_1.resolve('${__dirname}../../src/.envLocal');
        ambiente = 'Local';
        break;
    case "DEV":
        path = path_1.resolve('${__dirname}../../src/.envDev');
        ambiente = 'DESARROLLO';
        break;
    case "TEST":
        path = path_1.resolve('${__dirname}../../src/.envTest');
        ambiente = 'TEST';
        break;
    case "QA":
        path = path_1.resolve('${__dirname}../../src/.envQA');
        ambiente = 'CALIDAD';
        break;
    case "PROD":
        path = path_1.resolve('${__dirname}../../src/.envProd');
        ambiente = 'PRODUCCION';
        break;
    default:
        path = path_1.resolve('${__dirname}../../src/.envDev');
        ambiente = 'DESARROLLO';
}
dotenv_1.default.config({ path: path });
process.env['AMBIENTE'] = ambiente;
