-- An�lisis de las tablas.

------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------

-- �Qu� cantidad de clientes por ciudad?

SELECT cl.cli_ciudad AS ciudad, COUNT(cl.id_cliente) AS cantidad_clientes 
FROM dbo.clientes cl
GROUP BY cl.cli_ciudad;

------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------

-- �Qu� cantidad de productos hay seg�n la categor�a?

SELECT ct.id_categ, ct.categ_nombre AS 'categor�a', COUNT(*) AS 'cantidad_producto'
FROM dbo.productos pd
JOIN dbo.categorias ct ON ct.id_categ = pd.id_categ
GROUP BY ct.id_categ, ct.categ_nombre;

------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------

-- �Cu�les son los  productos que pertenecen  a las categor�as 
--  port�tiles y tel�fonos?

SELECT pd.id_prod, cat.categ_nombre FROM dbo.productos pd
JOIN dbo.categorias cat ON cat.id_categ = pd.id_categ
WHERE pd.id_categ = 4
UNION ALL
SELECT pd.id_prod, cat.categ_nombre FROM dbo.productos pd
JOIN dbo.categorias cat ON cat.id_categ = pd.id_categ
WHERE pd.id_categ = 5;

------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------

-- Hallar los ingresos totales generados por cada cliente 
-- que compr� en 2024, y esto se ha mayor de 1000. 

SELECT ord.id_cliente AS cliente, 
		SUM(dord.cantidad * prod.precio_unitario) AS Ingresos 
FROM dbo.ordenes ord
JOIN dbo.detalle_orden dord ON dord.id_orden = ord.id_orden
JOIN dbo.productos prod ON prod.id_prod = dord.id_prod 
WHERE (ord.fecha_orden >= '2024-01-01') AND (ord.fecha_orden < '2025-01-01')  
GROUP BY ord.id_cliente
HAVING SUM(dord.cantidad * prod.precio_unitario) > 1000;

	-- Lo mismo pero utilizando las expresiones comunes de tabla CTE.

WITH cliente_precio_cantidad_2024 AS(
SELECT ord.id_cliente,
		dord.cantidad, 
		prod.precio_unitario
FROM dbo.ordenes ord
JOIN dbo.detalle_orden dord ON dord.id_orden = ord.id_orden
JOIN dbo.productos prod ON prod.id_prod = dord.id_prod
WHERE ord.fecha_orden BETWEEN '2024-01-01' AND '2024-12-31'
)
SELECT cpc2024.id_cliente AS cliente, 
	  SUM(cpc2024.cantidad * cpc2024.precio_unitario) AS ingresos
FROM cliente_precio_cantidad_2024 cpc2024
GROUP BY cpc2024.id_cliente
HAVING SUM(cpc2024.cantidad * cpc2024.precio_unitario) > 1000;

------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------

-- Calcular las ventas medias y totales de cada categor�a 
-- de productos.

WITH cat_ingresos AS(
SELECT cat.categ_nombre AS categor�as, 
		(prod.precio_unitario * dord.cantidad) AS ingresos 
FROM dbo.detalle_orden dord
JOIN dbo.productos prod ON prod.id_prod = dord.id_prod
JOIN dbo.categorias cat ON cat.id_categ = prod.id_categ
)
SELECT  catin.categor�as, 
		SUM(catin.ingresos) AS ventas_total,
		ROUND(AVG(catin.ingresos),2) AS ventas_medias
FROM cat_ingresos catin
GROUP BY catin.categor�as;

	-- Otra forma con subconsultas

SELECT  catin.categor�as, 
		SUM(catin.ingresos) AS ventas_total,
		ROUND(AVG(catin.ingresos),2) AS ventas_medias
FROM (SELECT cat.categ_nombre AS categor�as, 
		(prod.precio_unitario * dord.cantidad) AS ingresos 
FROM dbo.detalle_orden dord
JOIN dbo.productos prod ON prod.id_prod = dord.id_prod
JOIN dbo.categorias cat ON cat.id_categ = prod.id_categ) catin
GROUP BY catin.categor�as;

------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------

-- Calcular las ventas medias y totales de cada productos.

WITH prod_ingresos AS(
SELECT prod.prod_nombre AS producto, 
		(prod.precio_unitario * dord.cantidad) AS ingresos 
FROM dbo.detalle_orden dord
JOIN dbo.productos prod ON prod.id_prod = dord.id_prod
)
SELECT  proding.producto, 
		SUM(proding.ingresos) AS ventas_total,
		ROUND(AVG(proding.ingresos),2) AS ventas_medias
FROM prod_ingresos proding
GROUP BY proding.producto;

------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------

-- Calcular las ventas totales de cada producto, identificar los productos 
-- con ventas totales superiores a la media y clasificar estos productos en 
-- funci�n de sus ventas totales.

WITH ventas_total  AS(
	SELECT prod.id_prod, 
	SUM(dord.cantidad * prod.precio_unitario) AS ingresos
	FROM dbo.detalle_orden dord
	JOIN dbo.productos prod ON dord.id_prod = prod.id_prod
	GROUP BY prod.id_prod
), 
media_ventas AS (
	SELECT AVG(ventotal.ingresos) AS media_ventas 
	FROM ventas_total ventotal
),
total_sea_superior_media AS(
	SELECT ventotal.id_prod, ventotal.ingresos AS total_ventas 
	FROM ventas_total ventotal
	WHERE ventotal.ingresos > (SELECT medi_ven.media_ventas 
								FROM media_ventas medi_ven)
)
SELECT tsm.id_prod, tsm.total_ventas, 
		RANK()OVER(ORDER BY tsm.total_ventas DESC) AS rank_ventas
FROM total_sea_superior_media tsm;

------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------

-- �Qu� clientes compraron una mayor cantidad de productos en 2024 
--  y que estos sean mayores a 20 unidades?

SELECT  total.id_cliente, total.nombre 
FROM (SELECT ord.id_cliente AS id_cliente,
	cli.cli_nombre_completo AS nombre, 
	SUM(dord.cantidad) AS cantidad
	FROM dbo.detalle_orden dord
	JOIN dbo.ordenes ord ON dord.id_orden = ord.id_orden
	JOIN dbo.clientes cli ON ord.id_cliente = cli.id_cliente
	WHERE ord.fecha_orden BETWEEN '2024-01-01' AND '2024-12-31'
	GROUP BY ord.id_cliente, cli.cli_nombre_completo) AS total
WHERE total.cantidad > 20;

------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------

-- Crea una vista materializada llamada sales_summary que agrega la 
-- cantidad total y los ingresos de cada producto.

CREATE VIEW resumen_ventas
WITH SCHEMABINDING
AS
SELECT cl.id_cliente AS cliente,
		SUM(dord.cantidad) AS cantidad,
		SUM(dord.cantidad * prod.precio_unitario) AS ingresos
FROM dbo.clientes cl
JOIN dbo.ordenes ord ON ord.id_cliente = cl.id_cliente
JOIN dbo.detalle_orden dord ON dord.id_orden = ord.id_orden
JOIN dbo.productos prod ON prod.id_prod = dord.id_prod
GROUP BY cl.id_cliente;
GO

-- �Qu� clientes compraron una mayor cantidad mayor a 15 y 
--  los ingresos sean  mayores a 5000?

SELECT reve.cliente 
FROM resumen_ventas reve
WHERE reve.cantidad >15 AND reve.ingresos >5000 

------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------

-- Hallar la cantidad de ordenes por cliente

SELECT cli.cli_nombre_completo AS cliente, 
	   COUNT(ord.id_orden) AS cantidad_ordenada 
FROM dbo.clientes cli
JOIN dbo.ordenes ord ON ord.id_cliente = cli.id_cliente
GROUP BY cli.cli_nombre_completo;

------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------

-- Hallar los ingresos obtendidos por cliente en el a�o 2025

SELECT TOP 100 * FROM dbo.detalle_orden

SELECT TOP 100 * FROM dbo.ordenes

SELECT TOP 100 * FROM dbo.productos

SELECT TOP 100 * FROM dbo.clientes

SELECT cli.cli_nombre_completo AS cliente,
	   SUM(prod.precio_unitario * deord.cantidad) AS ingresos
FROM dbo.clientes cli
JOIN dbo.ordenes ord ON ord.id_cliente = cli.id_cliente
JOIN dbo.detalle_orden deord ON deord.id_orden = ord.id_orden
JOIN dbo.productos prod ON prod.id_prod = deord.id_prod 
WHERE ord.fecha_orden >= '2025-01-01'
GROUP BY cli.cli_nombre_completo;

------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------

-- �Cu�ntos clientes de sexo femenino y masculino hay?

SELECT cli.cli_sexo AS sexo, 
	   COUNT(cli.id_cliente) AS cantidad_clientes  
FROM dbo.clientes cli
GROUP BY cli.cli_sexo;

------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------





 