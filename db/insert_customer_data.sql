DELIMITER //

CREATE PROCEDURE InsertCustomer(
    IN id VARCHAR(255),
    IN name VARCHAR(255),
    IN dob DATE,
    IN email VARCHAR(255),
    IN phone VARCHAR(20),
    IN cardNumber VARCHAR(15),
    IN address TEXT,
    IN status VARCHAR(6),
    IN point INT,
    IN username VARCHAR(20),
    IN password VARCHAR(20)
)
BEGIN
    INSERT INTO customer (id, name, dob, email, phone, cardNumber, address, status, point, username, password)
    VALUES (id, name, dob, email, phone, cardNumber, address, status, point, username, password);
END //

DELIMITER ;
