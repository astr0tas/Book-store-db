DELIMITER //

CREATE FUNCTION PRICEAFTERDISCOUNT(
    nameEvent VARCHAR(20),
    bookID VARCHAR(10)
) 
RETURNS DOUBLE
DETERMINISTIC
BEGIN
    DECLARE discountPercentVariable DOUBLE;
    DECLARE originalPrice DOUBLE;
    DECLARE priceAfterDiscount DOUBLE;

    SET discountPercentVariable = 0.0;
    SET priceAfterDiscount = 0.0;
	SET originalPrice = 0.0;
    -- Get the original price from the book
    SELECT price INTO originalPrice FROM book WHERE id = bookID;
    IF originalPrice > 0 THEN
		IF nameEvent IS NOT NULL THEN
			-- Get the discount percent
			SELECT discountPercent INTO discountPercentVariable FROM eventdiscount WHERE discount = nameEvent;
			-- Check if the discount percent is not null and within the valid range
			IF discountPercentVariable IS NOT NULL AND discountPercentVariable > 0 AND discountPercentVariable < 100 THEN
            -- Calculate the discounted price
				SET priceAfterDiscount = originalPrice - (originalPrice * discountPercentVariable / 100);
			ELSE
            -- Handle the case where discountPercent is not within the valid range
				SET priceAfterDiscount = originalPrice; 
			END IF;
		END IF;
    ELSE
		RETURN NULL;
    END IF;
    RETURN priceAfterDiscount ;
END //

DELIMITER ;
