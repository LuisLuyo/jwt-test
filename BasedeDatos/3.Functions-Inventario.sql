\set postgres_user "adminfrances1720T"
\set postgres_db "francesTest"

\c :postgres_db

CREATE OR REPLACE FUNCTION sigv_inventario.buscarproducto(
	_pagina integer,
	_idsubcategoria integer,
	_idsucursal integer,
	_idstock integer,
	_periodo character varying,
	_codigo character varying,
	_producto character varying,
	_estado character varying,
	OUT idproducto integer,
	OUT codigo character varying,
	OUT idcategoria integer,
	OUT categoria character varying,
	OUT idsubcategoria integer,
	OUT subcategoria character varying,
	OUT producto character varying,
	OUT tipo character varying,
	OUT idmarca integer,
	OUT idmedida integer,
	OUT stock_min numeric,
	OUT stock_actual numeric,
	OUT stock_max numeric,
	OUT costo numeric,
	OUT pventa numeric,
	OUT imagen character varying,
	OUT estado character varying,
	OUT situacion character varying,
	OUT situacion2 character varying)
    RETURNS SETOF record 
    LANGUAGE 'plpgsql'
    
AS $BODY$
	DECLARE
		registro 	RECORD;
		_condicion	VARCHAR;
		_cadena		VARCHAR;
		_idstock_n	INT;
		ipagination	INT;
		fpagination	INT;
		pagination	INT;
	BEGIN
		pagination = 100;
		fpagination = _pagina * pagination;
		ipagination = (fpagination - pagination) + 1;
		_condicion = '';
		IF(_idstock = 0)THEN
			IF(_idsucursal!=0)THEN
				SELECT IDSTOCK FROM SIGV_INVENTARIO.STOCK WHERE MES = RTRIM(TO_CHAR(CURRENT_DATE,'MM'),'0') AND PERIODO = _periodo AND IDSUCURSAL = _idsucursal INTO _idstock_n;
				IF(_condicion = '')THEN
					_condicion = 'WHERE T2.IDSTOCK = '||_idstock_n;
				END IF;
			END IF;
		ELSE
			IF(_condicion = '')THEN
				_condicion = 'WHERE T2.IDSTOCK = '||_idstock;
			END IF;
		END IF;

		IF(_idsubcategoria != 0)THEN
			IF(_condicion = '')THEN
				_condicion = 'WHERE T1.IDSUBCATEGORIA = '||_idsubcategoria;
			ELSE
				_condicion = 'AND T1.IDSUBCATEGORIA = '||_idsubcategoria;
			END IF;
		END IF;

		IF(_codigo!='' OR _producto!='')THEN
			IF(_condicion = '')THEN
				_condicion = 'WHERE UPPER(TRIM(T1.CODIGO)) LIKE ''%'||_codigo||'%''';
			ELSE
				_condicion = _condicion||' AND UPPER(TRIM(T1.CODIGO)) LIKE ''%'||_codigo||'%'' AND UPPER(TRIM(T1.DESCRIPCION)) LIKE ''%'||_producto||'%''   ';
			END IF;
		END IF;

		IF(_estado!='')THEN
			IF(_condicion = '')THEN
				_condicion = 'WHERE T1.ESTADO = '''||_estado||'''';
			ELSE 
				_condicion = _condicion||' AND T1.ESTADO ='''||_estado||'''';
			END IF;
		END IF;
		_cadena	='SELECT
					*
					FROM
					(
						SELECT T1.IDPRODUCTO,
							T1.CODIGO,
							T3.IDCATEGORIA,
							T4.DESCRIPCION CATEGORIA,
							T1.IDSUBCATEGORIA,
							T3.DESCRIPCION SUBCATEGORIA,
							T1.DESCRIPCION PRODUCTO,
							T1.TIPO,
							T1.IDMARCA,
							T1.IDMEDIDA,
							T1.STOCK_MIN,
							SUM(T2.CANTIDAD) STOCK_ACTUAL,
							T1.STOCK_MAX,
							T1.COSTO,
							T1.PVENTA,
							T1.IMAGEN,
							T1.ESTADO,
							CASE 
								WHEN SUM(T2.CANTIDAD) = T1.STOCK_MAX THEN
									''STOCK MAXIMO''
								WHEN SUM(T2.CANTIDAD) > T1.STOCK_MIN AND SUM(T2.CANTIDAD) < T1.STOCK_MIN+6 THEN
									''POR AGOTAR''
								WHEN SUM(T2.CANTIDAD) > 1 AND SUM(T2.CANTIDAD) < T1.STOCK_MIN+1 OR SUM(T2.CANTIDAD) = 1 THEN
									''PEDIR PRODUCTO''
								WHEN SUM(T2.CANTIDAD) = 0 THEN
									''PRODUCTO AGOTADO''
								ELSE ''DISPONIBLE''
							END::VARCHAR AS SITUACION,
							CASE 
								WHEN SUM(T2.CANTIDAD) = 0 THEN
									0
								WHEN SUM(T2.CANTIDAD) > 0 THEN
									1		
							END::INT AS SITUACION2,
							ROW_NUMBER () OVER (ORDER BY T1.DESCRIPCION)
						FROM SIGV_INVENTARIO.PRODUCTO T1
						LEFT JOIN SIGV_INVENTARIO.STOCKD T2 ON T1.IDPRODUCTO = T2.IDPRODUCTO
						LEFT JOIN SIGV_INVENTARIO.SUBCATEGORIA T3 ON T1.IDSUBCATEGORIA = T3.IDSUBCATEGORIA
						LEFT JOIN SIGV_INVENTARIO.CATEGORIA T4 ON T3.IDCATEGORIA = T4.IDCATEGORIA
						'||_condicion||'
						GROUP BY 1,3,4,6
						ORDER BY T1.DESCRIPCION
					) x
					WHERE
					ROW_NUMBER BETWEEN '||ipagination||' AND '||fpagination||';';
		RAISE NOTICE'_CADENA %',_cadena;
		FOR registro IN
			EXECUTE(_cadena)LOOP
			IDPRODUCTO := registro.IDPRODUCTO;
			CODIGO := registro.CODIGO;
			IDCATEGORIA := registro.IDCATEGORIA;
			CATEGORIA := registro.CATEGORIA;
			IDSUBCATEGORIA := registro.IDSUBCATEGORIA;
			SUBCATEGORIA := registro.SUBCATEGORIA;
			PRODUCTO := registro.PRODUCTO;
			TIPO := registro.TIPO;
			IDMARCA := registro.IDMARCA;
			IDMEDIDA := registro.IDMEDIDA;
			STOCK_MIN:= registro.STOCK_MIN;
			STOCK_ACTUAL := registro.STOCK_ACTUAL;
			STOCK_MAX := registro.STOCK_MAX;
			COSTO := registro.COSTO;
			PVENTA := registro.PVENTA;
			IMAGEN := registro.IMAGEN;
			ESTADO := registro.ESTADO;
			SITUACION := registro.SITUACION;
			SITUACION2 := registro.SITUACION2;
			RETURN NEXT;
		END LOOP;
		RETURN;			
	END;
$BODY$;

CREATE OR REPLACE FUNCTION SIGV_INVENTARIO.LISTARCATEGORIA(
	_idcategoria INTEGER,
	_estado CHARACTER VARYING,
	OUT idcategoria INTEGER,
	OUT categoria CHARACTER VARYING)
    RETURNS SETOF RECORD 
    LANGUAGE 'plpgsql'
AS $BODY$
	DECLARE
		registro 	RECORD;
		_condicion	VARCHAR;
		_cadena		VARCHAR;
	BEGIN	
		_condicion = '';
		IF(_idcategoria != 0)THEN
			IF(_condicion = '')THEN
				_condicion = 'WHERE T1.IDCATEGORIA = '||_idcategoria;
			END IF;
		ELSE
			IF(_estado!='')THEN
				IF(_condicion = '')THEN
					_condicion = 'WHERE T1.ESTADO = '''||_estado||'''';
				ELSE 
					_condicion = _condicion||' AND T1.ESTADO ='''||_estado||'''';
				END IF;
			END IF;
		END IF;
		_cadena	= 'SELECT
					T1.IDCATEGORIA,
					T1.DESCRIPCION CATEGORIA
					FROM SIGV_INVENTARIO.CATEGORIA T1
						'||_condicion||'
					ORDER BY T1.DESCRIPCION';
			
		RAISE NOTICE'_CADENA %',_cadena;
		FOR registro IN
			EXECUTE(_cadena)LOOP
				IDCATEGORIA := registro.IDCATEGORIA;
				CATEGORIA := registro.CATEGORIA;
				RETURN NEXT;
			END LOOP;
		RETURN;	
	END;
$BODY$;

CREATE OR REPLACE FUNCTION SIGV_INVENTARIO.LISTARSUBCATEGORIA(
	_idsubcategoria INTEGER,
	_idcategoria INTEGER,
	_estado CHARACTER VARYING,
	OUT idsubcategoria INTEGER,
	OUT subcategoria CHARACTER VARYING)
	RETURNS SETOF record
	LANGUAGE 'plpgsql'
  AS $BODY$
	DECLARE
		registro 	RECORD;
		_condicion	VARCHAR;
		_cadena		VARCHAR;
	BEGIN
		_condicion = '';
		IF(_idsubcategoria != 0)THEN
			IF(_condicion = '')THEN
				_condicion = 'WHERE T1.IDSUBCATEGORIA = '||_idsubcategoria;
			END IF;
		ELSE
			IF(_idcategoria != 0)THEN
				IF(_condicion = '')THEN
					_condicion = 'WHERE T1.IDCATEGORIA = '||_idcategoria;
				END IF;
				IF(_estado != '')THEN
					_condicion = _condicion||' AND T1.ESTADO ='''||_estado||'''';
				END IF;
			ELSE
				IF(_estado != '')THEN
					IF(_condicion = '')THEN
						_condicion = 'WHERE T1.ESTADO = '''||_estado||'''';
					ELSE 
						_condicion = _condicion||' AND T1.ESTADO ='''||_estado||'''';
					END IF;
				END IF;
			END IF;
		END IF;
		_cadena	='SELECT
					T1.IDSUBCATEGORIA,
					T1.DESCRIPCION SUBCATEGORIA
					FROM SIGV_INVENTARIO.SUBCATEGORIA T1
					'||_condicion||'
					ORDER BY T1.DESCRIPCION';

		RAISE NOTICE'_CADENA %',_cadena;	
		FOR registro IN
			EXECUTE(_cadena)LOOP
			IDSUBCATEGORIA := registro.IDSUBCATEGORIA;
			SUBCATEGORIA := registro.SUBCATEGORIA;
			RETURN NEXT;
		END LOOP;
		RETURN;
	END;
$BODY$

CREATE OR REPLACE FUNCTION SIGV_INVENTARIO.LISTARMARCA(
	_idmarca INTEGER,
	_idsubcategoria INTEGER,
	_estado CHARACTER VARYING,
	OUT idmarca INTEGER,
	OUT idsubcategoria INTEGER,
	OUT idsubcategoriamarca INTEGER,
	OUT marca CHARACTER VARYING)
	RETURNS SETOF RECORD
	LANGUAGE 'plpgsql'
AS $BODY$
	DECLARE
		registro 	RECORD;
		_condicion	VARCHAR;
		_cadena		VARCHAR;
	BEGIN
		_condicion = '';
		IF(_idmarca != 0)THEN
			IF(_condicion = '')THEN
				_condicion = 'WHERE T1.IDMARCA = '||_idmarca;
			END IF;
		ELSE
			IF(_idsubcategoria != 0)THEN
				IF(_condicion = '')THEN
					_condicion = 'WHERE T2.IDSUBCATEGORIA = '||_idsubcategoria;
				END IF;
				IF(_estado != '')THEN
					_condicion = _condicion||' AND T2.ESTADO ='''||_estado||'''';
				END IF;
			ELSE
				IF(_estado != '')THEN
					IF(_condicion = '')THEN
						_condicion = 'WHERE T2.ESTADO = '''||_estado||'''';
					ELSE 
						_condicion = _condicion||' AND T2.ESTADO ='''||_estado||'''';
					END IF;
				END IF;
			END IF;
		END IF;

		_cadena	='SELECT T1.IDMARCA,
					T2.IDSUBCATEGORIA,
					T2.IDSUBCATEGORIAMARCA,
					T1.DESCRIPCION MARCA
					FROM SIGV_INVENTARIO.MARCA T1
					LEFT JOIN SIGV_INVENTARIO.SUBCATEGORIAMARCA T2 ON T1.IDMARCA = T2.IDMARCA
                    '||_condicion||'
                    ORDER BY T1.DESCRIPCION';
		RAISE NOTICE'_CADENA %',_cadena;
		FOR registro IN
			EXECUTE(_cadena)LOOP
			IDMARCA := registro.IDMARCA;
			IDSUBCATEGORIA := registro.IDSUBCATEGORIA;
			IDSUBCATEGORIAMARCA := registro.IDSUBCATEGORIAMARCA;
			MARCA := registro.MARCA;
			RETURN NEXT;
		END LOOP;
		RETURN;			
	END;
$BODY$

CREATE OR REPLACE FUNCTION sigv_inventario.insertarproducto(
	_idproducto integer,
	_codigo character varying,
	_descripcion character varying,
	_tipo character varying,
	_idsubcategoria integer,
	_idmarca integer,
	_idmedida integer,
	_stock_min numeric,
	_stock_max numeric,
	_costo numeric,
	_pventa numeric,
	_imagen character varying,
	_estado character varying,
	_idusuarioalta integer,
	_canalalta character varying)
    RETURNS record
    LANGUAGE 'plpgsql'
AS $BODY$
	DECLARE
		registro 	RECORD;
		_idcat		VARCHAR;
		_idsubcat	VARCHAR;
		_idmarcacad	VARCHAR;
		_idproducton VARCHAR;
		_codigon	VARCHAR(20);
		retorno		INT;
		codreto		VARCHAR(7);
		mensaje		VARCHAR(100);
		filler		VARCHAR(100);
	BEGIN
		------------------------------- VALIDACION DE DATOS ENTRADA -------------------------------
		retorno 		= 1;
		_codigo 		= UPPER(TRIM(_codigo));
		_descripcion 	= UPPER(TRIM(_descripcion));
		_tipo			= UPPER(TRIM(_tipo));
		_imagen 		= TRIM(_imagen);
		_estado 		= UPPER(TRIM(_estado));
		_canalalta 		= UPPER(TRIM(_canalalta));
		filler			= '';
		IF(_idproducto != 0)THEN
				retorno = 0;
				codreto = 'INE0008';
				mensaje = 'Utilize servicio modificación.';
				SELECT INTO registro codreto, mensaje;
				RETURN registro;
		END IF;
		IF(_codigo != '')THEN
			IF EXISTS(SELECT codigo FROM sigv_inventario.producto WHERE codigo = _codigo)THEN
				retorno = 0;
				codreto = 'INE0000';
				mensaje = 'El código de producto ya existe.';
				SELECT INTO registro codreto, mensaje;
				RETURN registro;
			END IF;
		ELSE
			_codigo = 'DEFAULT999';
		END IF;
		IF(TRIM(_descripcion) = '' OR _descripcion IS NULL)THEN
			retorno = 0;
			codreto = 'INE0001';
			mensaje = 'Ingresar descripción del producto.';
			SELECT INTO registro codreto, mensaje;
			RETURN registro;
		ELSE
			IF EXISTS(SELECT descripcion FROM sigv_inventario.producto WHERE descripcion = _descripcion)THEN
				retorno = 0;
				codreto = 'INE0007';
				mensaje = 'El nombre del producto ya existe.';
				SELECT INTO registro codreto, mensaje;
				RETURN registro;
			END IF;
		END IF;
		IF(TRIM(_tipo) = '' OR _tipo IS NULL)THEN
			_tipo = 'B';
		END IF;
		IF(_idsubcategoria = 0 OR _idsubcategoria IS NULL)THEN
			retorno = 0;
			codreto = 'INE0002';
			mensaje = 'Ingresar subcategoria del producto.';
			SELECT INTO registro codreto, mensaje;
			RETURN registro;
		END IF;
		IF(_idmarca = 0 OR _idmarca IS NULL)THEN
			retorno = 0;
			codreto = 'INE0003';
			mensaje = 'Ingresar marca del producto.';
			SELECT INTO registro codreto, mensaje;
			RETURN registro;
		END IF;
		IF(_idmedida = 0 OR _idmedida IS NULL)THEN
			_idmedida = 1;
		END IF;
		IF(_stock_min IS NULL)THEN
			_stock_min = 0::NUMERIC;
		END IF;
		IF(_stock_max IS NULL)THEN
			_stock_max = 0::NUMERIC;
		END IF;
		IF(_costo IS NULL)THEN
			_costo = 0::NUMERIC;
		END IF;
		IF(_pventa IS NULL)THEN
			retorno = 0;
			codreto = 'INE0004';
			mensaje = 'Ingresar precio de venta del producto.';
			SELECT INTO registro codreto, mensaje;
			RETURN registro;
		END IF;
		IF(TRIM(_estado) = '' OR _estado IS NULL)THEN
			_estado = 'A';
		END IF;		
		IF(_idusuarioalta = 0 OR _idusuarioalta IS NULL)THEN
			retorno = 0;
			codreto = 'INE0005';
			mensaje = 'Ingresar usuario de alta del producto.';
			SELECT INTO registro codreto, mensaje;
			RETURN registro;
		END IF;
		IF(TRIM(_canalalta) = '' OR _canalalta IS NULL)THEN
			retorno = 0;
			codreto = 'INE0006';
			mensaje = 'Ingresar canal de alta del producto.';
			SELECT INTO registro codreto, mensaje;
			RETURN registro;
		END IF;
		
		--------------------------------------- PROCESO ---------------------------------------
		IF(retorno != 0)THEN
			INSERT INTO sigv_inventario.producto
				(codigo, descripcion, tipo, idsubcategoria, idmarca, idmedida, stock_min, stock_max, costo, pventa, estado, idusuarioalta, canalalta, fechaalta)
			VALUES
				(_codigo, _descripcion, _tipo, _idsubcategoria, _idmarca, _idmedida, _stock_min, _stock_max, _costo, _pventa, _estado, _idusuarioalta, _canalalta, now())
			RETURNING idproducto INTO _idproducto;
			IF(_codigo = 'DEFAULT999')THEN
				SELECT idcategoria FROM sigv_inventario.subcategoria WHERE idsubcategoria = _idsubcategoria INTO _idcat;
				/*SELECT LPAD(idcategoria::VARCHAR,3,'0')::VARCHAR FROM sigv_inventario.subcategoria WHERE idsubcategoria = _idsubcategoria INTO _idcat;
				SELECT LPAD(_idsubcategoria::VARCHAR,3,'0')::VARCHAR INTO _idsubcat;
				SELECT LPAD(_idmarca::VARCHAR,3,'0')::VARCHAR INTO _idmarcacad;
				SELECT LPAD(_idproducto::VARCHAR,6,'0')::VARCHAR INTO _idproducton;*/
				_codigon = _idcat||_idsubcategoria||_idmarca||_idproducto;
				RAISE NOTICE'_codigon %',_codigon;
				UPDATE sigv_inventario.producto
				SET codigo = _codigon
				WHERE idproducto = _idproducto;
			END IF;
			retorno = 1;
			codreto = 'INA0001';
			mensaje = 'PRODUCTO CREADO CORRECTAMENTE...';
			filler	= _idproducto::VARCHAR;
			SELECT INTO registro codreto, mensaje, filler;
			RETURN registro;
		END IF;
	END;
$BODY$;