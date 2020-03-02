const { Pool } = require('pg');
const jwt = require('jsonwebtoken');

const pool = new Pool({
    user: 'adminfrances1720',
    host: '68.183.103.192',
    password: 'Frances1720@2020',
    database: 'francesTest',
    port: '5432'
});

const getPrueba = (req,res) => {
    res.json({
        text: 'api works!'
    });
}

const getToken = async (req,res) => {
    const user = {id:3};
    //const usuarioParameter = String(req.params.usuario);
    //const claveParameter = String(req.params.clave);
    const { usuario, clave } = req.body;
    const usuariores = await pool.query('SELECT usuario, estado FROM SIGV_SEGURIDAD.USUARIO WHERE USUARIO = $1 AND CLAVE = $2;', [usuario,clave]);
    //console.log(usuariores);
    //debo obtener el usuario y contraseña insertado desde el body
    //aqui debo acceder a la base de datos a Validar el usuario y la contraseña ingresada
    //según sea la respuesta debo validar si se genera o no el token
    const rows = usuariores.rows;
    if(!isEmptyObject(usuariores.rows)){
        console.log(usuariores.rows);
        const token = jwt.sign({usuariores}, 'my_secret_key', { expiresIn: '30s' });
        res.status(200).json({
            message: 'Token generated successfully!',
            body: {
                usuario: usuariores.rows,
                jwt : token
            }
        });
    }
    else {
        res.status(200).json({
            message: 'Error en usuario/contraseña, volver a intentar!',
            body: {
            }
        });
    }
}

function isEmptyObject(obj) {
  for (var key in obj) {
    if (Object.prototype.hasOwnProperty.call(obj, key)) {
      return false;
    }
  }
  return true;
}

const getUsuario = async (req, res) => {
    const ad = 'ADMINISTRADOR';
    const response = await pool.query('SELECT usuario, clave FROM SIGV_SEGURIDAD.USUARIO WHERE USUARIO = $1 ORDER BY idusuario ASC',[ad]);
    res.status(200).json(response.rows);
};

module.exports = {
    getPrueba,
    getUsuario,
    getToken
}