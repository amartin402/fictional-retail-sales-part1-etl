# fictional-retail-sales-part1-etl

## Dataset Overview
The dataset was created using Python script that uses the pandas and faker libraries to generate a normalized dataset that simulates a general merchandise retail business. The script created eight interconnected CSV files, each representing an entity in a snowflake schema design. This design is highly normalized to reduce data redundancy, which is typical for OLTP systems.

## OLTP Snowflake schema design
<img
   src="https://github.com/amartin402/fictional-retail-sales-part1-etl/blob/main/oltp_retail_sales_snowflake_schema.png"
   title="OLTP Snowflake Schema" alt="SQLServer" width="300" height="300" />
   
There are eight csv files that can be imported to sql server and a sql script to create the foreign key relationships.
- customers.csv
- product_categories.csv
- products.csv
- warehouses.csv
- inventory.csv
- shippers.csv
- orders.csv
- transactions.csv

## Data warehouse Star schema design
<img
   src="https://github.com/amartin402/fictional-retail-sales-part1-etl/blob/main/dw_retail_sales_star_schema.png"
   title="Data warehouse Star Schema" alt="SQLServer" width="300" height="300" />

The normalized dataset serves as the source for demonstrating a transformation into a star schema data warehouse. The star schema denormalized the structure, optimize it for analytical queries, and enable efficient business intelligence reporting in tools like Power BI. This will involve creating a central fact_sales table and streamlined dimension tables (dim_customer, dim_product, dim_order, dim_date) by flattening and combining related normalized tables.

There are seven csv files with the prefix "data_warehouse" that can be imported to sql server and a sql script to create the foreign key relationships. Two of csv files ("table_admin","event_log") demostrate audit tracking of the ETL process.

## SSIS ETL pipeline process

Below is images of the ETL process and the audit tracking results from a successful run.

<img
   src="https://github.com/amartin402/fictional-retail-sales-part1-etl/blob/main/dw_retail_sales_dw_etl.png"
   title="SSIS ETL OLTP to OLAP" alt="SQLServer" width="300" height="300" />

<img
   src="https://github.com/amartin402/fictional-retail-sales-part1-etl/blob/main/dw_retail_sales_admin_before.png"
   title="Lineage audit admin table before run " alt="SQLServer" width="300" height="300" />

<img
   src="https://github.com/amartin402/fictional-retail-sales-part1-etl/blob/main/dw_retail_sales_admin_after.png"
   title="Lineage audit admin table after run " alt="SQLServer" width="300" height="300" />

  
