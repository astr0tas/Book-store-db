-- De giam thieu du lieu can luu thi chung ta nen xoa nhung tai khoan khong uy tin, thủ tục delete sẽ kiểm tra các trang thai cua nhung khach hang status la true (tuc co the bi vo hieu hoa) neu ho chua thuc hien giao dich nao thi xoa
USE bookstore;
DELIMITER //
CREATE PROCEDURE deleteCustomers()
BEGIN
    -- neu da xuat hien bang tam thi xoa
    DROP TEMPORARY TABLE IF EXISTS temp_table;
    -- tao bang tam chua id cua nhung tai khoan khach hang co status = true va chua thuc hien giao dich nao
    CREATE TEMPORARY TABLE temp_table (idToDelete VARCHAR(10));
    INSERT INTO temp_table
    SELECT id FROM customer WHERE status = true AND id NOT IN (SELECT customer FROM customerOrder WHERE status = 1);
    IF (SELECT COUNT(*) FROM temp_table) > 0 THEN
        SELECT 'Da xoa nhung tai khoan khach hang khong thuc hien giao dich nao';
    ELSE 
        SELECT 'Moi tai khoan deu hoat dong';
	END IF;
    -- xoa nhung khach hang co tai khoan chua thuc hien giao dich nao
    DELETE FROM customer WHERE id IN (SELECT idToDelete FROM temp_table);
END;
//
DELIMITER ;
----------------------
CALL deleteCustomers();