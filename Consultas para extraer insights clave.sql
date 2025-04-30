-- An�lisis de las tablas.

------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------

-- �Cu�les son los 10 empleados que vendieron m�s productos?

SELECT  TOP 10 emp.emp_nombre AS empledo, 
		SUM(dord.cantidad) AS cantidad_vendida 
FROM dbo.ordenes ord
JOIN dbo.detalle_ordenes dord ON dord.id_orden = ord.id_orden
JOIN dbo.empleados emp ON emp.id_empleado = ord.id_empleado
GROUP BY emp.emp_nombre
ORDER BY SUM(dord.cantidad) DESC;

-------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------

-- �Cu�les son los 10 productos m�s vendidos en cantidad?

SELECT TOP 10 prod.prod_nombre AS producto,
		SUM(dord.cantidad) AS cantidad_vendida
FROM dbo.productos prod
JOIN dbo.detalle_ordenes dord ON dord.id_prod = prod.id_prod
JOIN dbo.ordenes ord ON ord.id_orden = dord.id_orden
GROUP BY  prod.prod_nombre
ORDER BY SUM(dord.cantidad) DESC;

-------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------

-- �Cu�les son los 10 productos que generan m�s ingresos?

SELECT TOP 10 prod.prod_nombre AS producto,
		SUM(prod.precio * dord.cantidad) AS Ingresos
FROM dbo.productos prod
JOIN dbo.detalle_ordenes dord ON dord.id_prod = prod.id_prod
JOIN dbo.ordenes ord ON ord.id_orden = dord.id_orden
GROUP BY  prod.prod_nombre
ORDER BY SUM(prod.precio * dord.cantidad) DESC;

-------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------

-- �Cu�les son las categor�as que generan m�s ingresos?

SELECT cat.categ_nombre AS categor�a, 
	   SUM(prod.precio * dord.cantidad) AS ingresos 
FROM dbo.categorias cat
JOIN dbo.productos prod ON prod.id_categ = cat.id_categ
JOIN dbo.detalle_ordenes dord ON dord.id_prod = prod.id_prod
GROUP BY cat.categ_nombre
ORDER BY ingresos DESC;

-------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------

-- �Cu�les son los 10 clientes que realizaron mayor cantidad de �rdenes?

SELECT TOP 10 cli.cli_nombre_completo AS cliente,  
	   COUNT(ord.id_orden) AS 'Cantidad de �rdenes'
FROM dbo.clientes cli
JOIN dbo.ordenes ord ON ord.id_cliente = cli.id_cliente 
GROUP BY cli.cli_nombre_completo
ORDER BY COUNT(ord.id_cliente) DESC;

-------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
-- �C�mo ha sido la tendencia de ingresos mensuales por a�o?

-- Crea una vista materializada llamada dord_ord_ingresos
CREATE VIEW dord_ord_ingresos
WITH SCHEMABINDING
AS
SELECT dord.id_detalle_orden, 
		ord.id_orden,
		ord.id_cliente,
		dord.id_prod,
		prod.precio * dord.cantidad AS ingresos
FROM dbo.productos prod
JOIN dbo.detalle_ordenes dord ON dord.id_prod = prod.id_prod
JOIN dbo.ordenes ord ON ord.id_orden = dord.id_orden;
GO

SELECT YEAR(ord.fecha_orden) AS a�o,
		MONTH(ord.fecha_orden) AS mes,
		SUM(ing.ingresos) AS ingresos		
FROM dbo.dord_ord_ingresos ing
JOIN dbo.ordenes ord ON ord.id_orden = ing.id_orden
GROUP BY YEAR(ord.fecha_orden), MONTH(ord.fecha_orden)
ORDER BY a�o ASC, mes ASC;

-------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------

-- Hallar los ingresos mensuales por empleado.

SELECT emp.emp_nombre AS empleado,
		YEAR(ord.fecha_orden) AS a�o,
		MONTH(ord.fecha_orden) AS mes,
		SUM(ing.ingresos) AS ingresos		
FROM dbo.dord_ord_ingresos ing
JOIN dbo.ordenes ord ON ord.id_orden = ing.id_orden
JOIN dbo.empleados emp ON emp.id_empleado = ord.id_empleado 
GROUP BY emp.emp_nombre, YEAR(ord.fecha_orden), MONTH(ord.fecha_orden)
ORDER BY a�o ASC, mes ASC;

-------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------

-- �Cu�l es la compra media por cliente?

SELECT ROUND(AVG(cli_ing.ingresos), 2) AS 'compra media por cliente'
FROM (SELECT ing.id_cliente AS cliente, 
		ROUND(SUM(ing.ingresos),2) AS ingresos
FROM dbo.dord_ord_ingresos ing
GROUP BY ing.id_cliente) AS cli_ing;

-------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------

-- �Cu�l es el valor promedio por pedido?

SELECT ROUND(AVG(ord_ing.ingresos),2) AS 'valor promedio por pedido'
FROM (SELECT ing.id_orden AS id_orden, 
		ROUND(SUM(ing.ingresos),2) AS ingresos
FROM dbo.dord_ord_ingresos ing
GROUP BY ing.id_orden) AS ord_ing;

-------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------

-- Calcular las ventas medias y totales de cada categor�a.


WITH cat_ingresos AS(
SELECT cat.categ_nombre AS categor�a, 
		(prod.precio * dord.cantidad) AS ingresos 
FROM dbo.detalle_ordenes dord
JOIN dbo.productos prod ON prod.id_prod = dord.id_prod
JOIN dbo.categorias cat ON cat.id_categ = prod.id_categ
)
SELECT  catin.categor�a, 
		SUM(catin.ingresos) AS venta_total,
		ROUND(AVG(catin.ingresos),2) AS venta_media
FROM cat_ingresos catin
GROUP BY catin.categor�a;

-------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------

-- Hallar los ingresos totales generados por cada cliente que compr� 
-- en a�o  de 2024, y esto ser� mayor de 1500000.

WITH cliente_precio_cantidad_2024 AS(
SELECT ord.id_cliente,
		dord.cantidad, 
		prod.precio
FROM dbo.ordenes ord
JOIN dbo.detalle_ordenes dord ON dord.id_orden = ord.id_orden
JOIN dbo.productos prod ON prod.id_prod = dord.id_prod
WHERE ord.fecha_orden BETWEEN '2024-01-01' AND '2024-12-31'
)
SELECT cli.cli_nombre_completo AS cliente, 
	  SUM(cpc2024.cantidad * cpc2024.precio) AS ingresos
FROM cliente_precio_cantidad_2024 cpc2024
JOIN dbo.clientes cli ON cpc2024.id_cliente = cli.id_cliente
GROUP BY cli.cli_nombre_completo 
HAVING SUM(cpc2024.cantidad * cpc2024.precio) > 1500000
ORDER BY ingresos DESC;

-------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------

-- Hallar a los 10 clientes que m�s compran en t�rminos de ingresos en 
-- el a�o 2025.

SELECT TOP 10 cli.cli_nombre_completo AS cliente,
	   SUM(prod.precio * deord.cantidad) AS ingresos
FROM dbo.clientes cli
JOIN dbo.ordenes ord ON ord.id_cliente = cli.id_cliente
JOIN dbo.detalle_ordenes deord ON deord.id_orden = ord.id_orden
JOIN dbo.productos prod ON prod.id_prod = deord.id_prod 
WHERE ord.fecha_orden >= '2025-01-01'
GROUP BY cli.cli_nombre_completo
ORDER BY SUM(prod.precio * deord.cantidad) DESC;

-------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------

-- Calcular las ventas totales de cada producto, identificar los productos con ventas 
-- totales superiores a la media y clasificar estos productos en funci�n de sus ventas totales.

WITH ventas_total  AS(
	SELECT prod.id_prod, 
	SUM(dord.cantidad * prod.precio) AS ingresos
	FROM dbo.detalle_ordenes dord
	JOIN dbo.productos prod ON dord.id_prod = prod.id_prod
	GROUP BY prod.id_prod
), 
media_ventas AS (
	SELECT AVG(ventotal.ingresos) AS media_ventas 
	FROM ventas_total ventotal
),
total_sea_superior_media AS(
	SELECT ventotal.id_prod, ventotal.ingresos AS total_ventas 
	FROM ventas_total AS ventotal
	WHERE ventotal.ingresos > (SELECT medi_ven.media_ventas 
								FROM media_ventas medi_ven)
)
SELECT tsm.id_prod AS id_producto, tsm.total_ventas AS venta_total, 
		RANK()OVER(ORDER BY tsm.total_ventas DESC) AS rank_ventas
FROM total_sea_superior_media tsm;







