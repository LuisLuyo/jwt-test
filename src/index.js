const app = require('./app');

async function init() {
    await app.listen(process.env['SERVER_PORT']);
    console.log('Server on port ' + process.env['SERVER_PORT']);
}

init();