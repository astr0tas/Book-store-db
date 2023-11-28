-- Change the database context
USE bookstore;

-- Delimiter change to handle the 'GO' keyword
DELIMITER //

CREATE PROCEDURE GetTop5BestSellers (
    IN p_StartDate DATE,
    IN p_EndDate DATE
)
BEGIN
    SELECT
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
        co.orderTime BETWEEN p_StartDate AND p_EndDate
        AND co.status = 1 -- Add this condition to filter orders with status = 1
    GROUP BY
        b.name

    UNION

    SELECT
        b.name AS BookName,
        COUNT(oc.book) AS TotalSold
    FROM
        customerOrder co
    JOIN
        fileOrderContain oc ON co.id = oc.orderID
    JOIN
        edition e ON oc.book = e.id AND oc.number = e.number
    JOIN
        book b ON e.id = b.id
    WHERE
        co.orderTime BETWEEN p_StartDate AND p_EndDate
        AND co.status = 1 -- Add this condition to filter orders with status = 1
    GROUP BY
        b.name
    ORDER BY
        TotalSold DESC
    LIMIT 5;
END //

-- Reset the delimiter
DELIMITER ;
CALL GetTop5BestSellers('2023-01-01', '2023-12-31');
