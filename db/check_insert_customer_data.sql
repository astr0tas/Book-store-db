DELIMITER //
CREATE TRIGGER check_insert_customer_data
BEFORE INSERT ON customer
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1 
        FROM customer 
        WHERE id = NEW.id 
            OR phone = NEW.phone 
            OR cardNumber = NEW.cardNumber 
            OR email = NEW.email 
            OR username = NEW.username
    ) AND NEW.id IS NULL
    THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Duplicate entry for customer data';
    END IF;
END;
//
DELIMITER ;
