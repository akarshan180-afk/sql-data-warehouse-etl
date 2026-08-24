/*
Create Database And Schemas
Script Purpose:
This script creates a new database named 'DataWareHouse' after checking if it already exists or not .
If database exists it drops the database and if it not exists it cretas a new database.

Warning :
Running these script will drop entire data base named 'DataWareHouse' if existes.

*/








USE master;
GO

IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
    ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouse;
END;
GO

CREATE DATABASE DataWarehouse;
GO

USE DataWarehouse;
GO

CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
GO
