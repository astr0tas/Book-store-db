use bookstore;

drop function if exists priceAfterDiscount;
DELIMITER //
CREATE FUNCTION priceAfterDiscount(
    bookID VARCHAR(20),
    purchaseTime datetime,
    orderID VARCHAR(20)
) 
RETURNS DOUBLE
DETERMINISTIC
BEGIN
 -- Check for null parameters
	IF bookID is null then 
		SIGNAL SQLSTATE '45000' SET message_text = '`bookID` param is null';
    END IF;
     IF orderID is null then 
		SIGNAL SQLSTATE '45000' SET message_text = '`orderID` param is null';
    END IF;
      IF purchaseTime is null then 
		SIGNAL SQLSTATE '45000' SET message_text = '`purchaseTime` param is null';
    END IF;
      -- Check if book exists
    IF NOT EXISTS (SELECT * FROM book WHERE id = bookID ) then
		SIGNAL SQLSTATE '45000' SET message_text = 'Not found book from bookID provided!!!';
	END IF;
      -- Check if order exists
	IF NOT EXISTS (SELECT * FROM customerOrder WHERE id = orderID ) then
		SIGNAL SQLSTATE '45000' SET message_text = 'Not found your order from orderID provided!!!';
	END IF;
      -- Check if purchaseTime is correct
    IF purchaseTime > NOW() then 
		SIGNAL SQLSTATE '45000' SET message_text = '`purchaseTime` param is invalid because greater than current time!';
	END IF;
	IF purchaseTime <> (SELECT purchaseTime FROM customerOrder WHERE id = orderID) THEN
		SIGNAL SQLSTATE '45000' SET message_text = '`purchaseTime` param is invalid because it does not match the purchase time in the order!';
	END IF;
    BEGIN 
		DECLARE discountPercentVariable DOUBLE default 0.0;
		DECLARE originalPrice DOUBLE default 0.0;
		DECLARE discountEventId varchar(20) default null;
		-- Get the original price from the book
		SELECT price INTO originalPrice FROM book WHERE id = bookID;
		IF originalPrice <= 0 THEN
			RETURN NULL;
		END IF;
		SELECT
            ed.discountPercent, ed.discount INTO discountPercentVariable, discountEventId
        FROM eventDiscount ed
        WHERE ed.startDate <= purchaseTime AND purchaseTime <= ed.endDate
            AND (ed.applyForAll OR EXISTS (SELECT 1 FROM eventApply ea WHERE ea.discount = ed.discount AND ea.book = bookID))
        ORDER BY ed.discountPercent DESC, ed.discount ASC
        LIMIT 1;
        -- Apply discount to the order
        IF discountEventId IS NOT NULL AND NOT EXISTS (SELECT * FROM discountApply da WHERE da.orderId = orderID AND da.discount = discountEventId) THEN
            INSERT INTO discountApply (orderId, discount) VALUES (orderID, discountEventId);
        END IF;
        -- Calculate discounted price
        RETURN originalPrice - (originalPrice * discountPercentVariable / 100.0);
    END;
END //
DELIMITER ;

DROP FUNCTION IF EXISTS GetTopRatedBooks;
DELIMITER //
CREATE FUNCTION GetTopRatedBooks()
RETURNS VARCHAR(255)
DETERMINISTIC
BEGIN
    -- Declare variables
    DECLARE result VARCHAR(255);

    -- Create a temporary table to store the intermediate results
    CREATE TEMPORARY TABLE IF NOT EXISTS temp_table AS
    SELECT CONCAT(b.name, '_', ROUND(AVG(r.star), 1)) AS concatenated
    FROM book b
    LEFT JOIN rating r ON b.id = r.book
    GROUP BY b.id
    ORDER BY AVG(r.star) DESC
    LIMIT 5; 

    -- Concatenate the values using GROUP_CONCAT
    SELECT GROUP_CONCAT(concatenated SEPARATOR ', ')
    INTO result
    FROM temp_table;

    -- Drop the temporary table
    DROP TEMPORARY TABLE IF EXISTS temp_table;

    -- Return the result
    RETURN result;
END //
DELIMITER ;