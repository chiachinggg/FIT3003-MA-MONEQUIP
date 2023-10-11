---------------------------------------------------------------------------
-- STAR SCHEMA VERSION 1
---------------------------------------------------------------------------

-- Newly created tables during data cleaning phase: 
-- CUSTOMER, HIRE, EQUIPMENT, SALES, CATEGORY


---------------------------------------------------------------------------
-- DROP TABLE SEGMENT
---------------------------------------------------------------------------
drop table sales_price_scale_dim;
drop table season_dim;
drop table company_branch_dim;
drop table time_dim_temp;
drop table time_dim;
drop table customer_type_dim;
drop table category_dim;
drop table MON_EQUIP_SALES_FACT_TEMP_V1;
drop table MON_EQUIP_SALES_FACT_V1;
drop table MON_EQUIP_HIRE_FACT_TEMP_V1;
drop table MON_EQUIP_HIRE_FACT_V1;


-- SALES_PRICE_SCALE Dimension

CREATE TABLE SALES_PRICE_SCALE_DIM
    (
        Sales_Price_Scale_ID NUMBER(5),
        Description VARCHAR2(50),
        Min_Price NUMBER(10),
        Max_Price NUMBER(10)
    );

-- Insert records into SALES_PRICE_SCALE Dimension

INSERT INTO SALES_PRICE_SCALE_DIM VALUES (1, 'Low sales', 0, 4999);
INSERT INTO SALES_PRICE_SCALE_DIM VALUES (2, 'Medium sales', 5000, 10000);
INSERT INTO SALES_PRICE_SCALE_DIM VALUES (3, 'High sales', 10001, 999999);

-- SEASON Dimension

CREATE TABLE SEASON_DIM
    (
        Season_ID NUMBER(1),
        Description VARCHAR2(30),
        Start_Month VARCHAR2(2),
        End_Month VARCHAR2(2)
    ); 

-- Insert records into SEASON Dimension

INSERT INTO SEASON_DIM VALUES (1, 'Spring', '09', '11');
INSERT INTO SEASON_DIM VALUES (2, 'Summer', '12', '02');
INSERT INTO SEASON_DIM VALUES (3, 'Autumn', '03', '05');
INSERT INTO SEASON_DIM VALUES (4, 'Winter', '06', '08');

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
    Time_ID VARCHAR2(6),
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

-- CATEGORY Dimension

CREATE TABLE CATEGORY_DIM AS
    SELECT 
        CATEGORY_ID,
        CATEGORY_DESCRIPTION AS Description
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
WHERE TO_CHAR(TO_DATE(Time_ID, 'YYYYMM'), 'MM') >= '12' OR
    TO_CHAR(TO_DATE(Time_ID, 'YYYYMM'), 'MM') <= '02';

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
WHERE Total_Sales_Price BETWEEN 0 AND 4999;

UPDATE MON_EQUIP_SALES_FACT_TEMP_V1
SET Sales_Price_Scale_ID = 2
WHERE Total_Sales_Price BETWEEN 5000 AND 10000;
        
UPDATE MON_EQUIP_SALES_FACT_TEMP_V1
SET Sales_Price_Scale_ID = 3
WHERE Total_Sales_Price BETWEEN 10001 AND 999999;

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
WHERE TO_CHAR(TO_DATE(Time_ID, 'YYYYMM'), 'MM') >= '12' OR
    TO_CHAR(TO_DATE(Time_ID, 'YYYYMM'), 'MM') <= '02';

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
        




---------------------------------------------------------------------------
-- STAR SCHEMA VERSION 2
---------------------------------------------------------------------------
-- Newly created tables during data cleaning phase: 
-- CUSTOMER, HIRE, EQUIPMENT, SALES, CATEGORY


---------------------------------------------------------------------------
-- DROP TABLE SEGMENT
---------------------------------------------------------------------------
drop table sales_dim;
drop table customer_dim;
drop table staff_dim;
drop table equipment_dim;
drop table hire_dim;
drop table MON_EQUIP_SALES_FACT_TEMP_V2;
drop table MON_EQUIP_SALES_FACT_V2;
drop table MON_EQUIP_HIRE_FACT_TEMP_V2;
drop table MON_EQUIP_HIRE_FACT_V2;


---------------------------------------------------------------------------
-- SALES_DIM
---------------------------------------------------------------------------
CREATE TABLE SALES_DIM AS
    SELECT 
        SALES_ID, 
        SALES_DATE, 
        QUANTITY, 
        UNIT_SALES_PRICE, 
        TOTAL_SALES_PRICE
    FROM SALES
    ORDER BY SALES_ID;
    

---------------------------------------------------------------------------
-- CUSTOMER_DIM
---------------------------------------------------------------------------

CREATE TABLE CUSTOMER_DIM AS
    SELECT 
        C.CUSTOMER_ID, 
        C.NAME, 
        C.GENDER, 
        C.PHONE, 
        C.EMAIL, 
        CT.DESCRIPTION AS CUSTOMER_TYPE_DESCRIPTION
    FROM CUSTOMER C, MONEQUIP.CUSTOMER_TYPE CT
    WHERE C.CUSTOMER_TYPE_ID = CT.CUSTOMER_TYPE_ID
    ORDER BY CUSTOMER_ID;


---------------------------------------------------------------------------
-- STAFF_DIM
---------------------------------------------------------------------------

CREATE TABLE STAFF_DIM AS
    SELECT 
        STAFF_ID, 
        FIRST_NAME, 
        LAST_NAME, 
        GENDER, 
        PHONE, 
        EMAIL, 
        COMPANY_BRANCH
    FROM MONEQUIP.STAFF
    ORDER BY STAFF_ID;
        
        
---------------------------------------------------------------------------
-- EQUIPMENT_DIM
---------------------------------------------------------------------------

CREATE TABLE EQUIPMENT_DIM AS
    SELECT 
        E.EQUIPMENT_ID, 
        E.EQUIPMENT_NAME, 
        E.EQUIPMENT_PRICE, 
        E.MANUFACTURE_YEAR, 
        E.MANUFACTURER, 
        C.CATEGORY_DESCRIPTION
    FROM EQUIPMENT E, CATEGORY C
    WHERE E.CATEGORY_ID = C.CATEGORY_ID
    ORDER BY EQUIPMENT_ID;
    
    
---------------------------------------------------------------------------
-- HIRE_DIM
---------------------------------------------------------------------------
CREATE TABLE HIRE_DIM AS
    SELECT 
        HIRE_ID, 
        START_DATE, 
        END_DATE,
        QUANTITY, 
        UNIT_HIRE_PRICE, 
        TOTAL_HIRE_PRICE
    FROM HIRE
    ORDER BY HIRE_ID;
    
    
---------------------------------------------------------------------------
-- MON_EQUIP_SALES Temporary Fact Table V2
---------------------------------------------------------------------------
CREATE TABLE MON_EQUIP_SALES_FACT_TEMP_V2 AS
    SELECT 
        S.SALES_ID,
        C.CUSTOMER_ID,
        F.STAFF_ID,
        E.EQUIPMENT_ID,
        S.TOTAL_SALES_PRICE,
        S.QUANTITY 
    FROM 
        SALES S,
        CUSTOMER  C, 
        MONEQUIP.STAFF F,
        EQUIPMENT E 
    WHERE
        S.CUSTOMER_ID = C.CUSTOMER_ID AND
        S.STAFF_ID = F.STAFF_ID AND
        S.EQUIPMENT_ID = E.EQUIPMENT_ID;


---------------------------------------------------------------------------
-- MON_EQUIP_SALES Fact Table V2
---------------------------------------------------------------------------
CREATE TABLE MON_EQUIP_SALES_FACT_V2 AS
    SELECT 
        SALES_ID,
        CUSTOMER_ID,
        STAFF_ID,
        EQUIPMENT_ID,
        SUM(TOTAL_SALES_PRICE) AS Total_Sales_Revenue,
        SUM(QUANTITY) AS Total_Equipment_Sold  
    FROM 
        MON_EQUIP_SALES_FACT_TEMP_V2
    GROUP BY
        SALES_ID,
        CUSTOMER_ID,
        STAFF_ID,
        EQUIPMENT_ID;      
    

---------------------------------------------------------------------------
-- MON_EQUIP_HIRE Temporary Fact Table V2
---------------------------------------------------------------------------
CREATE TABLE MON_EQUIP_HIRE_FACT_TEMP_V2 AS
    SELECT 
        H.HIRE_ID,
        C.CUSTOMER_ID,
        F.STAFF_ID,
        E.EQUIPMENT_ID,
        H.TOTAL_HIRE_PRICE,
        H.QUANTITY 
    FROM 
        HIRE H,
        CUSTOMER  C, 
        MONEQUIP.STAFF F,
        EQUIPMENT E 
    WHERE
        H.CUSTOMER_ID = C.CUSTOMER_ID AND
        H.STAFF_ID = F.STAFF_ID AND
        H.EQUIPMENT_ID = E.EQUIPMENT_ID;

---------------------------------------------------------------------------
-- MON_EQUIP_HIRE Fact Table V2
---------------------------------------------------------------------------
CREATE TABLE MON_EQUIP_HIRE_FACT_V2 AS
    SELECT 
        HIRE_ID,
        CUSTOMER_ID,
        STAFF_ID,
        EQUIPMENT_ID,
        SUM(TOTAL_HIRE_PRICE) AS Total_Hire_Revenue,
        SUM(QUANTITY) AS Total_Equipment_Hired  
    FROM 
        MON_EQUIP_HIRE_FACT_TEMP_V2
    GROUP BY
        HIRE_ID,
        CUSTOMER_ID,
        STAFF_ID,
        EQUIPMENT_ID;

