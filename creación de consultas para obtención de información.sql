
-- An�lisis de las tablas.

-- Cantidad de clientes por ciudad

SELECT cl.cli_ciudad AS ciudad, COUNT(cl.id_cliente) AS cantidad_clientes 
FROM dbo.clientes cl
GROUP BY cl.cli_ciudad;

-- Cantidad de productos seg�n categor�a

SELECT ct.id_categ, ct.categ_nombre AS 'categor�a', COUNT(*) AS 'cantidad_producto'
FROM dbo.productos pd
JOIN dbo.categorias ct ON ct.id_categ = pd.id_categ
GROUP BY ct.id_categ, ct.categ_nombre;

-- Mostrar los productos pertenecientes a las categor�as 
-- port�tiles y  tel�fonos

SELECT pd.id_prod, pd.id_categ FROM dbo.productos pd
WHERE pd.id_categ = 4
UNION ALL
SELECT pd.id_prod, pd.id_categ FROM dbo.productos pd
WHERE pd.id_categ = 5;

-- �Qu� cantidad de ordenes su total de venta es mayor a 700?

WITH total_vendida AS (SELECT do.id_detalle_orden, 
	   (do.cantidad * pd.precio_unitario) AS 'total_vendida'
FROM dbo.detalle_orden do
JOIN dbo.productos pd ON pd.id_prod = do.id_prod
)
SELECT  COUNT(tv.id_detalle_orden) AS 'cantidad de ordenes'
FROM total_vendida tv
WHERE tv.total_vendida > 700;







