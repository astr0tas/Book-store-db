-- thủ tục delete sẽ kiểm tra các trang thai cua nhung khach hang neu trang thai la 0 (tuc duoc phep xoa) thi xoa no
USE bookstore;

CREATE PROCEDURE deleteCustomers()
BEGIN
    -- neu da xuat hien bang tam thi xoa
    DROP TEMPORARY TABLE IF EXISTS temp_table;
    -- tao bang tam chua id cua nhung tai khoan khach hang dang khong hoat dong
    CREATE TEMPORARY TABLE temp_table (idToDelete VARCHAR(10));
    INSERT INTO temp_table
    SELECT id FROM customer WHERE status != true;
    IF (SELECT COUNT(*) FROM temp_table) > 0 THEN
        SELECT 'Da xoa nhung tai khoan khach hang khong hoat dong';
    ELSE 
        SELECT 'Moi tai khoan khach hang deu dang hoat dong';
	END IF;
    -- xoa nhung khach hang co tai khoan khong hoat dong
    DELETE FROM customer WHERE id IN (SELECT idToDelete FROM temp_table);
END;

----------------------
CALL deleteCustomers();