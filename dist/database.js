"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const pg_1 = require("pg");
exports.pool = new pg_1.Pool({
    user: process.env['PG_USERNAME'],
    host: process.env['PG_HOSTNAME'],
    password: process.env['PG_PASSWORD'],
    database: process.env['PG_DATABASE'],
    port: Number(process.env['PG_PORT'])
});
