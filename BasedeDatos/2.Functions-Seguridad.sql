CREATE OR REPLACE FUNCTION sigv_seguridad.inicia_session(
	_usuario character varying,
	_clave character varying,
	_uniquedeviceid character varying)
    RETURNS record
    LANGUAGE 'plpgsql'
AS $BODY$
	DECLARE
		registro 			RECORD;
		idusuario			INT;
		idusuarioq			INT;
		idperfil			INT;
		idperfilq			INT;
		idsucursalq			INT;
		idempresaq			INT;
		terminal			VARCHAR;
		maxlogeoq 			INT;
		resetintentologeoq	INTERVAL;
		i_fecha_logeo		TIMESTAMP;
		f_fecha_logeo		TIMESTAMP;
		intento				INT;
		ingreso				INT;
		nombres				VARCHAR;
		sexo				VARCHAR;
		prefijo				VARCHAR;
		code				VARCHAR;
		message 			VARCHAR;
		BEGIN
			idusuario = 0;
			idperfil = 0;
			nombres = '';
			SELECT TU.IDUSUARIO, TU.IDSUCURSAL FROM SIGV_SEGURIDAD.USUARIO TU WHERE TU.USUARIO = _USUARIO INTO idusuarioq, idsucursalq;
			SELECT IDEMPRESA FROM SIGV_VENTAS.EMPRESASUCURSAL WHERE IDSUCURSAL = idsucursalq INTO idempresaq;
			SELECT T1.TERMINAL FROM SIGV_SEGURIDAD.TERMINAL T1 WHERE T1.UNIQUEDEVICEID = _UNIQUEDEVICEID INTO terminal;
			SELECT MAXLOGEO, RESETINTENTOLOGEO FROM SIGV_SEGURIDAD.SETTING WHERE CODIGO = 'GLOBAL-001' AND IDEMPRESA = idempresaq INTO maxlogeoq, resetintentologeoq;
			SELECT MAX(FECHAOPERACION) INIFECHAOPERACION FROM SIGV_SEGURIDAD.LOG WHERE DESCRIPCION = '1' AND IDUSUARIOOPERACION = idusuarioq AND IDOPERACION = 2 LIMIT 1 INTO i_fecha_logeo;
			SELECT i_fecha_logeo + resetintentologeoq::INTERVAL AS FINFECHAOPERACION INTO f_fecha_logeo;
			IF (NOW() BETWEEN i_fecha_logeo AND f_fecha_logeo) THEN
				SELECT MAX(T1.DESCRIPCION) INGRESO
				FROM (SELECT T2.*
						FROM SIGV_SEGURIDAD.LOG T2
	  					WHERE T2.IDUSUARIOOPERACION = idusuarioq AND 
 						(T2.FECHAOPERACION BETWEEN i_fecha_logeo AND f_fecha_logeo)) T1
				LIMIT 1 INTO ingreso;
				intento = ingreso + 1::INT;
			ELSE
				ingreso = 0;
				intento = 1;
			END IF;

			IF(intento < maxlogeoq OR intento = maxlogeoq) THEN -- OR 
				IF(idusuarioq > 0)THEN
					IF EXISTS(SELECT * FROM SIGV_SEGURIDAD.USUARIO WHERE USUARIO = _USUARIO AND ESTADO = 'A')THEN
						IF EXISTS(SELECT * FROM SIGV_SEGURIDAD.USUARIO WHERE USUARIO = _USUARIO AND CLAVE = _CLAVE AND ESTADO = 'A')THEN
							INSERT INTO SIGV_SEGURIDAD.LOG(IDUSUARIOOPERACION,CANALOPERACION,FECHAOPERACION,IDOPERACION,UNIQUEDEVICEID)
								VALUES(idusuarioq,'APP',NOW(),1,_UNIQUEDEVICEID);
							
							SELECT TU.IDPERFIL, TP.NOMBRES, TP.SEXO FROM SIGV_PERSONA.COLABORADOR TP
							LEFT JOIN SIGV_SEGURIDAD.USUARIO TU ON TP.IDCOLABORADOR=TU.IDCOLABORADOR
							WHERE TU.IDUSUARIO = idusuarioq INTO idperfil, nombres, sexo;
							IF(sexo = 'F')THEN
								prefijo = 'Bienvenida ';
							ELSE 
								prefijo = 'Bienvenido ';
							END IF;
							code = '00';
							message = prefijo||nombres||'!';
							idusuario = idusuarioq;
							--idperfil = 
							/*
							SELECT code,message,t1.idusuario,t1.idperfil,nombres,terminal
							FROM	sigv_seguridad.usuario t1
							WHERE t1.usuario=_usuario AND t1.clave=_clave
							INTO registro;
							RETURN registro;
							*/
						ELSE
							IF(intento = maxlogeoq)THEN
								UPDATE SIGV_SEGURIDAD.USUARIO T1
									SET ESTADO = 'I'
								WHERE T1.IDUSUARIO = idusuarioq;
								INSERT INTO SIGV_SEGURIDAD.LOG(IDUSUARIOOPERACION,CANALOPERACION,FECHAOPERACION,IDOPERACION,UNIQUEDEVICEID,DESCRIPCION)
									VALUES(idusuarioq,'APP',NOW(),2,_UNIQUEDEVICEID,(ingreso+1::INT)::VARCHAR);
								code = '05';
								message = 'EL USUARIO HA SIDO BLOQUEADO POR UN EXCESO DE INTENTOS DE LOGEO, POR FAVOR COMUNIQUESE CON EL ADMINISTRADOR DEL SISTEMA';						
							ELSE
								INSERT INTO SIGV_SEGURIDAD.LOG(IDUSUARIOOPERACION,CANALOPERACION,FECHAOPERACION,IDOPERACION,UNIQUEDEVICEID,DESCRIPCION)
									VALUES(idusuarioq,'APP',NOW(),2,_UNIQUEDEVICEID,(ingreso+1::INT)::VARCHAR);
								code = '06';
								message = 'CLAVE INCORRECTA';
							END IF; 
						END IF;
					ELSE
						code = '07';
						message = 'USUARIO BLOQUEADO COMUNIQUESE CON EL ADMINISTRADOR';
						INSERT INTO SIGV_SEGURIDAD.LOG(IDUSUARIOOPERACION,CANALOPERACION,FECHAOPERACION,IDOPERACION,UNIQUEDEVICEID)
							VALUES(idusuarioq,'APP',NOW(),3,_UNIQUEDEVICEID);
					END IF;				
				ELSE
					code = '08';
					message = 'USUARIO NO EXISTE';
				END IF;
			ELSE
				INSERT INTO SIGV_SEGURIDAD.LOG(IDUSUARIOOPERACION,CANALOPERACION,FECHAOPERACION,IDOPERACION,UNIQUEDEVICEID)
					VALUES(idusuarioq,'APP',NOW(),3,_UNIQUEDEVICEID);
				code = '09';
				message = 'EL USUARIO HA SIDO BLOQUEADO POR UN EXCESO DE INTENTOS DE LOGEO, POR FAVOR COMUNIQUESE CON EL ADMINISTRADOR DEL SISTEMA';
			END IF;
			SELECT INTO registro code, message,idusuario,idperfil,nombres,terminal;
			RETURN registro;
		END;
$BODY$;
