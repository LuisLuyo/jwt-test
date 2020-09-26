import { Request, Response, NextFunction } from 'express';
import { pool } from '../database';
import { QueryResult } from 'pg';
import jwt from 'jsonwebtoken';
import { ArquitecturaResponse } from '../class/ArquitecturaResponse';

export const generateToken = async (req: Request, res: Response): Promise<Response> => {
  try {
    const { usuario, clave } = req.body;
    //console.log(req.body);
    const response: QueryResult = await pool.query('SELECT usuario, estado FROM SIGV_SEGURIDAD.USUARIO WHERE USUARIO = $1 AND CLAVE = $2;', [usuario.toUpperCase(),clave.toUpperCase()]);
    const user = response.rows;
    if(!isEmptyObject(user)){
      const estado = user[0].estado;
      if(estado == 'A'){
        const token = jwt.sign({user}, process.env['TOKEN_KEY'] || '', { expiresIn: process.env['TOKEN_EXP'] });
        const data = new ArquitecturaResponse("Success","Success","200","00","Token generado satisfactoriamente.","El Token se ha creado correctamente con el usuario y la clave ingresada.");
        res.status(200);
        res.setHeader('jwt', token);
        return res.json(data);
      }    
      else{
        const token = '';
        const data = new ArquitecturaResponse("Warning","Unauthorized","401","01","Usuario inactivo","El usuario se encuentra en estado inactivo.");
        res.status(401);
        res.setHeader('jwt', '');
        return res.json(data);
      }
    }
    else {
      const data = new ArquitecturaResponse("Warning","Not Found","404","05","Las credenciales son inválidas.","Registro no encontrado, usuario o clave incorrecto.");
      res.status(404);
      return res.json(data);
    }
  } catch (e) {
    console.error(e.stack);
    const message = new String(e.message);
    const description = new String(e.code + ': ' + e.routine + ' - ' + e.hint);
    const data = new ArquitecturaResponse("Error","Fatal","500","02",message.toString(),description.toString());
    res.status(500);
    return res.json(data);
  }
}

export const validateToken = (req: Request, res: Response) => {
    jwt.verify(req.params.token, process.env['TOKEN_KEY']  || '', (err, authData) => {
    if(err) {//console.log(err.stack);
      const message = new String("El Token de la petición es inválido.");
      const description = new String(err.name + ': '+ err.message);
      const data = new ArquitecturaResponse("Warning","Forbidden","403","03",message.toString(),description.toString());
      res.status(403);
      return res.json(data);
    } else {//console.log(authData);
      const data = new ArquitecturaResponse("Success","Success","200","00","Token autenticado correctamente.","Token autenticado correctamente.");
      res.status(200);
      return res.json(data);
    }
  });
}

export const verifyToken = (req: Request, res: Response, next: NextFunction) => {
  const bearerHeader = req.headers['jwt'];
  if(typeof bearerHeader !== 'undefined') {
    req.params.token = bearerHeader.toString();
    next();
  } else {
    const data = new ArquitecturaResponse("Warning","Forbidden","403","04","No se ha encontrado Token en la petición.","Ingrese un valor en el parámetro jwt del Header.");
    res.status(403);
    return res.json(data);
  }
}

function isEmptyObject(obj : any) {
  for (var key in obj) {
    if (Object.prototype.hasOwnProperty.call(obj, key)) {
      return false;
    }
  }
  return true;
}