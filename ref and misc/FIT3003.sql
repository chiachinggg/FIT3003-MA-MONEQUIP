drop table bakeryfact;
drop table timedim;
drop table feedbackfact;
drop table branchdim;
drop table ratingdim;
drop table channeldim;

CREATE TABLE BAKERYFACT (
    PRODUCTTYPE VARCHAR(20),
    BRANCH VARCHAR(20),
    MONTHYEAR NUMBER(10),
    CHANNEL VARCHAR2(20),
    TOTAL_SALES NUMBER(20)
);

CREATE TABLE FEEDBACKFACT (
    PRODUCTTYPE VARCHAR2(20),
    MONTHYEAR NUMBER(10),
    RATINGID NUMBER(2),
    NO_OF_FEEDBACK NUMBER(10)
);

CREATE TABLE BRANCHDIM (
    BRANCH VARCHAR2(20)
);

CREATE TABLE TIMEDIM (
    MONTHYEAR NUMBER(10),
    MONTH VARCHAR2(10),
    YEAR NUMBER(4)
);


CREATE TABLE RATINGDIM (
    RATINGID NUMBER(2),
    DESCRIPTION VARCHAR2(20)
);

CREATE TABLE PRODUCTDIM (
    PRODUCTTYPE VARCHAR2(20)
);

CREATE TABLE CHANNELDIM (
    CHANNEL VARCHAR2(20)
);

INSERT INTO PRODUCTDIM VALUES ('Croissants');
INSERT INTO PRODUCTDIM VALUES ('Pastry');

INSERT INTO CHANNELDIM VALUES ('Take-away');
INSERT INTO CHANNELDIM VALUES ('Dine-in');

INSERT INTO RATINGDIM VALUES (1, 'Poor');
INSERT INTO RATINGDIM VALUES (2, 'Fair');
INSERT INTO RATINGDIM VALUES (3, 'Good');
INSERT INTO RATINGDIM VALUES (4, 'Very Good');
INSERT INTO RATINGDIM VALUES (5, 'Excellent');

INSERT INTO BRANCHDIM VALUES ('North Melbourne');
INSERT INTO BRANCHDIM VALUES ('East Melbourne');
INSERT INTO BRANCHDIM VALUES ('Carlton');
INSERT INTO BRANCHDIM VALUES ('Richmond');

INSERT INTO TIMEDIM VALUES (202101, 'January', 2021);
INSERT INTO TIMEDIM VALUES (202101, 'February', 2021);
INSERT INTO TIMEDIM VALUES (202101, 'March', 2021);


INSERT INTO FEEDBACKFACT VALUES ('Croissants', 202101, 1, 100);
INSERT INTO FEEDBACKFACT VALUES ('Croissants', 202101, 2, 100);
INSERT INTO FEEDBACKFACT VALUES ('Croissants', 202101, 3, 250);
INSERT INTO FEEDBACKFACT VALUES ('Croissants', 202101, 4, 200);
INSERT INTO FEEDBACKFACT VALUES ('Croissants', 202102, 1, 50);
INSERT INTO FEEDBACKFACT VALUES ('Croissants', 202102, 2, 50);
INSERT INTO FEEDBACKFACT VALUES ('Croissants', 202102, 3, 100);
INSERT INTO FEEDBACKFACT VALUES ('Croissants', 202102, 4, 200);
INSERT INTO FEEDBACKFACT VALUES ('Croissants', 202102, 5, 300);
INSERT INTO FEEDBACKFACT VALUES ('Pastry', 202101, 2, 100);
INSERT INTO FEEDBACKFACT VALUES ('Pastry', 202101, 3, 150);
INSERT INTO FEEDBACKFACT VALUES ('Pastry', 202101, 4, 200);
INSERT INTO FEEDBACKFACT VALUES ('Pastry', 202101, 5, 100);
INSERT INTO FEEDBACKFACT VALUES ('Pastry', 202102, 2, 150);
INSERT INTO FEEDBACKFACT VALUES ('Pastry', 202102, 3, 100);
INSERT INTO FEEDBACKFACT VALUES ('Pastry', 202102, 4, 200);
INSERT INTO FEEDBACKFACT VALUES ('Pastry', 202102, 5, 300);
INSERT INTO FEEDBACKFACT VALUES ('Croissants', 202103, 2, 150);
INSERT INTO FEEDBACKFACT VALUES ('Croissants', 202103, 3, 200);
INSERT INTO FEEDBACKFACT VALUES ('Croissants', 202103, 4, 300);
INSERT INTO FEEDBACKFACT VALUES ('Croissants', 202103, 5, 400);
INSERT INTO FEEDBACKFACT VALUES ('Pastry', 202103, 2, 150);
INSERT INTO FEEDBACKFACT VALUES ('Pastry', 202103, 3, 250);
INSERT INTO FEEDBACKFACT VALUES ('Pastry', 202103, 4, 200);
INSERT INTO FEEDBACKFACT VALUES ('Pastry', 202103, 5, 300);

INSERT INTO BAKERYFACT VALUES ('Croissants', 'Carlton', 202101, 'Take-away', 20000);
INSERT INTO BAKERYFACT VALUES ('Croissants', 'Carlton', 202101, 'Dine-in', 30000);
INSERT INTO BAKERYFACT VALUES ('Croissants', 'East Melbourne', 202101, 'Dine-in', 35000);
INSERT INTO BAKERYFACT VALUES ('Croissants', 'East Melbourne', 202101, 'Take-away', 35000);
INSERT INTO BAKERYFACT VALUES ('Croissants', 'North Melbourne', 202101, 'Dine-in', 15000);
INSERT INTO BAKERYFACT VALUES ('Pastry', 'North Melbourne', 202101, 'Dine-in', 25000);
INSERT INTO BAKERYFACT VALUES ('Croissants', 'Richmond', 202101, 'Take-away', 39000);
INSERT INTO BAKERYFACT VALUES ('Pastry', 'Richmond', 202101, 'Take-away', 45000);
INSERT INTO BAKERYFACT VALUES ('Croissants', 'Carlton', 202102, 'Dine-in', 15000);
INSERT INTO BAKERYFACT VALUES ('Pastry', 'Carlton', 202102, 'Take-away', 10000);
INSERT INTO BAKERYFACT VALUES ('Pastry', 'East Melbourne', 202102, 'Take-away', 20000);
INSERT INTO BAKERYFACT VALUES ('Croissants', 'North Melbourne', 202102, 'Dine-in', 10000);
INSERT INTO BAKERYFACT VALUES ('Croissants', 'Richmond', 202102, 'Take-away', 45000);
INSERT INTO BAKERYFACT VALUES ('Croissants', 'Carlton', 202103, 'Take-away', 25000);
INSERT INTO BAKERYFACT VALUES ('Pastry', 'Carlton', 202103, 'Take-away', 20000);
INSERT INTO BAKERYFACT VALUES ('Croissants', 'East Melbourne', 202103, 'Dine-in', 25000);
INSERT INTO BAKERYFACT VALUES ('Croissants', 'North Melbourne', 202103, 'Dine-in', 40000);
INSERT INTO BAKERYFACT VALUES ('Pastry', 'North Melbourne', 202103, 'Take-away', 25000);
INSERT INTO BAKERYFACT VALUES ('Pastry', 'Richmond', 202103, 'Dine-in', 25000);
INSERT INTO BAKERYFACT VALUES ('Pastry', 'Richmond', 202103, 'Take-away', 50000);
INSERT INTO BAKERYFACT VALUES ('Croissants', 'East Melbourne', 202104, 'Dine-in', 25000);
INSERT INTO BAKERYFACT VALUES ('Pastry', 'East Melbourne', 202104, 'Dine-in', 30000);
INSERT INTO BAKERYFACT VALUES ('Pastry', 'North Melbourne', 202104, 'Take-away', 50000);
INSERT INTO BAKERYFACT VALUES ('Croissants', 'Richmond', 202104, 'Take-away', 35000);

Select 
decode(grouping(month), 1, 'All Months', Month) AS Month,
decode(grouping(branch), 1, 'All Branches', Branch) AS Branch,
decode(grouping(producttype), 1, 'All Products', ProductType) AS ProductType,
sum(total_sales)
from bakeryfact natural join timedim
group by cube(month, producttype, branch)
having branch like '%Melbourne'
order by month, branch, sum(total_sales);

Select 
decode(grouping(month), 1, 'All Months', Month) AS Month,
decode(grouping(branch), 1, 'All Branches', Branch) AS Branch,
decode(grouping(producttype), 1, 'All Products', ProductType) AS ProductType,
sum(total_sales)
from bakeryfact natural join timedim
group by producttype, cube(month,  branch)
having branch like '%Melbourne'
order by month, branch, sum(total_sales);

SELECT Month, SUM(No_of_Feedback)
FROM FeedbackFact F, TimeDIM T
WHERE F.MonthYear = T.MonthYear
group by month;

SELECT Branch, TotalSales FROM

(SELECT

Branch, SUM(Total_Sales) AS TotalSales,

PERCENT_RANK() OVER(ORDER BY SUM(Total_Sales)) AS Product_Rank

FROM BakeryFact

GROUP BY Branch)
where product_rank <=0.5;

SELECT  Branch, SUM(Total_Sales) AS "Total Sales",

RANK()OVER (ORDER BY SUM(Total_Sales) DESC) AS Rank

FROM BakeryFACT
group by branch;

SELECT Description, ProductType, SUM(No_of_Feedback) AS Total_Feedback, 

RANK() OVER(PARTITION BY Description ORDER BY SUM(No_Of_Feedback) DESC) AS Rank

FROM FeedbackFACT NATURAL JOIN RatingDIM
group by description, producttype;

select producttype, description, sum(no_of_feedback) as total_feedback
from feedbackfact, ratingdim
where feedbackfact.ratingid = ratingdim.ratingid
group by producttype, description
order by description desc;

SELECT  ProductType, Month, SUM(Total_Sales) AS TotalSales,

RANK() OVER(

PARTITION BY Month

ORDER BY SUM(Total_Sales) DESC) AS SalesRank

FROM BakeryFact NATURAL JOIN TimeDIM

GROUP BY ProductType, Month

HAVING ProductType = 'Croissants';
SELECT  ProductType, Month, SUM(Total_Sales) AS TotalSales,

RANK() OVER(

PARTITION BY ProductType

ORDER BY SUM(Total_Sales) DESC) AS SalesRank

FROM BakeryFact NATURAL JOIN TimeDIM

GROUP BY ProductType, Month

HAVING ProductType = 'Croissants';

SELECT * FROM

(SELECT Month, ProductType, SUM(Total_Sales) AS Total_Sales,

ROUND(PERCENT_RANK() OVER (ORDER BY SUM(Total_Sales)),2) as Sales_Percent_Rank

FROM BakeryFACT F NATURAL JOIN TimeDIM T

WHERE Month = 'January' OR Month = 'February'

GROUP BY Month, ProductType)

WHERE Sales_Percent_Rank <= 0.1;

SELECT  Branch, SUM(Total_Sales) AS "Total Sales",

RANK()OVER (ORDER BY SUM(Total_Sales) DESC) AS Rank

FROM BakeryFACT

GROUP BY Branch;

SELECT ProductType, RatingID, SUM(No_of_Feedback) AS Number_of_Feedback

FROM FeedbackFACT

WHERE ProductType = 'Croissants'

GROUP BY ProductType, RatingID

ORDER BY ProductType, RatingID;

SELECT DECODE(GROUPING(Month), 1, 'All Months', Month) AS Month,

DECODE(GROUPING(ProductType), 1, 'All Products', ProductType) As ProductType,

DECODE(GROUPING(Channel), 1, 'All Channels', Channel) As Channel,

SUM(Total_Sales)

FROM BakeryFACT NATURAL JOIN TimeDIM

GROUP BY CUBE(Month), ProductType, Channel;

SELECT DECODE(GROUPING(Month), 1, 'All Months', Month) AS Month,

DECODE(GROUPING(ProductType), 1, 'All Products', ProductType) As ProductType,

DECODE(GROUPING(Channel), 1, 'All Channels', Channel) As Channel,

SUM(Total_Sales)

FROM BakeryFACT NATURAL JOIN TimeDIM

GROUP BY CUBE(Month, ProductType), Channel;

SELECT ProductType, MonthYear, SUM(Total_Sales) AS Total_Sales

FROM BakeryFACT

GROUP BY ROLLUP (ProductType, MonthYear);

SELECT ProductType, ROUND(AVG(TOTAL_Sales)) AS Total_Sales, ROUND(AVG(Total_Feedback)) AS Total_Feedback

FROM 

 (SELECT BK.ProductType AS ProductType, FF.ProductType AS FProductType, Total_Sales, 

No_of_Feedback As Total_Feedback

FROM BakeryFACT BK, FeedbackFact FF

WHERE BK.ProductType = FF.ProductType

AND BK.MonthYear = FF.MonthYear)T

GROUP BY ProductType

ORDER BY Total_Sales;



SELECT MonthYear, ProductType, Branch, SUM(Total_Sales), 

TO_CHAR(SUM(SUM(Total_Sales)) OVER(PARTITION BY ProductType

ORDER BY MonthYear ROWS UNBOUNDED PRECEDING), '999,999,999') 

AS Total_Sales

FROM BakeryFACT

GROUP BY MonthYear, ProductType, Branch

Order By MonthYear, ProductTYpe, Branch;



SELECT * FROM

(SELECT Month, ProductType, SUM(Total_Sales) AS Total_Sales,

PERCENT_RANK() OVER (ORDER BY SUM(Total_Sales)) as Sales_Percent_Rank

FROM BakeryFACT F NATURAL JOIN TimeDIM T

WHERE Month = 'January' OR Month = 'February'

GROUP BY Month, ProductType)

WHERE Sales_Percent_Rank <= 0.1;

SELECT Month, ProductType, SUM(Total_Sales) AS Total_Sales,

ROUND(PERCENT_RANK() OVER (ORDER BY SUM(Total_Sales)),2) as Sales_Percent_Rank

FROM BakeryFACT F NATURAL JOIN TimeDIM T

WHERE Month = 'January' OR Month = 'February'

GROUP BY Month, ProductType

HAVING (PERCENT_RANK() OVER (ORDER BY SUM(Total_Sales))) >= 0.90;