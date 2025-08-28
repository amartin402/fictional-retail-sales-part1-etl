CREATE DATABASE RetailSalesDW;
GO

USE RetailSalesDW
GO

DROP TABLE dbo.TableAdmin

CREATE TABLE dbo.TableAdmin
(
RowId INT IDENTITY(1,1) NOT NULL, 
TableName VARCHAR(50) NOT NULL,
TableType VARCHAR(25) NULL,
LastUpdateDateTime VARCHAR(25) NULL, 
LastUpdateKey BIGINT NULL, 
NextLoadType CHAR(1) NOT NULL DEFAULT('F'), --F=Full, I=Incremental
RowCycleId INT NULL, 
UpdateDate SMALLDATETIME  NULL
)

INSERT INTO dbo.TableAdmin
(TableName, TableType, LastUpdateDateTime, LastUpdateKey, NextLoadType, RowCycleId, UpdateDate)
VALUES
('FactSales', 'Transactional', NULL, 0, 'F', NULL, NULL),
('DimCustomer', 'SCD Type 2', NULL, 0, 'F', NULL, NULL),
('DimProduct', 'Hierarchy', NULL, 0, 'F', NULL, NULL),
('DimOrder', NULL, NULL, 0, 'F', NULL, NULL),
('DimDate', 'Role-Playing', NULL, 0, 'F', NULL, NULL)

DROP TABLE dbo.EventLog

CREATE TABLE dbo.EventLog
(
RowId INT IDENTITY(1, 1), 
ProcessType VARCHAR(15) NULL, 
RowCycleId BIGINT NOT NULL, 
Package VARCHAR(75) NOT NULL, 
Container VARCHAR(75) NULL, 
EventDate SMALLDATETIME NOT NULL, 
CompletionDate SMALLDATETIME NULL,
RowsCount INT NULL,
Duration  AS (datediff(second, EventDate, CompletionDate)),
EventOutcome VARCHAR(15) NULL
)

DROP TABLE dbo.Sales_S

CREATE TABLE dbo.Sales_S
(
transaction_id INT NOT NULL,
transaction_date date NULL, 
order_id INT NULL,
customer_id INT NULL,
product_id INT NULL, 
quantity INT NULL, 
unit_price MONEY NULL, 
delivery_date DATE NULL,
)

DROP TABLE dbo.Customer_S

CREATE TABLE dbo.Customer_S
(
customer_id INT NOT NULL,
full_name VARCHAR(150) NULL,
email VARCHAR(250) NULL,
city VARCHAR(150) NULL,
_state VARCHAR(150) NULL,
country VARCHAR(150) NULL,
join_date DATE NULL,
is_loyal_customer BIT NULL,
update_date SMALLDATETIME NULL
)

DROP TABLE dbo.Product_S

CREATE TABLE dbo.Product_S
(
product_id INT NOT NULL,
product_name VARCHAR(150) NULL,
main_category VARCHAR(150) NULL,
subcategory VARCHAR(150) NULL,
unit_price MONEY NULL,
creation_date DATE NULL,
is_discontinued BIT NULL,
update_date SMALLDATETIME NULL
)

DROP TABLE dbo.Order_S

CREATE TABLE dbo.Order_S
(
order_id INT NOT NULL,
order_date DATE NULL,
shipper_name VARCHAR(150), 
service_level VARCHAR(150),
)
GO

PRINT 'All data warehouse admin and staging tables have been successfully created.'

CREATE SCHEMA dw

DROP TABLE dw.FactSales

CREATE TABLE dw.FactSales
(
TransactionsKey INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
BK_transaction_id INT NOT NULL,
TransactionDateKey INT NULL, 
CustomerKey INT NULL,
OrderKey INT NULL, 
ProductKey INT NULL, 
Quantity INT NULL, 
UnitPrice MONEY NULL, 
TotalSalesAmount as (Quantity * UnitPrice), 
DeliveryDays INT NULL,
RowCycleId INT NULL,
InsertDate SMALLDATETIME NULL
)

DROP TABLE dw.DimCustomer

CREATE TABLE dw.DimCustomer
(
CustomerKey INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
BK_customer_id INT NOT NULL,
FullName VARCHAR(150) NULL,
Email VARCHAR(250) NULL,
City VARCHAR(150) NULL,
_State VARCHAR(150) NULL,
Country VARCHAR(150) NULL,
JoinedDateKey INT NULL,
IsLoyalCustomer BIT NULL,
RowActiveStartDate SMALLDATETIME NOT NULL DEFAULT GETDATE(),
RowActiveEndDate SMALLDATETIME NULL,
RowIsActive BIT NOT NULL DEFAULT 0,
RowCycleId INT NULL,
RowUpdateCycleId INT NULL,
InsertDate SMALLDATETIME NULL,
UpdateDate SMALLDATETIME NULL
)

SET IDENTITY_INSERT dw.DimCustomer  ON;

INSERT INTO dw.DimCustomer 
(CustomerKey, BK_customer_id, FullName, Email, City, _State, Country, JoinedDateKey, IsLoyalCustomer, RowActiveStartDate, RowActiveEndDate, RowIsActive, RowCycleId, InsertDate)
VALUES 
(-1, -1, 'Unknown', 'Unknown', 'Unknown', 'Unknown', 'Unknown', '19000101', 0, '1900-01-01', NULL, 1, -1, GETDATE());

SET IDENTITY_INSERT dw.DimCustomer  OFF;

DROP TABLE dw.DimProduct

CREATE TABLE dw.DimProduct
(
ProductKey INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
BK_product_id INT NOT NULL,
ProductName VARCHAR(150) NULL,
MainCategory VARCHAR(150) NULL,
SubCategory VARCHAR(150) NULL,
UnitPrice MONEY NULL,
CreationDateKey INT NULL,
IsDiscontinued BIT NOT NULL DEFAULT 0, 
RowCycleId INT NULL,
RowUpdateCycleId INT NULL,
InsertDate SMALLDATETIME NULL,
UpdateDate SMALLDATETIME NULL
)

SET IDENTITY_INSERT dw.DimProduct  ON;

INSERT INTO dw.DimProduct 
(ProductKey, BK_product_id, ProductName, MainCategory, SubCategory, UnitPrice, CreationDateKey, IsDiscontinued, RowCycleId, InsertDate)
VALUES 
(-1, -1, 'Unknown', 'Unknown', 'Unknown', 0, '19000101', 0, -1, GETDATE());

SET IDENTITY_INSERT dw.DimProduct  OFF;

DROP TABLE dw.DimOrder

CREATE TABLE dw.DimOrder
(
OrderKey INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
BK_order_id INT NOT NULL,
OrderDateKey INT NOT NULL,
ShippingMethod VARCHAR(150) NULL,
ShipperName VARCHAR(150) NULL,
RowCycleId INT NULL,
RowUpdateCycleId INT NULL,
InsertDate SMALLDATETIME NULL,
UpdateDate SMALLDATETIME NULL
)

SET IDENTITY_INSERT dw.DimOrder  ON;

INSERT INTO dw.DimOrder 
(OrderKey, BK_order_id, OrderDateKey, ShippingMethod, ShipperName, RowCycleId, InsertDate)
VALUES 
(-1, -1, '19000101', 'Unknown', 'Unknown', -1, GETDATE());

SET IDENTITY_INSERT dw.DimOrder  OFF;


DROP TABLE dw.DimDate

CREATE TABLE dw.DimDate
(
DateKey INT NOT NULL PRIMARY KEY,
FullDate DATE  NULL,
DayOf_Week INT  NULL,
DayOf_Month INT  NULL,
_Month INT  NULL,
_MonthName VARCHAR(10)  NULL,
_Year INT  NULL,
_Quarter INT  NULL,
IsWeekend BIT  NULL DEFAULT 0,
RowCycleId INT NULL,
InsertDate SMALLDATETIME NULL
)

INSERT INTO dw.DimDate 
(DateKey, FullDate, DayOf_Week, DayOf_Month, _Month, _MonthName, _Year, _Quarter, IsWeekend, RowCycleId, InsertDate)
VALUES 
(-1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, -1, GETDATE());


-- Transactions -> Orders
ALTER TABLE dw.FactSales
ADD CONSTRAINT FK_FactSales_Order FOREIGN KEY (OrderKey)
REFERENCES dw.DimOrder (OrderKey);

-- Transactions -> Products
ALTER TABLE dw.FactSales
ADD CONSTRAINT FK_FactSales_Product FOREIGN KEY (ProductKey)
REFERENCES dw.DimProduct (ProductKey);

-- Transactions -> Customers
ALTER TABLE dw.FactSales
ADD CONSTRAINT FK_FactSales_Customer FOREIGN KEY (CustomerKey)
REFERENCES dw.DimCustomer (CustomerKey);
GO

PRINT 'All data warehouse staging tables have been successfully created.'