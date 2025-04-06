
-- Insertar datos a la tabla cliente

SELECT* FROM dbo.clientes;

WITH numeros AS (
	SELECT 1 as num
	UNION ALL 
	SELECT num + 1 FROM numeros WHERE num <1000)
INSERT INTO dbo.clientes
SELECT
	'cliente' + CAST(num AS VARCHAR(4)),
	CASE 
		WHEN num % 2 = 0 THEN 'M'
		ELSE 'F' END,
	'cliente' + CAST(num AS VARCHAR(4)) + '@gmail.com',
	CASE 
		WHEN num % 3 = 0 THEN 'ciudad A'
		WHEN num % 3 = 1 THEN 'ciudad B'
		ELSE 'ciudad C' END
FROM numeros OPTION (MAXRECURSION 1000);

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
INSERT INTO productos (id_categ, prod_nombre, precio_unitario)
SELECT
	ABS(CHECKSUM(NEWID())) % 6 +1,
	'producto' + CAST(num AS CHAR),
	ROUND((ABS(CHECKSUM(NEWID())) % 1000 + 100) * 1.0, 2) 
FROM numeros OPTION (MAXRECURSION 50);

-- Añadir datos a venta

SELECT * FROM dbo.ventas;

WITH numeros AS (
	SELECT 1 AS num
	UNION ALL
	SELECT num + 1 FROM numeros WHERE num < 1000
)
INSERT INTO dbo.ventas (id_cliente, fecha_venta)
SELECT
	ABS(CHECKSUM(NEWID())) % 1000 + 1,
	GETDATE() - (ABS(CHECKSUM(NEWID())) % 365)
FROM numeros OPTION (MAXRECURSION 1000);


-- Añadir datos a la tabla ordenes

SELECT * FROM dbo.ordenes

WITH numeros AS (
	SELECT 1 AS num
	UNION ALL
	SELECT num + 1 FROM numeros WHERE num < 1000
)
INSERT INTO ordenes (id_cliente,  fecha_orden)
SELECT 
	ABS(CHECKSUM(NEWID())) % 1000 + 1,
	GETDATE() - (ABS(CHECKSUM(NEWID())) % 365)
FROM numeros OPTION (MAXRECURSION 1000);

-- Añadir datos a la tabla detalle_orden

SELECT * FROM dbo.detalle_orden

WITH numeros AS (
	SELECT 1 AS num
	UNION ALL
	SELECT num + 1 FROM numeros WHERE num < 1000
)
INSERT INTO dbo.detalle_orden (id_orden, id_prod, cantidad)
SELECT 
	num,
	ABS(CHECKSUM(NEWID())) % 50 + 1,
	ROUND((ABS(CHECKSUM(NEWID())) % 10 + 1) * 1.0, 2)
FROM numeros  OPTION (MAXRECURSION 1000); 
