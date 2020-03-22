CREATE OR REPLACE FUNCTION sigv_seguridad.inicia_session(
_usuario character varying,
_clave character varying,
_ipaddress character varying,
intento_logeo integer)
  RETURNS record AS
$BODY$
	DECLARE
		registro 	RECORD;
		mensaje 	VARCHAR;
		max_intento 	INT;
		ingreso		INT;
		idusuariodev 	INT;
		parametro	INT;
		_nombres	VARCHAR;
		_sexo		VARCHAR;
		_prefijo	VARCHAR;
		_idsucursal	INT;
		_terminal	VARCHAR;
        
		BEGIN
			SELECT max_intento_logeo FROM sigv_seguridad.settings WHERE codigo = 'SYSTEM001' INTO max_intento;
			SELECT * FROM sigv_seguridad.usuario WHERE usuario = _usuario INTO idusuariodev;

			SELECT MAX(t1.ingreso) ingreso FROM sigv_seguridad.log t1 WHERE t1.idusuario = idusuariodev LIMIT 1 INTO ingreso;

			IF(ingreso ISNULL)THEN
				ingreso = 0;
			END IF ;

			SELECT idsucursal FROM sigv_seguridad.usuario WHERE idusuario = idusuariodev INTO _idsucursal;


			SELECT terminal
			FROM sigv_seguridad.terminal
			WHERE idterminal = (SELECT idterminal FROM sigv_seguridad.terminalm WHERE /*idsucursal = _idsucursal AND*/ ip = _ipaddress)
			INTO _terminal;
			IF(intento_logeo < max_intento OR intento_logeo = max_intento) THEN
				IF(idusuariodev >0)THEN
					IF EXISTS(SELECT * FROM sigv_seguridad.usuario WHERE usuario = _usuario AND estado = 'G')THEN
						IF EXISTS(SELECT * FROM sigv_seguridad.usuario WHERE usuario = _usuario AND clave = _clave AND estado = 'G')THEN
							SELECT tp.nombres FROM sigv_persona.colaborador tp
							LEFT JOIN sigv_seguridad.usuario tu ON tp.idcolaborador=tu.idcolaborador
							WHERE tu.idusuario = idusuariodev INTO _nombres;
                                
							SELECT tp.sexo FROM sigv_persona.colaborador tp
							LEFT JOIN sigv_seguridad.usuario tu ON tp.idcolaborador=tu.idcolaborador
							WHERE tu.idusuario = idusuariodev INTO _sexo;
                                
							IF(_sexo = 'F')THEN
								_prefijo = 'Bienvenida ';
							END IF;
							IF(_sexo = 'M')THEN
								_prefijo = 'Bienvenido ';
							END IF;
                                
							mensaje = _prefijo||_nombres||'!';

							INSERT INTO sigv_seguridad.log(idusuario,fecha,hora,descripcion,ip_maquina,ingreso)
								VALUES(idusuariodev,now(),now(),'INGRESO SIN ERROR',inet_client_addr(),ingreso+1::INT);

							SELECT 1,mensaje,3,t1.idusuario,t1.idperfil,_nombres,_terminal
							FROM	sigv_seguridad.usuario t1
							WHERE t1.usuario=_usuario AND t1.clave=_clave
							INTO registro;
							RETURN registro;
						ELSE
							IF(intento_logeo = max_intento)THEN
								UPDATE sigv_seguridad.usuario t1
									SET estado = 'A'
								WHERE t1.idusuario = idusuariodev;
								mensaje = 'EL USUARIO HA SIDO ANULADO POR UN EXCESO DE INTENTOS DE LOGEO, POR FAVOR COMUNIQUESE CON EL ADMINISTRADOR DEL SISTEMA';						
								parametro = 0;
							ELSE
								INSERT INTO sigv_seguridad.log(idusuario,fecha,hora,descripcion,ip_maquina)
									VALUES(idusuariodev,now(),now(),'CLAVE INCORRECTA',inet_client_addr());
								mensaje = 'CLAVE INCORRECTA';
								parametro = 1;
							END IF; 
						END IF;
					ELSE
						mensaje = 'USUARIO ANULADO COMUNIQUESE CON EL ADMINISTRADOR DEL SISTEMA';

						INSERT INTO sigv_seguridad.log(idusuario,fecha,hora,descripcion,ip_maquina)
							VALUES(idusuariodev,now(),now(),'INGRESO DE USUARIO ANULADO',inet_client_addr());
						parametro = 0;

					END IF;				
				ELSE
					mensaje = 'USUARIO NO EXISTE';
					parametro = 2;
				END IF;
			ELSE
				IF(intento_logeo = max_intento)THEN
					UPDATE sigv_seguridad.usuario t1
						SET estado = 'A'
					WHERE t1.idusuario = idusuariodev;
				END IF; 
				mensaje = 'EL USUARIO HA SIDO ANULADO POR UN EXCESO DE INTENTOS DE LOGEO, POR FAVOR COMUNIQUESE CON EL ADMINISTRADOR DEL SISTEMA';						
				parametro = 0;
			END IF;
			SELECT INTO registro 0::INT, mensaje,parametro,0,0,'',_terminal;
			RETURN registro;
		END;

$BODY$
  LANGUAGE plpgsql VOLATILE