-- Creación de tablas

DROP TABLE dbo.clientes;
DROP TABLE dbo.categorias;
DROP TABLE dbo. productos;
DROP TABLE dbo.ordenes;
DROP TABLE detalle_orden;

-- Tabla clientes

CREATE TABLE clientes (
	id_cliente INT PRIMARY KEY IDENTITY(1,1),
	cli_nombre_completo VARCHAR(100),
	cli_sexo Varchar(2),
	cli_email VARCHAR(100),
	cli_ciudad VARCHAR(50)
);

-- Tabla categorias

CREATE TABLE categorias(
	id_categ INT PRIMARY KEY IDENTITY(1,1),
	categ_nombre VARCHAR(100)
);

-- Tabla de productos

CREATE TABLE productos(
	id_prod INT PRIMARY KEY IDENTITY(1,1),
	id_categ INT REFERENCES categorias(id_categ),
	prod_nombre VARCHAR(60),
	precio_unitario DECIMAL(11,2)
);
 
-- SELECT * FROM productos



-- tabla ordenes 

CREATE TABLE ordenes (
	id_orden INT PRIMARY KEY IDENTITY(1,1),
	id_cliente INT REFERENCES clientes(id_cliente),
	fecha_orden DATE
);


-- Tabla detalle_ ordenes

CREATE TABLE detalle_orden (
	id_detalle_orden INT PRIMARY KEY IDENTITY(1,1),
	id_orden INT REFERENCES ordenes(id_orden),
	id_prod INT REFERENCES productos(id_prod),
	cantidad INT
);







