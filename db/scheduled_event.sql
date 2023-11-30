use bookstore;

SET GLOBAL event_scheduler = on;
-- SHOW VARIABLES LIKE 'event_scheduler';

drop table if exists refreshOrderCostLog;

CREATE TABLE IF NOT EXISTS refreshOrderCostLog (
    logId INT AUTO_INCREMENT PRIMARY KEY,
    executionTime TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- select * from refreshOrderCostLog; 

drop event if exists refreshOrderCost;
DELIMITER //
CREATE EVENT IF NOT EXISTS refreshOrderCost
ON SCHEDULE EVERY 2 minute
DO
BEGIN
	insert into refreshOrderCostLog values();
    CALL refreshOrderCostProcedure();
END //
DELIMITER ;
