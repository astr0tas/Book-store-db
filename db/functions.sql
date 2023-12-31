-- use bookstore;

-- drop function if exists priceAfterDiscount;
-- SET GLOBAL log_bin_trust_function_creators = 1;
-- DELIMITER //
-- CREATE FUNCTION priceAfterDiscount(
--     bookID varchar(20),
--     purchaseTime datetime,
--     orderId varchar(20)
-- ) 
-- RETURNS DOUBLE
-- BEGIN
-- 	if bookID is null then
-- 		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '`bookID` parameter is null!';
--     end if;
--     
--     if not exists(select * from book where id=bookID) then
-- 		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Can not find book from the provided bookID!';
--     end if;
--     
--     if purchaseTime is null then
-- 		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '`purchaseTime` parameter is null!';
--     end if;
--     
--     if purchaseTime is not null and purchaseTime>now() then
-- 		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '`purchaseTime` parameter value is in the future?';
--     end if;
--     
--     if orderId is null then
-- 		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '`orderId` parameter is null!';
--     end if;
--     
-- 	if not exists(select * from customerOrder where id=orderId) then
-- 		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Can not find order from the provided orderId!';
--     end if;
--     
--     begin
--     DECLARE discountPercentVariable DOUBLE default 0;
--     DECLARE originalPrice DOUBLE default 0;
--     declare discountEventId varchar(20) default null;
--     
--     -- Get the original price from the book
--     SELECT price INTO originalPrice FROM book WHERE id = bookID;
--     
--     IF originalPrice > 0 THEN
-- 		begin
-- 			DECLARE done BOOLEAN DEFAULT FALSE;
--             declare discountId varchar(20) default null;
-- 			DECLARE myCursor CURSOR FOR SELECT discount FROM eventDiscount where startDate<=purchaseTime and purchaseTime<=endDate order by discountPercent desc,discount asc;
-- 			DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
-- 			OPEN myCursor;
-- 			loop_start: LOOP
-- 				set discountId:=null;
-- 				FETCH myCursor INTO discountId;
-- 				IF done THEN
-- 					LEAVE loop_start;
-- 				END IF;
--                 begin
-- 					declare isForAll boolean default false;
--                     select applyForAll into isForAll from eventDiscount where eventDiscount.discount=discountId;
--                     if isForAll then
-- 						select discountPercent,eventDiscount.discount into discountPercentVariable,discountEventId from eventDiscount where eventDiscount.discount=discountId;
-- 						set done:=true;
--                     else
-- 						begin
-- 							if exists(select* from eventApply where eventApply.book=bookID and eventApply.discount=discountId) then
-- 								select discountPercent,eventDiscount.discount into discountPercentVariable,discountEventId from eventDiscount where eventDiscount.discount=discountId;
-- 								set done:=true;
--                             end if;
--                         end;
--                     end if;
--                 end;
-- 			END LOOP loop_start;
-- 			CLOSE myCursor;
--             if discountEventId is not null and not exists(select * from discountApply where discountApply.orderId=orderId and discountApply.discount=discountEventId) then
-- 				insert into discountApply values(orderId,discountEventId);
--             end if;
--             return originalPrice-originalPrice*discountPercentVariable/100.0;
--         end;
--     ELSE
-- 		RETURN 0;
--     END IF;
--     end;
-- END //
-- DELIMITER ;
-- SET GLOBAL log_bin_trust_function_creators = 0;

-- drop function if exists GetnthEventDiscount; -- existence is questionable?
-- SET GLOBAL log_bin_trust_function_creators = 1;
-- DELIMITER //
-- CREATE function GetnthEventDiscount(
-- 	startDate date,
--     endDate date,
--     n int
-- )
-- returns varchar(20)
-- BEGIN
-- 	if startDate is null then
-- 		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '`startDate` parameter is null!';
--     end if;
--     
--     if endDate is null then
-- 		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '`endDate` parameter is null!';
--     end if;
--     
--     if startDate>endDate then
-- 		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '`startDate` value is larger than `endDate` value?';
--     end if;
--     
--     if n is null then
-- 		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '`nth` parameter is null!';
--     end if;
--     
--     if n<=0 then
-- 		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '`nth` parameter must be a positive value!';
--     end if;
--     
--     begin
--     declare result varchar(20) default null;
--     declare offsetTarget int default null;
--     
--     -- Create a temporary table to store the result
--     DROP TEMPORARY TABLE IF EXISTS TempEventOrderCount;
--     CREATE TEMPORARY TABLE TempEventOrderCount AS
--     SELECT
--         ed.discount AS event_id,
--         ed.startDate as event_start_date,
--         COUNT(co.id) AS order_count
--     FROM
--         eventDiscount ed
-- 	join
-- 		discountApply da on da.discount=ed.discount
--     JOIN
--         customerOrder co ON co.id=da.orderID
-- 	where
--         co.orderTime BETWEEN startDate AND endDate and co.status=true
--     GROUP BY
--         event_id,event_start_date
--     ORDER BY
--         order_count DESC,event_id;
-- 	
--     set offsetTarget:=n-1;
--     -- Select the desired number of rows from the temporary table
--     SELECT TempEventOrderCount.event_id into result FROM TempEventOrderCount order by TempEventOrderCount.order_count desc,event_start_date desc,cast(substr(TempEventOrderCount.event_id,11) as unsigned) limit 1 offset offsetTarget;

--     -- Drop the temporary table
--     DROP TEMPORARY TABLE IF EXISTS TempEventOrderCount;
--     
--     return result;
--     end;
-- END //
-- DELIMITER ;
-- SET GLOBAL log_bin_trust_function_creators = 0;