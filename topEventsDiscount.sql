DELIMITER //

-- Create a stored procedure to get information about the top events based on the number of orders

CREATE PROCEDURE GetTopEventDiscounts()
BEGIN
    -- Create a temporary table to store the result
    CREATE TEMPORARY TABLE TempEventOrderCount AS
    SELECT
        ed.discount AS event_discount,
        COUNT(co.id) AS order_count
    FROM
        eventDiscount ed
    JOIN
        customerOrder co ON co.orderTime BETWEEN ed.startDate AND ed.endDate
    GROUP BY
        ed.discount
    ORDER BY
        order_count DESC;

    -- Select the desired number of rows from the temporary table
    SELECT * FROM TempEventOrderCount LIMIT 5;

    -- Drop the temporary table
    DROP TEMPORARY TABLE IF EXISTS TempEventOrderCount;
END //

DELIMITER ;
