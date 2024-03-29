--ASSIGNMENT 7
--1. LIST THE CUSTOMERS FROM CALIFORNIA WHO BOUGHT RED MOUNTAIN BIKES IN SEPTEMBER 
--2003. USE ORDER DATE AS DATE BOUGHT
USE BIKE
SELECT	C.CUSTOMERID, C.LASTNAME, C.FIRSTNAME, B.MODELTYPE, P.COLORLIST, B.ORDERDATE, B.SALESTATE
FROM	CUSTOMER C INNER JOIN BICYCLE B ON C.CUSTOMERID = B.CUSTOMERID
		INNER JOIN PAINT P ON P.PAINTID = B.PAINTID
WHERE	B.SALESTATE = 'CA'
		AND P.COLORLIST = 'RED'
		AND B.MODELTYPE LIKE 'MOUNTAIN%'
		AND YEAR(B.ORDERDATE) = '2003'
		AND	MONTH(B.ORDERDATE) = '09'
ORDER BY C.LASTNAME, C.FIRSTNAME

--2. LIST THE EMPLOYEES WHO SOLD RACE BIKES SHIPPED TO WISCONSIN WITHOUT THE HELP
-- OF A RETAIL STORE IN 2001
SELECT	E.EMPLOYEEID, E.LASTNAME, B.SALESTATE, B.MODELTYPE, B.STOREID, B.ORDERDATE
FROM	BICYCLE B INNER JOIN EMPLOYEE E ON B.EMPLOYEEID = E.EMPLOYEEID
WHERE	B.SALESTATE = 'WI'
		AND B.MODELTYPE = 'RACE'
		AND YEAR(B.ORDERDATE) = '2001'
		AND B.STOREID IS NULL

--3. LIST ALL OF THE (DISTINCT) REAR DERAILLEURS INSTALLED ON ROAD BIKES SOLD IN 
--FLORIDA IN 2002.
SELECT	DISTINCT C.COMPONENTID, C.CATEGORY, B.SALESTATE, C.YEAR
FROM	COMPONENT C INNER JOIN BIKEPARTS BP ON BP.COMPONENTID = C.COMPONENTID
		INNER JOIN MANUFACTURER M ON M.MANUFACTURERID = C.MANUFACTURERID
		INNER JOIN BICYCLE B ON B.SERIALNUMBER = BP.SERIALNUMBER
WHERE	C.COMPONENTID IN (SELECT C.COMPONENTID 
						  FROM	 COMPONENT C 
						  WHERE	 C.CATEGORY = 'REAR DERAILLEUR' AND C.ROAD = 'ROAD'
								 AND C.YEAR = '2002')
		AND B.SALESTATE = 'FL'

--4. WHO BOUGHT THE LARGEST (FRAME SIZE) FULL SUSPENSION MOUNTAIN BIKE SOLD IN GEORGIA
-- IN 2004?
SELECT	C.CUSTOMERID, C.LASTNAME, C.FIRSTNAME, B.MODELTYPE, B.SALESTATE, B.FRAMESIZE, B.ORDERDATE
FROM	BICYCLE B INNER JOIN CUSTOMER C ON C.CUSTOMERID = B.CUSTOMERID
WHERE	B.MODELTYPE = 'MOUNTAIN FULL'
		AND	B.SALESTATE = 'GA'
		AND YEAR(B.ORDERDATE) = '2004'
		AND FRAMESIZE = (SELECT MAX(FRAMESIZE)
					     FROM	BICYCLE B
						 WHERE	B.MODELTYPE = 'MOUNTAIN FULL'
								AND B.SALESTATE = 'GA'
								AND YEAR(B.ORDERDATE) = '2004')

--5. WHICH MANUFACTURER GAVE US THE LARGEST DISCOUNT ON AN ORDER IN 2003?
SELECT	M.MANUFACTURERID, M.MANUFACTURERNAME
FROM	PURCHASEORDER P INNER JOIN MANUFACTURER M ON P.MANUFACTURERID = M.MANUFACTURERID
WHERE	P.DISCOUNT = (SELECT MAX(P.DISCOUNT)
					  FROM	 PURCHASEORDER P INNER JOIN MANUFACTURER M ON P.MANUFACTURERID = M.MANUFACTURERID
					 )

--6. WHAT IS THE MOST EXPENSIVE ROAD BIKE COMPONENT WE STOCK THAT HAS A QUANTITY
-- ON HAND GREATER THAN 200 UNITS? 
SELECT	C.COMPONENTID, M.MANUFACTURERNAME, C.PRODUCTNUMBER, C.ROAD, C.CATEGORY, C.LISTPRICE, C.QUANTITYONHAND
FROM	MANUFACTURER M INNER JOIN COMPONENT C ON M.MANUFACTURERID = C.MANUFACTURERID
WHERE	C.ROAD = 'ROAD'
		AND C.QUANTITYONHAND > '200'
		AND C.LISTPRICE = (SELECT MAX(C.LISTPRICE)
						   FROM	  MANUFACTURER M INNER JOIN COMPONENT C ON M.MANUFACTURERID = C.MANUFACTURERID
						   WHERE  C.ROAD = 'ROAD'
						   AND C.QUANTITYONHAND > '200')

--7. WHICH INVENTORY ITEM REPRESENTS THE MOST MONEY SITTING ON THE SHELF—BASED ON 
--   ESTIMATED COST?
--COMPONENTID	MANUFACTURERNAME	PRODUCTNUMBER	CATEGORY	YEAR	VALUE
SELECT	C.COMPONENTID, M.MANUFACTURERNAME, C.PRODUCTNUMBER, C.CATEGORY, C.YEAR, (C.ESTIMATEDCOST * C.QUANTITYONHAND) AS 'VALUE'
FROM	COMPONENT C INNER JOIN MANUFACTURER M ON C.MANUFACTURERID = M.MANUFACTURERID
WHERE	(C.ESTIMATEDCOST * C.QUANTITYONHAND) = (SELECT MAX(C.ESTIMATEDCOST * C.QUANTITYONHAND)
												FROM   COMPONENT C INNER JOIN MANUFACTURER M ON C.MANUFACTURERID = M.MANUFACTURERID)
--CHECK
--8. WHAT IS THE GREATEST NUMBER OF COMPONENTS EVER INSTALLED IN ONE DAY BY ONE 
--   EMPLOYEE?
--   EMPLOYEEID	 LASTNAME	DATEINSTALLED	COUNTOFCOMPONENTID
SELECT	E.EMPLOYEEID, E.LASTNAME, BP.DATEINSTALLED, COUNT(BP.QUANTITY) AS 'COUNTOFCOMPONENT'
FROM	EMPLOYEE E INNER JOIN BIKEPARTS BP ON E.EMPLOYEEID = BP.EMPLOYEEID
		INNER JOIN COMPONENT C ON C.COMPONENTID = BP.COMPONENTID
		INNER JOIN MANUFACTURER M ON C.MANUFACTURERID = M.MANUFACTURERID
WHERE	BP.DATEINSTALLED IS NOT NULL
GROUP BY E.EMPLOYEEID, E.LASTNAME, BP.DATEINSTALLED
HAVING	COUNT(BP.QUANTITY) = (SELECT TOP 1 COUNT(BP.QUANTITY)
							  FROM	EMPLOYEE E INNER JOIN BIKEPARTS BP ON E.EMPLOYEEID = BP.EMPLOYEEID
									INNER JOIN COMPONENT C ON C.COMPONENTID = BP.COMPONENTID
									INNER JOIN MANUFACTURER M ON C.MANUFACTURERID = M.MANUFACTURERID
							  WHERE	BP.DATEINSTALLED IS NOT NULL
							  GROUP BY E.EMPLOYEEID, E.LASTNAME, BP.DATEINSTALLED
							  ORDER BY COUNT(BP.QUANTITY) DESC)

--9. WHAT WAS THE MOST POPULAR LETTER STYLE ON RACE BIKES IN 2003?
--   LETTERSTYLEID	  COUNTOFSERIALNUMBER
SELECT	B.LETTERSTYLEID, COUNT(B.SERIALNUMBER) AS 'COUNTOFSERIALNUMBER'
FROM	LETTERSTYLE L INNER JOIN BICYCLE B ON L.LETTERSTYLE = B.LETTERSTYLEID
WHERE	B.MODELTYPE = 'RACE'
		AND YEAR(B.ORDERDATE) = '2003'
GROUP BY B.LETTERSTYLEID
HAVING	COUNT(B.SERIALNUMBER) = (SELECT TOP 1 COUNT(B.SERIALNUMBER)
								 FROM	LETTERSTYLE L INNER JOIN BICYCLE B ON L.LETTERSTYLE = B.LETTERSTYLEID
								 WHERE	B.MODELTYPE = 'RACE'
										AND YEAR(B.ORDERDATE) = '2003'
								 GROUP BY B.LETTERSTYLEID
								 ORDER BY COUNT(B.SERIALNUMBER) DESC)

--10. WHICH CUSTOMER SPENT THE MOST MONEY WITH US AND HOW MANY BICYCLES DID 
--    THAT PERSON BUY IN 2002?
--    CUSTOMERID	LASTNAME	FIRSTNAME	NUMBER OF BIKES	   AMOUNT SPENT
SELECT	C.CUSTOMERID, C.LASTNAME, C.FIRSTNAME, COUNT(B.SERIALNUMBER) AS 'NUMBEROFBIKES', SUM(CT.AMOUNT) AS 'AMOUNTSPENT'
FROM	CUSTOMER C INNER JOIN CUSTOMERTRANSACTION CT ON C.CUSTOMERID = CT.CUSTOMERID
		INNER JOIN BICYCLE B ON B.CUSTOMERID = C.CUSTOMERID
WHERE	YEAR(B.ORDERDATE) = '2002'
		AND CT.AMOUNT > 0
GROUP BY C.CUSTOMERID, C.LASTNAME, C.FIRSTNAME
HAVING	SUM(CT.AMOUNT ) = (SELECT TOP 1 SUM(CT.AMOUNT)
							FROM	CUSTOMER C INNER JOIN CUSTOMERTRANSACTION CT ON C.CUSTOMERID = CT.CUSTOMERID
									INNER JOIN BICYCLE B ON B.CUSTOMERID = C.CUSTOMERID
							WHERE	YEAR(B.ORDERDATE) = '2002'
							AND CT.AMOUNT > 0
							GROUP BY C.CUSTOMERID, C.LASTNAME, C.FIRSTNAME
							ORDER BY SUM(CT.AMOUNT ) DESC)

--11. HAVE THE SALES OF MOUNTAIN BIKES (FULL SUSPENSION OR HARD TAIL) INCREASED OR 
--    DECREASED FROM 2000 TO 2004 (BY COUNT NOT BY VALUE)?
--    SALEYEAR	COUNTOFSERIALNUMBER
SELECT	YEAR(B.ORDERDATE) AS 'SALEYEAR', COUNT(B.SERIALNUMBER) AS 'COUNTOFSERIALNUMBER'
FROM	BICYCLE B
WHERE	B.MODELTYPE IN ('MOUNTAIN', 'MOUNTAIN FULL')
GROUP BY YEAR(B.ORDERDATE)
HAVING	YEAR(B.ORDERDATE) >= '2000'AND YEAR(B.ORDERDATE) <= '2004'
ORDER BY SALEYEAR DESC

--12. WHICH COMPONENT DID THE COMPANY SPEND THE MOST MONEY ON IN 2003?
SELECT C.COMPONENTID, M.MANUFACTURERID, C.PRODUCTNUMBER, C.CATEGORY, SUM(ITEM.PRICEPAID * ITEM.QUANTITY) AS 'VALUE'
FROM PURCHASEORDER PO INNER JOIN PURCHASEITEM ITEM ON PO.PURCHASEID = ITEM.PURCHASEID
     INNER JOIN COMPONENT C ON ITEM.COMPONENTID = C.COMPONENTID
     INNER JOIN MANUFACTURER M ON C.MANUFACTURERID = M.MANUFACTURERID
WHERE YEAR(PO.ORDERDATE) = '2003'
GROUP BY C.COMPONENTID, M.MANUFACTURERID, C.PRODUCTNUMBER, C.CATEGORY
HAVING SUM(ITEM.PRICEPAID * ITEM.QUANTITY) = (SELECT TOP 1 SUM(ITEM.PRICEPAID * ITEM.QUANTITY)
											  FROM	PURCHASEORDER PO INNER JOIN PURCHASEITEM ITEM ON PO.PURCHASEID = ITEM.PURCHASEID
													INNER JOIN COMPONENT C ON ITEM.COMPONENTID = C.COMPONENTID
													INNER JOIN MANUFACTURER M ON C.MANUFACTURERID = M.MANUFACTURERID
											  WHERE YEAR(PO.ORDERDATE) = '2003'
											  GROUP BY C.COMPONENTID, M.MANUFACTURERNAME, C.PRODUCTNUMBER, C.CATEGORY 
											  ORDER BY SUM(ITEM.PRICEPAID * ITEM.QUANTITY) DESC)

--13. WHICH EMPLOYEE PAINTED THE MOST RED RACE BIKES IN MAY 2003?
SELECT  E.EMPLOYEEID, E.LASTNAME, COUNT(B.SERIALNUMBER) AS 'NUM_PAINTED'
FROM	BICYCLE B INNER JOIN EMPLOYEE E ON B.EMPLOYEEID =  E.EMPLOYEEID
		INNER JOIN PAINT P ON B.PAINTID = P.PAINTID
WHERE	B.MODELTYPE = 'RACE' 
		AND P.COLORLIST = 'RED'
		AND YEAR(B.ORDERDATE) = '2003'
		AND MONTH(B.ORDERDATE) = '05'
GROUP BY E.EMPLOYEEID, E.LASTNAME
ORDER BY COUNT(B.SERIALNUMBER)
		
--14. WHICH CALIFORNIA BIKE SHOP HELPED SELL THE MOST BIKES (BY VALUE) IN 2003?
SELECT	R.STOREID, R.STORENAME, C.CITY, SUM(B.SALEPRICE) AS 'SUMOFSALEPRICE'
FROM	RETAILSTORE R INNER JOIN BICYCLE B ON B.STOREID = R.STOREID
		RIGHT OUTER JOIN CITY C ON R.CITYID = C.CITYID
WHERE	YEAR(B.ORDERDATE) = '2003'
		AND C.STATE = 'CA'
GROUP BY R.STOREID, R.STORENAME, C.CITY
HAVING	SUM(B.SALEPRICE) = (SELECT TOP 1 SUM(B.SALEPRICE)
							FROM	RETAILSTORE R INNER JOIN BICYCLE B ON B.STOREID = R.STOREID
									RIGHT OUTER JOIN CITY C ON R.CITYID = C.CITYID
							WHERE	YEAR(B.ORDERDATE) = '2003'
									AND C.STATE = 'CA'
							GROUP BY R.STOREID, R.STORENAME, C.CITY
							ORDER BY SUM(B.SALEPRICE) DESC)

--15  WHAT IS THE TOTAL WEIGHT OF THE COMPONENTS ON BICYCLE 11356?
SELECT	SUM(C.WEIGHT) AS 'TOTAL_WEIGHT'
FROM	BICYCLE B INNER JOIN BIKEPARTS BP ON BP.SERIALNUMBER = B.SERIALNUMBER
		INNER JOIN COMPONENT C ON BP.COMPONENTID = C.COMPONENTID
WHERE	B.SERIALNUMBER = 11356

--16.  WHAT IS THE TOTAL LIST PRICE OF ALL ITEMS IN THE 2002 CAMPY RECORD GROUPO?
SELECT	G.GROUPNAME, SUM(CO.LISTPRICE) AS 'SUMOFLISTPRICE'
FROM	GROUPO G INNER JOIN GROUPCOMPONENTS GC ON GC.GROUPID = G.COMPONENTGROUPID
		INNER JOIN COMPONENT CO ON GC.COMPONENTID = CO.COMPONENTID
GROUP BY G.GROUPNAME
HAVING	G.GROUPNAME = 'CAMPY RECORD 2002'

--17. IN 2003, WERE MORE RACE BIKES BUILT FROM CARBON OR TITANIUM (BASED ON THE DOWN TUBE)?
SELECT	T.MATERIAL, COUNT(B.SERIALNUMBER) AS 'COUNTOFSERIALNUMBER'
FROM	TUBEMATERIAL T INNER JOIN BICYCLETUBEUSAGE BT ON T.TUBEID = BT.TUBEID
		INNER JOIN	BICYCLE B ON BT.SERIALNUMBER = B.SERIALNUMBER
		INNER JOIN BIKETUBES BTB ON BTB.SERIALNUMBER = B.SERIALNUMBER
WHERE	T.MATERIAL IN ('CARBON FIBER', 'TITANIUM')
		AND YEAR(B.STARTDATE) = '2003'
		AND B.MODELTYPE = 'RACE'
		AND BTB.TUBENAME = 'DOWN'
GROUP BY T.MATERIAL

--18. WHAT IS THE AVERAGE PRICE PAID FOR THE 2001 SHIMANO XTR REAR DERAILLEURS?
SELECT	ROUND(AVG(P.PRICEPAID),2) AS 'AVG_OF_PRICE_PAID'
FROM	COMPONENT C INNER JOIN PURCHASEITEM P ON P.COMPONENTID = C.COMPONENTID
		INNER JOIN MANUFACTURER M ON M.MANUFACTURERID = C.MANUFACTURERID
WHERE	M.MANUFACTURERNAME LIKE 'SHIMANO%'
		AND C.YEAR = '2001' 
		AND C.CATEGORY = 'REAR DERAILLEUR'
		AND C.PRODUCTNUMBER LIKE '%XTR%'

--19. WHAT IS THE AVERAGE TOP TUBE LENGTH FOR A 54 CM (FRAMESIZE) ROAD BIKE BUILT IN 1999?
SELECT	AVG(B.TOPTUBE) AS 'AVG_OF_TOP_TUBE'
FROM	BICYCLE B
WHERE	B.FRAMESIZE = 54
		AND B.MODELTYPE = 'ROAD'
		AND YEAR(B.STARTDATE) = '1999'

--20. ON AVERAGE, WHICH COSTS (LIST PRICE) MORE: ROAD TIRES OR MOUNTAIN BIKES TIRES?	
SELECT	C.ROAD, ROUND(AVG(C.LISTPRICE),2) AS 'AVG_LIST_PRICE'
FROM	COMPONENT C
WHERE	C.ROAD IN ('ROAD', 'MTB')
GROUP BY C.ROAD
ORDER BY AVG_LIST_PRICE DESC

--21  IN MAY 2003, WHICH EMPLOYEES SOLD ROAD BIKES THAT THEY ALSO PAINTED?
SELECT	E.EMPLOYEEID, E.LASTNAME
FROM	EMPLOYEE E INNER JOIN BICYCLE B ON E.EMPLOYEEID = B.EMPLOYEEID
WHERE	YEAR(B.ORDERDATE) = '2003'
		AND MONTH(B.ORDERDATE) = '05'
		AND	B.MODELTYPE = 'ROAD'
		AND B.PAINTER  = B.EMPLOYEEID
GROUP BY E.EMPLOYEEID, E.LASTNAME

--22. IN 2002, WAS THE OLD ENGLISH LETTER STYLE MORE POPULAR WITH SOME PAINT JOBS?
SELECT DISTINCT	P.PAINTID, P.COLORNAME, COUNT(B.SERIALNUMBER) AS 'NUMBER_OF_BIKES_PAINTED'
FROM	PAINT P INNER JOIN BICYCLE B ON P.PAINTID = B.PAINTID
WHERE	B.LETTERSTYLEID = 'ENGLISH'
		AND YEAR(B.ORDERDATE) = '2002'
GROUP BY P.PAINTID, P.COLORNAME
ORDER BY NUMBER_OF_BIKES_PAINTED DESC

--23  WHICH RACE BIKES IN 2003 SOLD FOR MORE THAN THE AVERAGE PRICE OF RACE BIKES IN 2002?
SELECT B.SERIALNUMBER, B.MODELTYPE, B.ORDERDATE, B.SALEPRICE 
FROM BICYCLE B
WHERE B.MODELTYPE = 'RACE'
      AND YEAR(B.ORDERDATE) = '2003'
      AND B.SALEPRICE > (SELECT AVG(B.SALEPRICE)
                         FROM	BIKE..BICYCLE B
                         WHERE	B.MODELTYPE = 'RACE'
								AND YEAR(B.ORDERDATE) = '2002')
ORDER BY B.ORDERDATE DESC

--24. WHICH COMPONENT THAT HAD NO SALES (INSTALLATIONS) IN 2004 HAS THE HIGHEST 
--    INVENTORY VALUE (COST BASIS)?
SELECT DISTINCT M.MANUFACTURERNAME, CO.PRODUCTNUMBER, CO.CATEGORY, (CO.ESTIMATEDCOST * CO.QUANTITYONHAND) AS 'VALUE', CO.COMPONENTID
FROM	MANUFACTURER M INNER JOIN COMPONENT CO ON M.MANUFACTURERID = CO.MANUFACTURERID
		INNER JOIN BIKEPARTS BP ON CO.COMPONENTID = BP.COMPONENTID
WHERE	YEAR(BP.DATEINSTALLED) <> '2004'
		AND (CO.ESTIMATEDCOST * CO.QUANTITYONHAND) = (SELECT MAX(CO.ESTIMATEDCOST * CO.QUANTITYONHAND)
													  FROM MANUFACTURER M INNER JOIN COMPONENT CO ON M.MANUFACTURERID = CO.MANUFACTURERID
													  INNER JOIN BIKEPARTS BP ON CO.COMPONENTID = BP.COMPONENTID
													  WHERE YEAR(BP.DATEINSTALLED) <> '2004')

--25. CREATE A VENDOR CONTACTS LIST OF ALL MANUFACTURERS AND RETAIL STORES IN 
--	  CALIFORNIA. INCLUDE ONLY THE COLUMNS FOR VENDORNAME AND PHONE. THE RETAIL STORES 
--    ONLY INCLUDE STORES THAT PARTICIPATED IN THE SALE OF AT LEAST ONE BICYCLE IN 2004.
SELECT	M.MANUFACTURERNAME AS 'STORE NAME OR MANUFACTURER NAME', M.PHONE
FROM	MANUFACTURER M INNER JOIN CITY CY ON M.CITYID = CY.CITYID
WHERE	CY.STATE = 'CA'
UNION
SELECT	S.STORENAME, S.PHONE
FROM	BICYCLE B INNER JOIN RETAILSTORE S ON B.STOREID = S.STOREID
		INNER JOIN CITY CY ON S.CITYID = CY.CITYID
WHERE	CY.STATE = 'CA'
		AND YEAR(B.ORDERDATE) = '2004'

--26  LIST ALL OF THE EMPLOYEES WHO REPORT TO VENETIAAN.
SELECT	EM.LASTNAME, E.EMPLOYEEID, E.LASTNAME, E.FIRSTNAME, E.TITLE
FROM	EMPLOYEE E INNER JOIN EMPLOYEE EM ON EM.EMPLOYEEID = E.CURRENTMANAGER
WHERE	EM.LASTNAME = 'VENETIAAN'
ORDER BY E.LASTNAME ASC

--27  LIST THE COMPONENTS WHERE THE COMPANY PURCHASED AT LEAST 25 PERCENT MORE UNITS 
--THAN IT USED THROUGH JUNE 30, 2000. AN ITEM IS USED IF IT HAS AN INSTALL DATE.
SELECT	CO.COMPONENTID, M.MANUFACTURERNAME, CO.PRODUCTNUMBER, CO.CATEGORY, SUM(ITEM.QUANTITYRECEIVED) AS TOTALRECEIVED,
		COUNT(BP.DATEINSTALLED) AS 'TOTALUSED',
		(SUM(ITEM.QUANTITYRECEIVED) - COUNT(BP.DATEINSTALLED))*(CO.LISTPRICE - ITEM.PRICEPAID) AS 'NETGAIN',
		((SUM(ITEM.QUANTITYRECEIVED) - COUNT(BP.DATEINSTALLED))*100)/SUM(ITEM.QUANTITYRECEIVED) AS 'NETPCT',
		CO.LISTPRICE
FROM	COMPONENT CO INNER JOIN BIKEPARTS BP ON CO.COMPONENTID = BP.COMPONENTID
		INNER JOIN PURCHASEITEM ITEM ON CO.COMPONENTID = ITEM.COMPONENTID
		INNER JOIN MANUFACTURER M ON M.MANUFACTURERID = CO.MANUFACTURERID
		INNER JOIN PURCHASEORDER PO ON ITEM.PURCHASEID = PO.PURCHASEID
WHERE	PO.RECEIVEDATE <= '2000-06-30'
GROUP BY CO.COMPONENTID, M.MANUFACTURERNAME, CO.PRODUCTNUMBER, CO.CATEGORY, CO.LISTPRICE, ITEM.PRICEPAID
HAVING	SUM(ITEM.QUANTITYRECEIVED) >= COUNT(BP.DATEINSTALLED)*1.25

--28  IN WHICH YEARS DID THE AVERAGE BUILD TIME FOR THE YEAR EXCEED THE OVERALL 
--AVERAGE BUILD TIME FOR ALL YEARS? THE BUILD TIME IS THE DIFFERENCE BETWEEN ORDER DATE 
--AND SHIP DATE.
SELECT	YEAR(B.ORDERDATE) AS 'YEAR', AVG(DATEDIFF(DAY, B.ORDERDATE, B.SHIPDATE)) AS 'BUILDTIME'
FROM	BICYCLE B
GROUP BY YEAR(B.ORDERDATE)
HAVING	AVG(DATEDIFF(DAY, B.ORDERDATE, B.SHIPDATE))  >  (SELECT AVG(DATEDIFF(DAY, B.ORDERDATE, B.SHIPDATE)) AS BUILDTIME
														 FROM BICYCLE B)
ORDER BY YEAR(B.ORDERDATE)
