cập nhật số sao trung bình khi có những thay đổi (insert,update,delete) trong bảng rating
USE bookstore;
drop trigger if exists updatestaredition_insert_rating;
DELIMITER //
-- cập nhật số sao trung bình khi insert, update, delete bảng rating
CREATE TRIGGER updatestaredition_after_rating
AFTER INSERT, UPDATE, DELETE ON rating
FOR EACH ROW
BEGIN
    DECLARE total_star_Ratings int;
    DECLARE totalRatings int = 0;
    DECLARE newAverageRating double;

    -- tính tổng số đánh giá và tổng số sao đánh giá
    SELECT COUNT(*), SUM(star) INTO totalRatings, total_star_Ratings
    FROM rating
    WHERE book = NEW.book AND number = NEW.number;
    -- nếu có đánh giá thì mới tính tránh lỗi chia cho 0
    IF totalRatings > 0 THEN
    -- Tính toán điểm trung bình mới
    SET newAverageRating = total_star_Ratings / totalRatings;
    -- Cập nhật điểm trung bình mới vào bảng edition
    UPDATE edition
    SET avgStar = newAverageRating
    WHERE book = NEW.book AND number = NEW.number;
    END IF;
END;
//
DELIMITER ;
