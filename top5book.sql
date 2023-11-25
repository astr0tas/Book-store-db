USE dbname;
GO

CREATE PROCEDURE GetTop5BestSellers
    @StartDate DATE,
    @EndDate DATE
AS
BEGIN
    SELECT TOP 5
        b.name AS BookName,
        SUM(oc.amount) AS TotalSold
    FROM
        customerOrder co
    JOIN
        physicalOrderContain oc ON co.id = oc.orderID
    JOIN
        edition e ON oc.book = e.id AND oc.number = e.number
    JOIN
        book b ON e.id = b.id
    WHERE
        co.orderTime BETWEEN @StartDate AND @EndDate
    GROUP BY
        b.name
    ORDER BY
        TotalSold DESC;
END;
GO
----------------------------------
USE dbname;
EXEC GetTop5BestSellers '2023-01-01', '2023-12-31';
