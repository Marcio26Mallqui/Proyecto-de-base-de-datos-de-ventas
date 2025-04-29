
-- Insertar datos a la tabla cliente

SELECT* FROM dbo.clientes;

WITH numeros AS (
	SELECT 1 as num
	UNION ALL 
	SELECT num + 1 FROM numeros WHERE num <2000)
INSERT INTO dbo.clientes (cli_nombre_completo,	cli_sexo,	cli_email,	cli_ciudad)
SELECT
	'cliente' + CAST(num AS VARCHAR(10)),
	CASE 
		WHEN num % 2 = 0 THEN 'M'
		ELSE 'F' END,
	'cliente' + CAST(num AS VARCHAR(10)) + '@gmail.com',
	CASE 
		WHEN num % 3 = 0 THEN 'ciudad A'
		WHEN num % 3 = 1 THEN 'ciudad B'
		ELSE 'ciudad C' END
FROM numeros OPTION (MAXRECURSION 2000);

-- Insertar datos categorías

SELECT * FROM dbo.categorias;

INSERT INTO dbo.categorias
VALUES
('auriculares'),
('electrodomésticos'),
('monitores'),
('portátiles'),
('teléfonos'),
('televisores');

-- Insertar datos producto

SELECT * FROM dbo.productos; 

-- DELETE FROM dbo.productos

WITH numeros AS (
	SELECT 1  AS num
	UNION ALL
	SELECT num + 1 FROM numeros WHERE num < 50 
)
INSERT INTO productos (prod_nombre, id_categ, precio, stock)
SELECT
	'producto' + CAST(num AS CHAR),
	ABS(CHECKSUM(NEWID())) % 6 +1,
	ROUND((ABS(CHECKSUM(NEWID())) % 1000 + 100) * 1.0, 2),
	ABS(CHECKSUM(NEWID())) % 400 + 500
FROM numeros OPTION (MAXRECURSION 50);

-- Añadir datos a la tabla proveedores

SELECT * FROM dbo.proveedores;

WITH numeros AS (
	SELECT 1 AS num
	UNION ALL
	SELECT num + 1 FROM numeros WHERE num < 5
)
INSERT INTO proveedores(prov_nombre_completo, prov_telefono, prov_ciudad)
SELECT 
	'proveedor' + CAST(num AS CHAR),
	ABS(CHECKSUM(NEWID())) % 6 + 999456326,
	CASE 
		WHEN num % 3 = 0 THEN 'ciudad A'
		WHEN num % 3 = 1 THEN 'ciudad B'
	ELSE 'ciudad C' END
FROM numeros OPTION (MAXRECURSION 50);

-- SELECT * FROM numeros OPTION(MAXRECURSION 5)


-- Añadir datos a la tabla empleados

SELECT * FROM dbo.empleados;

WITH numeros AS (
	SELECT 1 AS num
	UNION ALL
	SELECT num + 1 FROM numeros WHERE num < 20
)
INSERT INTO empleados(emp_nombre, emp_correo, emp_fecha_ingreso)
SELECT
	'empleado' + CAST(num AS VARCHAR(4)),
	'empleado' + CAST(num AS VARCHAR(4)) + '@gmail.com',
	DATEADD(DAY, - (ABS(CHECKSUM(NEWID())) % 365), '2023-06-25') 
FROM numeros OPTION (MAXRECURSION 20);


-- Añadir datos a la tabla ordenes

SELECT * FROM dbo.ordenes;

WITH numeros AS (
	SELECT 1 AS num
	UNION ALL
	SELECT num + 1 FROM numeros WHERE num < 1300000
)
INSERT INTO ordenes (id_cliente, id_empleado, fecha_orden)
SELECT 
	ABS(CHECKSUM(NEWID())) % 2000 + 1,
	ABS(CHECKSUM(NEWID())) % 20 + 1,
	GETDATE() - (ABS(CHECKSUM(NEWID())) % 365)
FROM numeros OPTION (MAXRECURSION 0);


-- Añadir datos a la tabla detalle_orden

SELECT * FROM dbo.detalle_ordenes;

WITH numeros AS (
	SELECT 1 AS num
	UNION ALL
	SELECT num + 1 FROM numeros WHERE num < 1300000
)
INSERT INTO dbo.detalle_ordenes(id_orden, id_prod, cantidad)
SELECT 
	num,
	ABS(CHECKSUM(NEWID())) % 50 + 1,
	ABS(CHECKSUM(NEWID())) % 10 + 1
FROM numeros  OPTION (MAXRECURSION 0); 




