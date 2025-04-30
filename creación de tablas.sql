-- Creación de tablas

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
	prod_nombre VARCHAR(100),
	id_categ INT REFERENCES categorias(id_categ),
	precio DECIMAL(11,2),
	stock INT
);



-- Tabla de proveedores 

CREATE TABLE proveedores(
	id_proveedor INT PRIMARY KEY IDENTITY(1,1),
	prov_nombre_completo VARCHAR(100),
	prov_telefono VARCHAR(20),
	prov_ciudad VARCHAR(50)
); 


-- Tabla empleados

CREATE TABLE empleados(
	id_empleado INT PRIMARY KEY IDENTITY(1,1),
	emp_nombre VARCHAR(100),
	emp_cargo VARCHAR(50) DEFAULT 'vendedor',
	emp_correo VARCHAR(100),
	emp_fecha_ingreso DATE
);

-- tabla ordenes 

CREATE TABLE ordenes(
	id_orden INT PRIMARY KEY IDENTITY(1,1),
	id_cliente INT REFERENCES clientes(id_cliente),
	id_empleado INT REFERENCES empleados(id_empleado),
	fecha_orden DATE
);


-- Tabla detalle_ ordenes

CREATE TABLE detalle_ordenes(
	id_detalle_orden INT PRIMARY KEY IDENTITY(1,1),
	id_orden INT REFERENCES ordenes(id_orden),
	id_prod INT REFERENCES productos(id_prod),
	cantidad INT
);


-- Eliminación de tablas

DROP TABLE dbo.proveedores;
DROP TABLE dbo.empleados;
DROP TABLE dbo.clientes;
DROP TABLE dbo.categorias;
DROP TABLE dbo. productos;
DROP TABLE dbo.ordenes;
DROP TABLE detalle_ordenes;





