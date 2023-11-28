USE bookstore;
DELIMITER //

CREATE PROCEDURE GetTop5BestSellers(
    IN startDateParam DATE,
    IN endDateParam DATE
)
BEGIN
    SELECT
        b.id AS BookID,
        b.name AS BookName,
        SUM(TotalSales) AS TotalSales
    FROM (
        SELECT
            oc.book,
            SUM(oc.amount) AS TotalSales
        FROM
            (
                SELECT DISTINCT
                    oc.orderID,
                    oc.book,
                    oc.amount
                FROM
                    customerOrder co
                JOIN
                    physicalOrderContain oc ON co.id = oc.orderID
                WHERE
                    co.orderTime BETWEEN startDateParam AND endDateParam
                    AND co.status = 1
            ) oc
        GROUP BY
            oc.orderID, oc.book

        UNION

        SELECT
            foc.book,
            COUNT(DISTINCT foc.orderID) AS TotalSales
        FROM
            customerOrder co
        JOIN
            fileOrderContain foc ON co.id = foc.orderID
        JOIN
            fileCopy fc ON foc.book = fc.book AND foc.number = fc.number
        WHERE
            co.orderTime BETWEEN startDateParam AND endDateParam
            AND co.status = 1
        GROUP BY
            foc.book
    ) AS SalesSubquery
    JOIN
        book b ON SalesSubquery.book = b.id
    GROUP BY
        b.id, b.name
    ORDER BY
        TotalSales DESC
    LIMIT 5;
END //

DELIMITER ;

CALL GetTop5BestSellers('2023-11-01', '2023-12-01');
