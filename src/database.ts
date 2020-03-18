import { Pool } from 'pg';
export const pool = new Pool({
    user: process.env['PG_USERNAME'],
    host: process.env['PG_HOSTNAME'],
    password: process.env['PG_PASSWORD'],
    database: process.env['PG_DATABASE'],
    port: Number(process.env['PG_PORT'])
});