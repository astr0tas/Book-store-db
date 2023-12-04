DROP PROCEDURE IF EXISTS insertNewCustomer;
DELIMITER //
CREATE PROCEDURE insertNewCustomer(
    IN name VARCHAR(100),
    IN dob VARCHAR(10),
    IN address TEXT,
    IN phone VARCHAR(10),
    IN cardNumber VARCHAR(16),
    IN email VARCHAR(100),
    IN username VARCHAR(20),
    IN password VARCHAR(20),
    IN referrerEmail VARCHAR(100)
)
BEGIN
    DECLARE emailExists INT;
    DECLARE phoneExists INT;
    DECLARE errorMessage VARCHAR(255);
	DECLARE referrerID VARCHAR(20) DEFAULT NULL;
    
    -- Kiểm tra tên
    IF name IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Name cannot be empty.';
    END IF;

    -- Kiểm tra ngày sinh (dob)
    IF dob IS NULL THEN
           SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: No date of birth provided.';
        ELSE
            IF date_add(dob,interval 16 year) > curdate() THEN
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Age must be at least 16 years old.';
            END IF;
    END IF;

    -- Kiểm tra địa chỉ
	IF address IS NULL THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Address cannot be empty.';
	END IF;

    -- Kiểm tra số điện thoại
    IF phone IS NULL THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Phone number cannot be empty.';
	ELSE 
		IF NOT phone REGEXP '^[0-9]{10}$' THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Customer\'s phone contain non-numeric character!';
		ELSE
			-- Kiểm tra trùng lặp số điện thoại
            BEGIN
				DECLARE isFound BOOLEAN DEFAULT FALSE;
                SELECT EXISTS(SELECT * FROM customer WHERE customer.phone=phone) INTO isFound;
                IF isFound THEN
					SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: The provided phone has already been used!';
                END IF;
            END;
		END IF;
    END IF;

    -- Kiểm tra email
    IF email IS NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Email cannot be empty.';
	ELSE 
		IF NOT email REGEXP '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}$' THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Invalid email format.';
		ELSE 
			-- Kiểm tra trùng lặp email
			BEGIN
				DECLARE isFound BOOLEAN DEFAULT FALSE;
                SELECT EXISTS(SELECT * FROM customer WHERE customer.email=email) INTO isFound;
                IF isFound THEN
					SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: The provided email has already been used!';
                END IF;
            END;
		END IF;
    END IF;

    -- Kiểm tra số thẻ
    IF cardNumber IS NULL THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Card number cannot be empty.';
	ELSE 
		IF cardNumber REGEXP '^[0-9]+$' THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Invalid card number format.';
        ELSE
        -- Kiểm tra trùng lặp số thẻ
			BEGIN
				DECLARE isFound BOOLEAN DEFAULT FALSE;
                SELECT EXISTS(SELECT * FROM customer WHERE customer.cardNumber=cardNumber) INTO isFound;
                IF isFound THEN
					SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: The provided card number has already been used!';
                END IF;
            END;
		END IF;
    END IF;

    -- Kiểm tra username
    IF username IS NULL THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Username cannot be empty.';
	ELSE
		IF LENGTH(username) < 6 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Username must be at least 6 characters long.';
        ELSE
			-- Kiểm tra trùng lặp username
			BEGIN
				DECLARE isFound BOOLEAN DEFAULT FALSE;
				SELECT EXISTS(SELECT * FROM customer WHERE customer.username=username) INTO isFound;
				IF isFound THEN
					SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Duplicate username.';
				END IF;
			END;
		END IF;
	END IF;

    -- Kiểm tra mật khẩu
   IF password IS NULL THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Password cannot be empty.';
	ELSE 
		IF LENGTH(password) <= 8 THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Password must be more than 8 characters long!';
		END IF;
	END IF;

    -- Kiểm tra email người giới thiệu (referrerEmail)
    IF referrerEmail IS NULL THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Referrer email cannot be empty.';
	ELSE
		IF referrerEmail IS NOT NULL THEN
			SELECT id INTO referrerID FROM customer WHERE customer.email=referrerEmail;
				IF referrerID IS NULL THEN
					SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Referrer\'s email not found!';
				END IF;
		END IF;
	END IF;
	
     BEGIN
		DECLARE counter INT DEFAULT 0;
        SELECT cast(substr(id,9) AS UNSIGNED) INTO counter FROM customer ORDER BY cast(substr(id,9) AS UNSIGNED) DESC LIMIT 1;
        SET counter:=counter+1;
        INSERT INTO customer VALUES(concat('CUSTOMER',counter),name,dob,address,phone,cardNumber,0,email,username,password,referrerID,true);
    END;
END //
DELIMITER ;