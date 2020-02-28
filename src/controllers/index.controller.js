const { Pool } = require('pg');

const pool = new Pool({
    user: 'adminfrances1720',
    host: '64.227.1.145',
    password: 'Frances1720@2020',
    database: 'francesTest',
    port: '5432'
});

const getPrueba = (req,res) => {
    res.json({
        text: 'api works!'
    });
}

const listUsuario = async (req, res) => {
    const response = await pool.query('SELECT * FROM SIGV_SEGURIDAD.USUARIO ORDER BY idusuario ASC');
    res.status(200).json(response.rows);
};

module.exports = {
    getPrueba,
    listUsuario
}