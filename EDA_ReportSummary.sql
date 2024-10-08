				-- Management requested summary 
				
-- Total amount purchased from each supplier.  
SELECT SUM(PurchaseAmount) TotalAmountPurchased, 
ST.SupplierID, 
CONCAT(S.FirstName, ' ', S.LastName) SupplierName
FROM ods.SupplierTrans ST
JOIN ods.Supplier S ON ST.SupplierID = S.SupplierID
GROUP BY ST.SupplierID, CONCAT(S.FirstName, ' ', S.LastName)
ORDER BY ST.SupplierID



-- Total amount purchased from each supplier and their countries.  
SELECT SUM(PurchaseAmount) TotalAmountPurchased, 
	ST.SupplierID, 
	CONCAT(S.FirstName, ' ', S.LastName) SupplierName,
	CT.CountryName SupplierCountry
FROM ods.SupplierTrans ST
JOIN ods.Supplier S ON ST.SupplierID = S.SupplierID
LEFT JOIN ods.SupplierAddress SA ON S.AddressID = SA.AddressID
LEFT JOIN ods.City C ON SA.cityID = C.cityID
LEFT JOIN ods.StateProvince SP ON C.ProvinceID = SP.ProvinceID
LEFT JOIN ods.Country CT ON SP.CountryID = CT.CountryID
GROUP BY ST.SupplierID, CONCAT(S.FirstName, ' ', S.LastName), CountryName
ORDER BY ST.SupplierID



-- Total amount purchased from each country.  
SELECT SUM(PurchaseAmount) TotalAmountPurchased, 
	CT.CountryName
FROM ods.SupplierTrans ST
JOIN ods.Supplier S ON ST.SupplierID = S.SupplierID
LEFT JOIN ods.SupplierAddress SA ON S.AddressID = SA.AddressID
LEFT JOIN ods.City C ON SA.cityID = C.cityID
LEFT JOIN ods.StateProvince SP ON C.ProvinceID = SP.ProvinceID
LEFT JOIN ods.Country CT ON SP.CountryID = CT.CountryID
GROUP BY CountryName
ORDER BY TotalAmountPurchased DESC



-- Total amount purchased by city in each country.  
SELECT SUM(PurchaseAmount) TotalAmountPurchased,
	CityName,
	CT.CountryName
FROM ods.SupplierTrans ST
JOIN ods.Supplier S ON ST.SupplierID = S.SupplierID
LEFT JOIN ods.SupplierAddress SA ON S.AddressID = SA.AddressID
LEFT JOIN ods.City C ON SA.cityID = C.cityID
LEFT JOIN ods.StateProvince SP ON C.ProvinceID = SP.ProvinceID
LEFT JOIN ods.Country CT ON SP.CountryID = CT.CountryID
GROUP BY ROLLUP (CountryName, CityName)



--Total amount purchased in ALL countries
SELECT SUM(PurchaseAmount) TotalAmountPurchased, 
	CT.CountryName
FROM ods.SupplierTrans ST
JOIN ods.Supplier S ON ST.SupplierID = S.SupplierID
LEFT JOIN ods.SupplierAddress SA ON S.AddressID = SA.AddressID
LEFT JOIN ods.City C ON SA.cityID = C.cityID
LEFT JOIN ods.StateProvince SP ON C.ProvinceID = SP.ProvinceID
FULL OUTER JOIN ods.Country CT ON SP.CountryID = CT.CountryID
GROUP BY CountryName
ORDER BY TotalAmountPurchased DESC



--Quantity of items ordered from each Supplier
SELECT ST.SupplierID, 
	CONCAT(S.FirstName, ' ', S.LastName) SupplierName,
	SUM(OrderQty) QuantityOrdered
from ods.SupplierTrans ST
JOIN ods.Supplier S ON ST.SupplierID = S.SupplierID
Group by ST.SupplierID, CONCAT(S.FirstName, ' ', S.LastName)
ORDER BY QuantityOrdered DESC

		--Suppliers ordered from the most.
		SELECT TOP 5 ST.SupplierID, 
			CONCAT(S.FirstName, ' ', S.LastName) SupplierName,
			SUM(OrderQty) QuantityOrdered
		from ods.SupplierTrans ST
		JOIN ods.Supplier S ON ST.SupplierID = S.SupplierID
		Group by ST.SupplierID, CONCAT(S.FirstName, ' ', S.LastName)
		ORDER BY QuantityOrdered DESC



		--Ranked quantity of items ordered, by City and country
WITH QuantityOrdered AS (
	SELECT 
		SUM(OrderQty) QuantityOrdered,
		C.CityName, 
		CT.CountryName
	from ods.SupplierTrans ST
	JOIN ods.Supplier S ON ST.SupplierID = S.SupplierID
	LEFT JOIN ods.SupplierAddress SA ON S.AddressID = SA.AddressID
	LEFT JOIN ods.City C ON SA.cityID = C.cityID
	LEFT JOIN ods.StateProvince SP ON C.ProvinceID = SP.ProvinceID
	LEFT JOIN ods.Country CT ON SP.CountryID = CT.CountryID
	Group by CT.CountryName, C.CityName
	--ORDER BY CountryName
), CityRank AS (
	SELECT *, DENSE_RANK () OVER (Partition BY CountryName ORDER BY QuantityOrdered) AS Ranking
	FROM QuantityOrdered
)
SELECT * FROM CityRank



--Number of transactions by city and country
SELECT COUNT(ST.TransID) NoOfTransactions, 
	C.CityName,
	CT.CountryName
FROM ods.SupplierTrans ST
JOIN ods.Supplier S ON ST.SupplierID = S.SupplierID
LEFT JOIN ods.SupplierAddress SA ON S.AddressID = SA.AddressID
LEFT JOIN ods.City C ON SA.cityID = C.cityID
LEFT JOIN ods.StateProvince SP ON C.ProvinceID = SP.ProvinceID
LEFT JOIN ods.Country CT ON SP.CountryID = CT.CountryID
GROUP BY ROLLUP(CountryName, C.CityName)
ORDER BY CountryName

	--Ranked NoOfTransactions by city and country.
	WITH NoOfTransactions AS (
		SELECT COUNT(ST.TransID) NoOfTransactions, 
			C.CityName,
			CT.CountryName
		FROM ods.SupplierTrans ST
		JOIN ods.Supplier S ON ST.SupplierID = S.SupplierID
		LEFT JOIN ods.SupplierAddress SA ON S.AddressID = SA.AddressID
		LEFT JOIN ods.City C ON SA.cityID = C.cityID
		LEFT JOIN ods.StateProvince SP ON C.ProvinceID = SP.ProvinceID
		LEFT JOIN ods.Country CT ON SP.CountryID = CT.CountryID
		GROUP BY CountryName, C.CityName
	), RankedTransactions AS (
		SELECT *, DENSE_RANK() OVER(PARTITION BY CountryName ORDER BY NoOfTransactions) as TransactionRank
		FROM NoOfTransactions
	)
	SELECT * FROM RankedTransactions



--Total amount in purchases done by each employee
SELECT SUM(PurchaseAmount) AmountPurchased, EmployeeID FROM ods.SupplierTrans ST
	JOIN ods.Supplier S ON ST.SupplierID = S.SupplierID
	LEFT JOIN ods.SupplierAddress SA ON S.AddressID = SA.AddressID
	LEFT JOIN ods.City C ON SA.cityID = C.cityID
	LEFT JOIN ods.StateProvince SP ON C.ProvinceID = SP.ProvinceID
	LEFT JOIN ods.Country CT ON SP.CountryID = CT.CountryID
GROUP BY EmployeeID
ORDER BY EmployeeID


--Total quantity of supplies ordered by each employee
SELECT SUM(OrderQty) QuantityOrdered, EmployeeID FROM ods.SupplierTrans ST
	JOIN ods.Supplier S ON ST.SupplierID = S.SupplierID
	LEFT JOIN ods.SupplierAddress SA ON S.AddressID = SA.AddressID
	LEFT JOIN ods.City C ON SA.cityID = C.cityID
	LEFT JOIN ods.StateProvince SP ON C.ProvinceID = SP.ProvinceID
	LEFT JOIN ods.Country CT ON SP.CountryID = CT.CountryID
GROUP BY EmployeeID
ORDER BY EmployeeID



-- Average order processing time (time from order to shipping) for each product
SELECT ST.ProductID, P.ProductName,
AVG(DATEDIFF(DAY, OrderDate, ShipDate)) [AverageOrderTime(Days)]
FROM ods.SupplierTrans ST
JOIN ods.Product P ON ST.productID = P.ProductID
GROUP BY ST.ProductID, P.ProductName
ORDER BY [AverageOrderTime(Days)] DESC


