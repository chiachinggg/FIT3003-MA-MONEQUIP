-- Newly created tables during data cleaning phase: 
-- CUSTOMER, HIRE, EQUIPMENT, SALES, CATEGORY

-- SALES_PRICE_SCALE Dimension

CREATE TABLE SALES_PRICE_SCALE_DIM
    (
        Sales_Price_Scale_ID NUMBER(5),
        Sales_Price_Scale_Description VARCHAR2(50)
    );

-- Insert records into SALES_PRICE_SCALE Dimension

INSERT INTO SALES_PRICE_SCALE_DIM VALUES (1, 'Low sales < $5,000');
INSERT INTO SALES_PRICE_SCALE_DIM VALUES (2, 'Medium sales between $5,000 and $10,000');
INSERT INTO SALES_PRICE_SCALE_DIM VALUES (3, 'High sales > $10,000');

-- SEASON Dimension

CREATE TABLE SEASON_DIM
    (
        Season_ID NUMBER(1),
        Season_Description VARCHAR2(30)
    );

-- Insert records into SEASON Dimension

INSERT INTO SEASON_DIM VALUES (1, 'Spring: Sep to Nov');
INSERT INTO SEASON_DIM VALUES (2, 'Summer: Dec to Feb');
INSERT INTO SEASON_DIM VALUES (3, 'Autumn: Mar to May');
INSERT INTO SEASON_DIM VALUES (4, 'Winter: Jun to Aug');

-- COMPANY_BRANCH Dimension

CREATE TABLE COMPANY_BRANCH_DIM AS
    SELECT DISTINCT Company_Branch AS Company_Branch_Name
    FROM MONEQUIP.STAFF
    ORDER BY Company_Branch_Name;
    

-- Temporary TIME Dimension

CREATE TABLE TIME_DIM_TEMP
(
    TIme_ID VARCHAR2(6)
);

-- Insert records into temporary TIME Dimension

INSERT INTO TIME_DIM_TEMP
SELECT DISTINCT TO_CHAR(Sales_Date, 'YYYYMM') AS Time_ID
FROM SALES;

INSERT INTO TIME_DIM_TEMP
SELECT DISTINCT TO_CHAR(Start_Date, 'YYYYMM') AS Time_ID
FROM HIRE;

-- TIME Dimension

CREATE TABLE TIME_DIM 
(
    Iime_ID VARCHAR2(6),
    Month VARCHAR2(2),
    Year VARCHAR2(4)
);

-- Insert records into TIME Dimension

INSERT INTO TIME_DIM
SELECT 
    DISTINCT Time_ID,
    TO_CHAR(TO_DATE(Time_ID, 'YYYYMM'), 'MM'),
    TO_CHAR(TO_DATE(Time_ID, 'YYYYMM'), 'YYYY')
FROM TIME_DIM_TEMP;

-- CUSTOMER_TYPE Dimension

CREATE TABLE CUSTOMER_TYPE_DIM AS
    SELECT *
    FROM MONEQUIP.CUSTOMER_TYPE
    ORDER BY CUSTOMER_TYPE_ID;
    
-- Rename the attribute

ALTER TABLE CUSTOMER_TYPE_DIM
RENAME COLUMN Description TO Customer_Type_Description;

-- CATEGORY Dimension

CREATE TABLE CATEGORY_DIM AS
    SELECT *
    FROM CATEGORY
    ORDER BY CATEGORY_ID;

-- MON_EQUIP_SALES Temporary Fact Table V1

CREATE TABLE MON_EQUIP_SALES_FACT_TEMP_V1 AS
    SELECT 
        TO_CHAR(S.Sales_Date, 'YYYYMM') AS Time_ID,
        C.Customer_Type_ID,
        F.Company_Branch AS Company_Branch_Name,
        Y.Category_ID,
        S.Total_Sales_Price,
        S.Sales_ID,
        S.Quantity
    FROM 
        SALES S,
        CUSTOMER C, 
        MONEQUIP.STAFF F,
        EQUIPMENT E,
        CATEGORY Y
    WHERE 
        S.Customer_ID = C.Customer_ID AND
        S.Staff_ID = F.Staff_ID AND
        S.Equipment_ID = E.Equipment_ID AND
        E.Category_ID = Y.Category_ID;
        
-- Add new attributes

ALTER TABLE MON_EQUIP_SALES_FACT_TEMP_V1
ADD (Season_ID NUMBER(1));

ALTER TABLE MON_EQUIP_SALES_FACT_TEMP_V1 
ADD (Sales_Price_Scale_ID NUMBER(10));

-- Update value of new attribute (Season_ID)

UPDATE MON_EQUIP_SALES_FACT_TEMP_V1
SET Season_ID = 1 
WHERE TO_CHAR(TO_DATE(Time_ID, 'YYYYMM'), 'MM') >= '09' AND
    TO_CHAR(TO_DATE(Time_ID, 'YYYYMM'), 'MM') <= '11';

UPDATE MON_EQUIP_SALES_FACT_TEMP_V1
SET Season_ID = 2 
WHERE TO_CHAR(TO_DATE(Time_ID, 'YYYYMM'), 'MM') = '12' OR
    TO_CHAR(TO_DATE(Time_ID, 'YYYYMM'), 'MM') = '01' OR
    TO_CHAR(TO_DATE(Time_ID, 'YYYYMM'), 'MM') = '02';

UPDATE MON_EQUIP_SALES_FACT_TEMP_V1
SET Season_ID = 3
WHERE TO_CHAR(TO_DATE(Time_ID, 'YYYYMM'), 'MM') >= '03' AND
    TO_CHAR(TO_DATE(Time_ID, 'YYYYMM'), 'MM') <= '05';
    
UPDATE MON_EQUIP_SALES_FACT_TEMP_V1
SET Season_ID = 4
WHERE TO_CHAR(TO_DATE(Time_ID, 'YYYYMM'), 'MM') >= '06' AND
    TO_CHAR(TO_DATE(Time_ID, 'YYYYMM'), 'MM') <= '08';
    
-- Update value of new attribute (Sales_Price_Scale_ID)

UPDATE MON_EQUIP_SALES_FACT_TEMP_V1
SET Sales_Price_Scale_ID = 1
WHERE Total_Sales_Price < 5000;

UPDATE MON_EQUIP_SALES_FACT_TEMP_V1
SET Sales_Price_Scale_ID = 2
WHERE Total_Sales_Price >= 5000 AND Total_Sales_Price <= 10000;
        
UPDATE MON_EQUIP_SALES_FACT_TEMP_V1
SET Sales_Price_Scale_ID = 3
WHERE Total_Sales_Price > 10000;

-- MON_EQUIP_SALES Fact Table V1

CREATE TABLE MON_EQUIP_SALES_FACT_V1 AS
    SELECT
        Time_ID,
        Season_ID,
        Customer_Type_ID,
        Company_Branch_Name,
        Category_ID,
        Sales_Price_Scale_ID,
        SUM(Total_Sales_Price) AS Total_Sales_Revenue,
        COUNT(Sales_ID) AS Total_Number_of_Sales,
        SUM(Quantity) AS Total_Equipment_Sold
    FROM
        MON_EQUIP_SALES_FACT_TEMP_V1
    GROUP BY
        Time_ID,
        Season_ID,
        Customer_Type_ID,
        Company_Branch_Name,
        Category_ID,
        Sales_Price_Scale_ID;
    
-- MON_EQUIP_HIRE Temporary Fact Table V1

CREATE TABLE MON_EQUIP_HIRE_FACT_TEMP_V1 AS
    SELECT 
        TO_CHAR(H.Start_Date, 'YYYYMM') AS Time_ID,
        C.Customer_Type_ID,
        F.Company_Branch AS Company_Branch_Name,
        Y.Category_ID,
        H.Total_Hire_Price,
        H.Hire_ID,
        H.Quantity
    FROM 
        HIRE H,
        CUSTOMER C, 
        MONEQUIP.STAFF F,
        EQUIPMENT E,
        CATEGORY Y
    WHERE 
        H.Customer_ID = C.Customer_ID AND
        H.Staff_ID = F.Staff_ID AND
        H.Equipment_ID = E.Equipment_ID AND
        E.Category_ID = Y.Category_ID;
        
-- Add new attributes

ALTER TABLE MON_EQUIP_HIRE_FACT_TEMP_V1
ADD (Season_ID NUMBER(1));

-- Update value of new attribute (Season_ID)

UPDATE MON_EQUIP_HIRE_FACT_TEMP_V1
SET Season_ID = 1 
WHERE TO_CHAR(TO_DATE(Time_ID, 'YYYYMM'), 'MM') >= '09' AND
    TO_CHAR(TO_DATE(Time_ID, 'YYYYMM'), 'MM') <= '11';

UPDATE MON_EQUIP_HIRE_FACT_TEMP_V1
SET Season_ID = 2 
WHERE TO_CHAR(TO_DATE(Time_ID, 'YYYYMM'), 'MM') = '12' OR
    TO_CHAR(TO_DATE(Time_ID, 'YYYYMM'), 'MM') = '01' OR
    TO_CHAR(TO_DATE(Time_ID, 'YYYYMM'), 'MM') = '02';

UPDATE MON_EQUIP_HIRE_FACT_TEMP_V1
SET Season_ID = 3
WHERE TO_CHAR(TO_DATE(Time_ID, 'YYYYMM'), 'MM') >= '03' AND
    TO_CHAR(TO_DATE(Time_ID, 'YYYYMM'), 'MM') <= '05';
    
UPDATE MON_EQUIP_HIRE_FACT_TEMP_V1
SET Season_ID = 4
WHERE TO_CHAR(TO_DATE(Time_ID, 'YYYYMM'), 'MM') >= '06' AND
    TO_CHAR(TO_DATE(Time_ID, 'YYYYMM'), 'MM') <= '08';

-- MON_EQUIP_HIRE Fact Table V1

CREATE TABLE MON_EQUIP_HIRE_FACT_V1 AS
    SELECT
        Time_ID,
        Season_ID,
        Customer_Type_ID,
        Company_Branch_Name,
        Category_ID,
        SUM(Total_Hire_Price) AS Total_Hire_Revenue,
        COUNT(Hire_ID) AS Total_Number_of_Hire,
        SUM(Quantity) AS Total_Equipment_Hired
    FROM
        MON_EQUIP_HIRE_FACT_TEMP_V1
    GROUP BY
        Time_ID,
        Season_ID,
        Customer_Type_ID,
        Company_Branch_Name,
        Category_ID;
        
select * from MON_EQUIP_HIRE_FACT_V1;