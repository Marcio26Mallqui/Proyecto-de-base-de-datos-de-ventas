-- Análisis de las tablas.

------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------

-- ¿Qué cantidad de clientes por ciudad?

SELECT cl.cli_ciudad AS ciudad, 
	   COUNT(cl.id_cliente) AS cantidad_clientes 
FROM dbo.clientes cl
GROUP BY cl.cli_ciudad;

------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------

-- ¿Qué cantidad de productos hay según la categoría?

SELECT ct.id_categ, ct.categ_nombre AS 'categoría', 
	   COUNT(*) AS 'cantidad_producto'
FROM dbo.productos pd
JOIN dbo.categorias ct ON ct.id_categ = pd.id_categ
GROUP BY ct.id_categ, ct.categ_nombre;

------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------

-- ¿Cuáles son los  productos que pertenecen  a las categorías 
--  portátiles y teléfonos?

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
-- que compró en año  de 2024, y esto se ha mayor de 1000. 

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


------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------

-- Calcular las ventas medias y totales de cada categoría 
-- de productos.

WITH cat_ingresos AS(
SELECT cat.categ_nombre AS categoría, 
		(prod.precio * dord.cantidad) AS ingresos 
FROM dbo.detalle_ordenes dord
JOIN dbo.productos prod ON prod.id_prod = dord.id_prod
JOIN dbo.categorias cat ON cat.id_categ = prod.id_categ
)
SELECT  catin.categoría, 
		SUM(catin.ingresos) AS venta_total,
		ROUND(AVG(catin.ingresos),2) AS venta_media
FROM cat_ingresos catin
GROUP BY catin.categoría;

	-- Otra forma con subconsultas

SELECT  catin.categoría, 
		SUM(catin.ingresos) AS venta_total,
		ROUND(AVG(catin.ingresos),2) AS venta_media
FROM (SELECT cat.categ_nombre AS categoría, 
		(prod.precio * dord.cantidad) AS ingresos 
FROM dbo.detalle_ordenes dord
JOIN dbo.productos prod ON prod.id_prod = dord.id_prod
JOIN dbo.categorias cat ON cat.id_categ = prod.id_categ) AS catin
GROUP BY catin.categoría;

------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------

-- Calcular las ventas medias y totales de cada productos.

WITH prod_ingresos AS(
SELECT prod.prod_nombre AS producto, 
		(prod.precio * dord.cantidad) AS ingresos 
FROM dbo.detalle_ordenes dord
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
-- función de sus ventas totales.

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
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
-- Otra forma




------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------

-- ¿Qué clientes compraron una mayor cantidad de productos en 2024 
--  y que estos sean mayores a 20 unidades?

SELECT  total.id_cliente, total.nombre 
FROM (SELECT ord.id_cliente AS id_cliente,
	cli.cli_nombre_completo AS nombre, 
	SUM(dord.cantidad) AS cantidad
	FROM dbo.detalle_ordenes dord
	JOIN dbo.ordenes ord ON dord.id_orden = ord.id_orden
	JOIN dbo.clientes cli ON ord.id_cliente = cli.id_cliente
	WHERE ord.fecha_orden BETWEEN '2024-01-01' AND '2024-12-31'
	GROUP BY ord.id_cliente, cli.cli_nombre_completo) AS total
WHERE total.cantidad > 50;

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

-- ¿Qué clientes compraron una mayor cantidad mayor a 15 y 
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

-- Hallar los ingresos obtendidos por cliente en el año 2025

SELECT TOP 100 * FROM dbo.detalle_orden

SELECT TOP 100 * FROM dbo.ordenes

SELECT TOP 100 * FROM dbo.productos

SELECT TOP 100 * FROM dbo.clientes

SELECT cli.cli_nombre_completo AS cliente,
	   SUM(prod.precio * deord.cantidad) AS ingresos
FROM dbo.clientes cli
JOIN dbo.ordenes ord ON ord.id_cliente = cli.id_cliente
JOIN dbo.detalle_ordenes deord ON deord.id_orden = ord.id_orden
JOIN dbo.productos prod ON prod.id_prod = deord.id_prod 
WHERE ord.fecha_orden >= '2025-01-01'
GROUP BY cli.cli_nombre_completo;

------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------

-- ¿Cuántos clientes de sexo femenino y masculino hay?

SELECT cli.cli_sexo AS sexo, 
	   COUNT(cli.id_cliente) AS cantidad_clientes  
FROM dbo.clientes cli
GROUP BY cli.cli_sexo;

------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------

-- ¿Cuáles son los 10 empleados que vendieron más productos?

SELECT  TOP 10 emp.emp_nombre AS empledo, 
		SUM(dord.cantidad) AS cantidad_vendida 
FROM dbo.ordenes ord
JOIN dbo.detalle_ordenes dord ON dord.id_orden = ord.id_orden
JOIN dbo.empleados emp ON emp.id_empleado = ord.id_empleado
GROUP BY emp.emp_nombre
ORDER BY SUM(dord.cantidad) DESC;

------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------

-- ¿Cuáles son los 10 productos más vendidos en cantidad?

SELECT TOP 10 prod.prod_nombre AS producto,
		SUM(dord.cantidad) AS cantidad_vendida
FROM dbo.productos prod
JOIN dbo.detalle_ordenes dord ON dord.id_prod = prod.id_prod
JOIN dbo.ordenes ord ON ord.id_orden = dord.id_orden
GROUP BY  prod.prod_nombre
ORDER BY SUM(dord.cantidad) DESC; 

------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------

-- ¿Qué 10 productos generan más ingresos?

SELECT TOP 10 prod.prod_nombre AS producto,
		SUM(prod.precio * dord.cantidad) AS Ingresos
FROM dbo.productos prod
JOIN dbo.detalle_ordenes dord ON dord.id_prod = prod.id_prod
JOIN dbo.ordenes ord ON ord.id_orden = dord.id_orden
GROUP BY  prod.prod_nombre
ORDER BY SUM(prod.precio * dord.cantidad) DESC;


------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
-- ¿Cuáles son las categorías que generan más ingresos?

SELECT cat.categ_nombre AS categoría, 
	   SUM(prod.precio * dord.cantidad) AS ingresos 
FROM dbo.categorias cat
JOIN dbo.productos prod ON prod.id_categ = cat.id_categ
JOIN dbo.detalle_ordenes dord ON dord.id_prod = prod.id_prod
GROUP BY cat.categ_nombre
ORDER BY ingresos DESC;

------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------

-- ¿Cuáles son los 10 clientes que realizaron mayor cantidad de órdenes?

SELECT TOP 10 cli.cli_nombre_completo AS cliente,  
	   COUNT(ord.id_orden) AS 'Cantidad de órdenes'
FROM dbo.clientes cli
JOIN dbo.ordenes ord ON ord.id_cliente = cli.id_cliente 
GROUP BY cli.cli_nombre_completo
ORDER BY COUNT(ord.id_cliente) DESC;

------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------

-- ¿Cómo ha sido la tendencia de ingresos mensuales por año?

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

SELECT YEAR(ord.fecha_orden) AS año,
		MONTH(ord.fecha_orden) AS mes,
		SUM(ing.ingresos) AS ingresos		
FROM dbo.dord_ord_ingresos ing
JOIN dbo.ordenes ord ON ord.id_orden = ing.id_orden
GROUP BY YEAR(ord.fecha_orden), MONTH(ord.fecha_orden)
ORDER BY año ASC, mes ASC;

------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------

-- Hallar los ingresos mensuales por empleado.

SELECT emp.emp_nombre AS empleado,
		YEAR(ord.fecha_orden) AS año,
		MONTH(ord.fecha_orden) AS mes,
		SUM(ing.ingresos) AS ingresos		
FROM dbo.dord_ord_ingresos ing
JOIN dbo.ordenes ord ON ord.id_orden = ing.id_orden
JOIN dbo.empleados emp ON emp.id_empleado = ord.id_empleado 
GROUP BY emp.emp_nombre, YEAR(ord.fecha_orden), MONTH(ord.fecha_orden)
ORDER BY año ASC, mes ASC;

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

-- ¿Quiénes son los 20 clientes que más compran en términos de ingresos?


SELECT TOP 20 ing.id_cliente,
		cli.cli_nombre_completo,
		ROUND(SUM(ing.ingresos),2) AS ingresos
FROM dbo.dord_ord_ingresos ing
JOIN dbo.clientes cli ON cli.id_cliente = ing.id_cliente
GROUP BY ing.id_cliente, cli.cli_nombre_completo
ORDER BY SUM(ing.ingresos) DESC;
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------

-- ¿Cuál es la compra media por cliente?

SELECT ROUND(AVG(cli_ing.ingresos), 2) AS 'compra media por cliente'
FROM (SELECT ing.id_cliente AS cliente, 
		ROUND(SUM(ing.ingresos),2) AS ingresos
FROM dbo.dord_ord_ingresos ing
GROUP BY ing.id_cliente) AS cli_ing;

------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------

-- ¿Cuál es el valor promedio por pedido?

SELECT ROUND(AVG(ord_ing.ingresos),2) AS 'valor promedio por pedido'
FROM (SELECT ing.id_orden AS id_orden, 
		ROUND(SUM(ing.ingresos),2) AS ingresos
FROM dbo.dord_ord_ingresos ing
GROUP BY ing.id_orden) AS ord_ing;

------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------





