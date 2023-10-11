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
drop table MON_EQUIP_SALES_FACT_V3;


---------------------------------------------------------------------------
-- SALES_DIM, CUSTOMER_DIM, STAFF_DIM, EQUIPMENT_DIM, HIRE_DIM
---------------------------------------------------------------------------
CREATE TABLE SALES_DIM AS
    SELECT SALES_ID, SALES_DATE, QUANTITY,
    UNIT_SALES_PRICE, TOTAL_SALES_PRICE
    FROM MONEQUIP.SALES
    ORDER BY SALES_ID;

CREATE TABLE CUSTOMER_DIM AS
    SELECT C.CUSTOMER_ID, C.CUSTOMER_TYPE_ID, CT.DESCRIPTION,
    C.NAME, C.GENDER, C.PHONE, C.EMAIL
    FROM MONEQUIP.CUSTOMER c, MONEQUIP.CUSTOMER_TYPE ct
    WHERE C.CUSTOMER_TYPE_ID = CT.CUSTOMER_TYPE_ID
    ORDER BY CUSTOMER_ID;

CREATE TABLE STAFF_DIM AS
    SELECT STAFF_ID, FIRST_NAME, LAST_NAME, GENDER,
    PHONE, EMAIL, COMPANY_BRANCH
    FROM MONEQUIP.STAFF
    ORDER BY STAFF_ID;
        
CREATE TABLE EQUIPMENT_DIM AS
    SELECT E.EQUIPMENT_ID, E.EQUIPMENT_NAME, E.EQUIPMENT_PRICE,
    E.MANUFACTURE_YEAR, E.MANUFACTURER, E.CATEGORY_ID, 
    C.CATEGORY_DESCRIPTION
    FROM MONEQUIP.EQUIPMENT E, MONEQUIP.CATEGORY C
    WHERE E.CATEGORY_ID = C.CATEGORY_ID
    ORDER BY EQUIPMENT_ID;
    
CREATE TABLE HIRE_DIM AS
    SELECT HIRE_ID, START_DATE, END_DATE,
    QUANTITY, UNIT_HIRE_PRICE, TOTAL_HIRE_PRICE
    FROM MONEQUIP.HIRE
    ORDER BY HIRE_ID;
    
    
---------------------------------------------------------------------------
-- MON_EQUIP_SALES Temporary Fact Table V2
---------------------------------------------------------------------------
CREATE TABLE MON_EQUIP_SALES_TEMP_FACT_V2 AS
    SELECT 
        S.SALES_ID,
        C.CUSTOMER_ID,
        F.STAFF_ID,
        E.EQUIPMENT_ID,
        S.TOTAL_SALES_PRICE,
        S.QUANTITY 
    FROM 
        CLEANED_SALES S,
        CLEANED_CUSTOMER  C, 
        CLEANED_STAFF F,
        MONEQUIP.EQUIPMENT E 
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
        COUNT(SALES_ID) AS Total_Number_of_Sales,
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
CREATE TABLE MON_EQUIP_HIRE_TEMP_FACT_V2 AS
    SELECT 
        H.HIRE_ID,
        C.CUSTOMER_ID,
        F.STAFF_ID,
        E.EQUIPMENT_ID,
        H.TOTAL_HIRE_PRICE,
        H.QUANTITY 
    FROM 
        CLEANED_HIRE S,
        CLEANED_CUSTOMER  C, 
        CLEANED_STAFF F,
        MONEQUIP.EQUIPMENT E 
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
        COUNT(SALES_ID) AS Total_Number_of_Hire,
        SUM(QUANTITY) AS Total_Equipment_Hired  
    FROM 
        MON_EQUIP_HIRE_FACT_TEMP_V2
    GROUP BY
        HIRE_ID,
        CUSTOMER_ID,
        STAFF_ID,
        EQUIPMENT_ID;