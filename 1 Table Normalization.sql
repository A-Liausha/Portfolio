CREATE TABLE dim_customer
(customer_id VARCHAR(50) PRIMARY KEY,
    customer_name VARCHAR(200),
    segment VARCHAR(50)
);

CREATE TABLE dim_location (
    location_id SERIAL PRIMARY KEY,
    city VARCHAR(100),
    state VARCHAR(100),
    region VARCHAR(50),
    iso3 VARCHAR(3),
    country VARCHAR(100),
    latitude DECIMAL(10,6),
    longitude DECIMAL(10,6),
    UNIQUE(city, state)
);
CREATE TABLE dim_product (
    product_id VARCHAR(50) PRIMARY KEY,
    product_name VARCHAR(500),
    sub_category VARCHAR(100),
    category VARCHAR(100)
);
CREATE TABLE dim_ship_mode (
    ship_mode_id SERIAL PRIMARY KEY,
    ship_mode VARCHAR(50) UNIQUE
);
CREATE TABLE fact_sales (
    primary_id int PRIMARY KEY,
    order_id int,
    order_date DATE,
    ship_date DATE,
    customer_id VARCHAR(50) REFERENCES dim_customer(customer_id),
    location_id INTEGER REFERENCES dim_location(location_id),
    product_id VARCHAR(50) REFERENCES dim_product(product_id),
    ship_mode_id INTEGER REFERENCES dim_ship_mode(ship_mode_id),
    quantity INTEGER,
   	discount NUMERIC(5,2),
	sales NUMERIC(15,2),
	profit NUMERIC(15,2),
	shipping_costs NUMERIC(15,2),
	storage_costs NUMERIC(15,2),
	personnel_cost NUMERIC(15,2),
	selling_costs NUMERIC(15,2),
	purchasing_costs NUMERIC(15,2)
);

INSERT INTO dim_customer (customer_id, customer_name, segment)
SELECT DISTINCT 
    "CustomerID", 
    "CustomerName", 
    "Segment"
FROM sac 
WHERE "CustomerID" IS NOT NULL;

INSERT INTO dim_location (city, state, region, iso3, country, latitude, longitude)
SELECT DISTINCT 
    "City", 
    "State", 
    "Region", 
    "ISO3", 
    "Country", 
    "Latitude", 
    "Longitude"
FROM sac 
WHERE "City" IS NOT NULL AND "State" IS NOT NULL;

INSERT INTO dim_product (product_id, product_name, sub_category, category)
SELECT DISTINCT 
    "ProductID", 
    "ProductName", 
    "SubCategory", 
    "Category"
FROM sac
WHERE "ProductID" IS NOT NULL;

INSERT INTO dim_ship_mode (ship_mode)
SELECT DISTINCT 
    "ShipMode"
FROM sac
WHERE "ShipMode" IS NOT NULL;

INSERT INTO fact_sales (
    primary_id,
    order_id,
    order_date,
    ship_date,
    customer_id,
    location_id,
    product_id,
    ship_mode_id,
    quantity,
    discount,
    sales,
    profit,
    shipping_costs,
    storage_costs,
    personnel_cost,
    selling_costs,
    purchasing_costs
)
SELECT 
    s."PrimaryID",
    s."OrderID",
    s."OrderDate",
    s."ShipDate",
    s."CustomerID",
    l.location_id,
    s."ProductID",
    sm.ship_mode_id,
    s."Quantity",
    s."Discount",
    s."Sales",
    s."Profit",
    s."ShippingCosts",
    s."StorageCosts",
    s."PersonnelCost",
    s."SellingCosts",
    s."PurchasingCosts"
FROM sac s
LEFT JOIN dim_location l ON l.city = s."City" AND l.state = s."State"
LEFT JOIN dim_ship_mode sm ON sm.ship_mode = s."ShipMode";

DELETE FROM fact_sales 
WHERE  order_date>ship_date