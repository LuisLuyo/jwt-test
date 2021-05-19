import { httpServer, httpsServer } from "./app";

/* Esto es un comentario commit de docker */
async function init() {
    await httpServer.listen(process.env['SERVER_PORT']);
    console.log('Server on port ======', process.env['SERVER_PORT']);
    console.log('JWT SIGV connect to==', process.env['AMBIENTE']);

    await httpsServer.listen(process.env['SERVER_PORT_SECURE']);
    console.log('Server on port secure ======', process.env['SERVER_PORT_SECURE']);
    console.log('JWT SIGV connect to==', process.env['AMBIENTE']);
}
init();