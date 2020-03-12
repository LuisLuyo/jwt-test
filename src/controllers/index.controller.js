const { Pool } = require('pg');
const jwt = require('jsonwebtoken');

const pool = new Pool({
    user: process.env['PG_USERNAME'],
    host: process.env['PG_HOSTNAME'],
    password: process.env['PG_PASSWORD'],
    database: process.env['PG_DATABASE'],
    port: process.env['PG_PORT'],
});

const getPrueba = (req,res) => {
    res.json({
        text: 'api works!'
    });
}

const generateToken = async (req,res) => {
    //const usuarioParameter = String(req.params.usuario);
    //const claveParameter = String(req.params.clave);
    const { usuario, clave } = req.body;
    const usuariores = await pool.query('SELECT usuario, estado FROM SIGV_SEGURIDAD.USUARIO WHERE USUARIO = $1 AND CLAVE = $2;', [usuario,clave]);
    const rows = usuariores.rows;
    if(!isEmptyObject(usuariores.rows)){
        console.log(usuariores.rows);
        const token = jwt.sign({usuariores}, process.env['TOKEN_KEY'], { expiresIn: process.env['TOKEN_EXP'] });
        res.status(200).json({
            message: 'Token generated successfully!',
            body: {
                usuario: usuariores.rows,
                jwt : token
            }
        });
    }
    else {
        res.status(401).json({
            message: 'Error en usuario/contraseña, volver a intentar, falso!',
            body: {
            }
        });
    }
}

const validateToken = async (req,res) => {
    jwt.verify(req.token, process.env['TOKEN_KEY'], (err, authData) => {
      if(err) {
         res.status(403).json({
            message: 'El Token de la petición es inválido.'
        });
      } else {
        res.json({
          message: 'Access all!',
          authData
        });
      }
    });
}

function isEmptyObject(obj) {
  for (var key in obj) {
    if (Object.prototype.hasOwnProperty.call(obj, key)) {
      return false;
    }
  }
  return true;
}

function verifyToken(req, res, next) {
    const bearerHeader = req.headers['authorization'];
    if(typeof bearerHeader !== 'undefined') {
      const bearer = bearerHeader.split(' ');
      const bearerToken = bearer[1];
      req.token = bearerToken;
      next();
    } else {
        res.status(403).json({
            message: 'No se ha encontrado Token en la petición.'
        });
    }
}

module.exports = {
    getPrueba,
    generateToken,
    validateToken,
    verifyToken
}