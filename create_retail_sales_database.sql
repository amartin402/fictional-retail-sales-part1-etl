CREATE DATABASE RetailSalesOLTP;
GO

--Import the csv files in the folder "fictional_retail_sales_data".

USE RetailSalesOLTP
GO
--Add update_date columns to the following tables for etl use.
ALTER TABLE dbo.customers
ADD  update_date smalldatetime null;

UPDATE dbo.customers
SET update_date = GETDATE()

ALTER TABLE dbo.products
ADD  update_date smalldatetime null;

UPDATE dbo.products
SET update_date = GETDATE()
GO

PRINT 'update_date columns have been successfully created.'

--Create foreign key relationships.
-- Products -> Product Categories
ALTER TABLE products
ADD CONSTRAINT FK_Products_ProductCategories FOREIGN KEY (category_id)
REFERENCES product_categories (category_id);

-- Inventory -> Products
ALTER TABLE inventory
ADD CONSTRAINT FK_Inventory_Products FOREIGN KEY (product_id)
REFERENCES products (product_id);

-- Inventory -> Warehouses
ALTER TABLE inventory
ADD CONSTRAINT FK_Inventory_Warehouses FOREIGN KEY (warehouse_id)
REFERENCES warehouses (warehouse_id);

-- Orders -> Customers
ALTER TABLE orders
ADD CONSTRAINT FK_Orders_Customers FOREIGN KEY (customer_id)
REFERENCES customers (customer_id);

-- Orders -> Shippers
ALTER TABLE orders
ADD CONSTRAINT FK_Orders_Shippers FOREIGN KEY (shipping_id)
REFERENCES shippers (shipper_id);

-- Transactions -> Orders
ALTER TABLE transactions
ADD CONSTRAINT FK_Transactions_Orders FOREIGN KEY (order_id)
REFERENCES orders (order_id);

-- Transactions -> Products
ALTER TABLE transactions
ADD CONSTRAINT FK_Transactions_Products FOREIGN KEY (product_id)
REFERENCES products (product_id);
GO

PRINT 'All tables and foreign key relationships have been successfully created.'