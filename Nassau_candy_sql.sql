create table nassau_canday(
Row_ID unique int ,
Order_ID unique varchar(30),
Order_Date date,
Ship_Date date,
Ship_Mode varchar(100),
Customer_ID int,
Country_Region varchar(100),
City varchar(100),
State_rovince varchar(100),
Postal_Code varchar(100),
Division varchar(100),
Region varchar(100),
Product_ID varchar(100),
Product_Name varchar(100),
Sales numeric(10,2),
Units int,
Gross_Profit numeric(10,2),
Cost numeric(10,2)
);


-- 
select* from nassau_canday;

-- Dataset mein total records count karna
SELECT COUNT(*) AS total_records
FROM nassau_candy;

-- Check karna ki Row ID duplicate to nahi hai
SELECT
    "Row ID",
    COUNT(*) AS duplicate_count
FROM nassau_candy
GROUP BY "Row ID"
HAVING COUNT(*) > 1;

-- Important columns mein missing values check karna
SELECT
    COUNT(*) FILTER (WHERE "Order ID" IS NULL) AS missing_order_id,
    COUNT(*) FILTER (WHERE "Order Date" IS NULL) AS missing_order_date,
    COUNT(*) FILTER (WHERE "Ship Date" IS NULL) AS missing_ship_date,
    COUNT(*) FILTER (WHERE "Product Name" IS NULL) AS missing_product,
    COUNT(*) FILTER (WHERE "Sales" IS NULL) AS missing_sales,
    COUNT(*) FILTER (WHERE "Gross Profit" IS NULL) AS missing_profit,
    COUNT(*) FILTER (WHERE "Cost" IS NULL) AS missing_cost
FROM nassau_candy;

-- Main business KPIs calculate karna
SELECT
    ROUND(SUM("Sales")::numeric, 2) AS total_sales,
    ROUND(SUM("Gross Profit")::numeric, 2) AS total_gross_profit,
    SUM("Units") AS total_units,
    COUNT(DISTINCT "Order ID") AS total_orders,
    COUNT(DISTINCT "Customer ID") AS unique_customers,
    ROUND(
        100.0 * SUM("Gross Profit") / NULLIF(SUM("Sales"), 0),
        2
    ) AS profit_margin_percent
FROM nassau_candy;

-- Kaunsa region sales aur profit mein best perform kar raha hai?
SELECT
    "Region",
    ROUND(SUM("Sales")::numeric, 2) AS total_sales,
    ROUND(SUM("Gross Profit")::numeric, 2) AS total_profit,
    SUM("Units") AS total_units,
    ROUND(
        100.0 * SUM("Gross Profit") / NULLIF(SUM("Sales"), 0),
        2
    ) AS profit_margin_percent
FROM nassau_candy
GROUP BY "Region"
ORDER BY total_profit DESC;


-- Business divisions ko sales aur profit ke basis par compare karna
SELECT
    "Division",
    ROUND(SUM("Sales")::numeric, 2) AS total_sales,
    ROUND(SUM("Gross Profit")::numeric, 2) AS total_profit,
    SUM("Units") AS total_units
FROM nassau_candy
GROUP BY "Division"
ORDER BY total_profit DESC;


-- Sabse zyada gross profit dene wale top 10 products
SELECT
    "Product Name",
    SUM("Units") AS units_sold,
    ROUND(SUM("Sales")::numeric, 2) AS total_sales,
    ROUND(SUM("Gross Profit")::numeric, 2) AS total_profit,
    ROUND(
        100.0 * SUM("Gross Profit") / NULLIF(SUM("Sales"), 0),
        2
    ) AS profit_margin_percent
FROM nassau_candy
GROUP BY "Product Name"
ORDER BY total_profit DESC
LIMIT 10;

-- Aise products identify karna jinki sales achhi hai,
-- lekin profit margin comparatively low hai
WITH product_performance AS (
    SELECT
        "Product Name",
        SUM("Sales") AS total_sales,
        SUM("Gross Profit") AS total_profit
    FROM nassau_candy
    GROUP BY "Product Name"
)
SELECT
    "Product Name",
    ROUND(total_sales::numeric, 2) AS total_sales,
    ROUND(total_profit::numeric, 2) AS total_profit,
    ROUND(
        100.0 * total_profit / NULLIF(total_sales, 0),
        2
    ) AS profit_margin_percent
FROM product_performance
WHERE total_sales > 0
ORDER BY profit_margin_percent ASC
LIMIT 10;


-- Har shipping mode ka average aur maximum dispatch lead time
SELECT
    "Ship Mode",
    COUNT(*) AS total_records,
    ROUND(
        AVG(("Ship Date" - "Order Date")::numeric), 2
    ) AS avg_lead_time_days,
    MIN("Ship Date" - "Order Date") AS min_lead_time_days,
    MAX("Ship Date" - "Order Date") AS max_lead_time_days
FROM nassau_candy
WHERE "Order Date" IS NOT NULL
  AND "Ship Date" IS NOT NULL
GROUP BY "Ship Mode"
ORDER BY avg_lead_time_days;


-- 30 din se zyada dispatch lead time wale records investigate karna
SELECT
    "Order ID",
    "Order Date",
    "Ship Date",
    "Ship Mode",
    "Region",
    "City",
    "Product Name",
    ("Ship Date" - "Order Date") AS lead_time_days
FROM nassau_candy
WHERE "Order Date" IS NOT NULL
  AND "Ship Date" IS NOT NULL
  AND ("Ship Date" - "Order Date") > 30
ORDER BY lead_time_days DESC;


-- Kis region mein kaunsa shipping mode zyada lead time le raha hai?
SELECT
    "Region",
    "Ship Mode",
    COUNT(*) AS order_records,
    ROUND(
        AVG(("Ship Date" - "Order Date")::numeric), 2
    ) AS avg_lead_time_days,
    SUM("Sales") AS total_sales,
    SUM("Gross Profit") AS total_profit
FROM nassau_candy
WHERE "Order Date" IS NOT NULL
  AND "Ship Date" IS NOT NULL
GROUP BY "Region", "Ship Mode"
ORDER BY "Region", avg_lead_time_days DESC;


-- Har month ki sales aur profit trend nikalna
SELECT
    DATE_TRUNC('month', "Order Date")::date AS order_month,
    ROUND(SUM("Sales")::numeric, 2) AS monthly_sales,
    ROUND(SUM("Gross Profit")::numeric, 2) AS monthly_profit,
    SUM("Units") AS monthly_units
FROM nassau_candy
WHERE "Order Date" IS NOT NULL
GROUP BY DATE_TRUNC('month', "Order Date")::date
ORDER BY order_month;


-- High-demand aur high-profit cities identify karna
SELECT
    "Region",
    "State/Province",
    "City",
    COUNT(DISTINCT "Order ID") AS total_orders,
    SUM("Units") AS units_sold,
    ROUND(SUM("Sales")::numeric, 2) AS total_sales,
    ROUND(SUM("Gross Profit")::numeric, 2) AS total_profit
FROM nassau_candy
GROUP BY
    "Region",
    "State/Province",
    "City"
ORDER BY total_profit DESC
LIMIT 20;


-- Negative gross profit wale records identify karna
SELECT
    "Order ID",
    "Region",
    "City",
    "Product Name",
    "Sales",
    "Cost",
    "Gross Profit"
FROM nassau_candy
WHERE "Gross Profit" < 0
ORDER BY "Gross Profit" ASC;

-- Text dates ko actual dates mein convert karna
SELECT
    TO_DATE("Order Date", 'DD-MM-YYYY') AS order_date,
    TO_DATE("Ship Date", 'DD-MM-YYYY') AS ship_date
FROM nassau_candy
LIMIT 10;