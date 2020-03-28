import app from "./app";

/* Esto es un comentario commit de docker */
async function init() {
    await app.listen(process.env['SERVER_PORT']);
    console.log('Server on port ======', process.env['SERVER_PORT']);
    console.log('JWT SIGV connect to==', process.env['AMBIENTE']);
}
init();