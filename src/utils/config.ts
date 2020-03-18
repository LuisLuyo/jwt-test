import dotenv from 'dotenv';
import { resolve } from "path";
let ambiente,path,node_env;
//Load environment variables
path = resolve('${__dirname}../../src/.env');
dotenv.config({ path: path });

node_env = new String(process.env['NODE_ENV']);
switch (node_env.toUpperCase()) {
    case "DEV":
        path = resolve('${__dirname}../../src/.envDev');
        ambiente = 'DESARROLLO';
        break;
    case "TEST":
        path = resolve('${__dirname}../../src/.envTest');
        ambiente = 'TEST';
        break;
    case "QA":
        path = resolve('${__dirname}../../src/.envQA');
        ambiente = 'CALIDAD';
        break;         
    case "PROD":
        path = resolve('${__dirname}../../src/.envProd');
        ambiente = 'PRODUCCION';
        break;
    default:
        path = resolve('${__dirname}../../src/.envDev');
        ambiente = 'DESARROLLO';
}
dotenv.config({ path: path });
process.env['AMBIENTE'] = ambiente;