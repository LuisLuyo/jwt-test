import { Request, Response, NextFunction } from 'express';
import { pool } from '../database';
import { QueryResult } from 'pg';
import jwt from 'jsonwebtoken';

export const getPrueba = async (req: Request, res: Response): Promise<Response> => {
  try {
    return res.status(200).json({ text: 'api works!' });
  } catch (e) {
      console.log(e);
      return res.status(500).json('Internal Server error');
  }
};

export const generateToken = async (req: Request, res: Response): Promise<Response> => {
    try {
      const { usuario, clave } = req.body;
      const response: QueryResult = await pool.query('SELECT usuario, estado FROM SIGV_SEGURIDAD.USUARIO WHERE USUARIO = $1 AND CLAVE = $2;', [usuario,clave]);
      const rows = response.rows;
      if(!isEmptyObject(response.rows)){
        console.log(response.rows);
        const token = jwt.sign({response}, process.env['TOKEN_KEY'] || '', { expiresIn: process.env['TOKEN_EXP'] });
        res.status(200);
        res.setHeader('jwt', token);
        return res.json({
          message: 'Token generated successfully!',
          body: { usuario: response.rows }
        });
      }
      else {
        return res.status(401).json({
            message: 'Error en usuario/contraseña, volver a intentar, falso!',
            body: {
            }
        });
      }
    } catch (e) {
      console.log(e);
      return res.status(500).json('Internal Server error');
    }
}

export const validateToken = (req: Request, res: Response) => {
    jwt.verify(req.params.token, process.env['TOKEN_KEY']  || '', (err, authData) => {
      if(err) {
         return res.status(403).json({
            message: 'El Token de la petición es inválido.'
        });
      } else {
        return res.json({
          message: 'Access all!',
          authData
        });
      }
    });
}

function isEmptyObject(obj : any) {
  for (var key in obj) {
    if (Object.prototype.hasOwnProperty.call(obj, key)) {
      return false;
    }
  }
  return true;
}

export const verifyToken = (req: Request, res: Response, next: NextFunction) => {
  const bearerHeader = req.headers['authorization'];
  if(typeof bearerHeader !== 'undefined') {
    //const bearer = bearerHeader.split(' ');
    //const bearerToken = bearer[1];
    //req.params.token = bearerToken;
    req.params.token = bearerHeader;
    next();
  } else {
    res.status(403).json({
      message: 'No se ha encontrado Token en la petición.'
    });
  }
}