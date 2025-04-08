
-- Análisis de las tablas.

-- Cantidad de clientes por ciudad

SELECT cl.cli_ciudad AS ciudad, COUNT(cl.id_cliente) AS cantidad_clientes 
FROM dbo.clientes cl
GROUP BY cl.cli_ciudad;

-- Cantidad de productos según categoría

SELECT ct.id_categ, ct.categ_nombre AS 'categoría', COUNT(*) AS 'cantidad_producto'
FROM dbo.productos pd
JOIN dbo.categorias ct ON ct.id_categ = pd.id_categ
GROUP BY ct.id_categ, ct.categ_nombre;

-- Mostrar los productos pertenecientes a las categorías 
-- portátiles y  teléfonos

SELECT pd.id_prod, pd.id_categ FROM dbo.productos pd
WHERE pd.id_categ = 4
UNION ALL
SELECT pd.id_prod, pd.id_categ FROM dbo.productos pd
WHERE pd.id_categ = 5;

-- Hallar los ingresos totales generados por cada cliente que 
-- compró en 2024, y esto se han mayor de 1000. 

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
		dord.cantidad, prod.precio_unitario  
FROM dbo.ordenes ord
JOIN dbo.detalle_orden dord ON dord.id_orden = ord.id_orden
JOIN dbo.productos prod ON prod.id_prod = dord.id_prod
WHERE (ord.fecha_orden >= '2024-01-01') AND (ord.fecha_orden < '2025-01-01')
)
SELECT cpc2024.id_cliente AS cliente, 
	  SUM(cpc2024.cantidad * cpc2024.precio_unitario) AS ingresos
FROM cliente_precio_cantidad_2024 cpc2024
GROUP BY cpc2024.id_cliente
HAVING SUM(cpc2024.cantidad * cpc2024.precio_unitario) > 1000;


-- Calcular las ventas medias y totales de cada categoría de productos.

WITH cat_ingresos AS(
SELECT cat.categ_nombre AS categorías, 
		(prod.precio_unitario * dord.cantidad) AS ingresos 
FROM dbo.detalle_orden dord
JOIN dbo.productos prod ON prod.id_prod = dord.id_prod
JOIN dbo.categorias cat ON cat.id_categ = prod.id_categ
)
SELECT  catin.categorías, 
		SUM(catin.ingresos) AS ventas_total,
		AVG(catin.ingresos) AS ventas_medias
FROM cat_ingresos catin
GROUP BY catin.categorías;

	-- Otra forma con subconsultas

SELECT  catin.categorías, 
		SUM(catin.ingresos) AS ventas_total,
		AVG(catin.ingresos) AS ventas_medias
FROM (SELECT cat.categ_nombre AS categorías, 
		(prod.precio_unitario * dord.cantidad) AS ingresos 
FROM dbo.detalle_orden dord
JOIN dbo.productos prod ON prod.id_prod = dord.id_prod
JOIN dbo.categorias cat ON cat.id_categ = prod.id_categ) catin
GROUP BY catin.categorías;

-- Calcular las ventas totales de cada producto, identificar los productos 
-- con ventas totales superiores a la media y clasificar estos productos en 
-- función de sus ventas totales.

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

-- ¿Qué cliente compro mayor cantidad de productos en 2024 
-- y que estos sean mayor a 30?

SELECT  total.cliente 
FROM (SELECT ord.id_cliente AS cliente,  
	SUM(dord.cantidad) AS cantidad
	FROM dbo.detalle_orden dord
	JOIN dbo.ordenes ord ON dord.id_orden = ord.id_orden
	WHERE ord.fecha_orden BETWEEN '2024-01-01' AND '2024-12-31'
	GROUP BY ord.id_cliente) AS total
WHERE total.cantidad > 30;





