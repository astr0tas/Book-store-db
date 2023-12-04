use bookstore;

drop procedure if exists addToFileOrder;
delimiter //
create procedure addToFileOrder(
    in customer varchar(20),
    in book varchar(20),
    in edition int
)
begin
	if customer is null then
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '`customer` parameter is null!';
    end if;
    
    if not exists(select * from customer where customer.id=customer) then
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Customer not found!';
    end if;
    
    if book is null then
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '`book` parameter is null!';
    end if;
    
    if edition is null then
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '`edition` parameter is null!';
    end if;
    
    if not exists(select * from edition where id=book and number=edition) then
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'The provided book and its edition is not found!';
    end if;

	begin
	declare orderId varchar(20) default null;
	if not exists(select * from customerOrder join fileOrder on fileOrder.orderId=customerOrder.id where customerOrder.customer=customer and customerOrder.status=false order by cast(substr(customerOrder.id,6) as unsigned) desc limit 1) then
		begin
			declare counter int default 0;
            select cast(substr(id,6) as unsigned) into counter from customerOrder ORDER BY cast(substr(id,6) as unsigned) DESC LIMIT 1;
            set counter:=counter+1;
			insert into customerOrder(id,orderTime,customer) values(concat('ORDER',counter),now(),customer);
            insert into fileOrder values(concat('ORDER',counter));
        end;
    end if;
    
    select customerOrder.id into orderId from customerOrder join fileOrder on fileOrder.orderId=customerOrder.id where customerOrder.customer=customer and customerOrder.status=false order by cast(substr(customerOrder.id,6) as unsigned) desc limit 1;
    insert into fileOrderContain values(edition,book,orderId);
    
    call updateOrderCost(orderId);
    end;
end//
delimiter ;

drop procedure if exists addToPhysicalOrder;
delimiter //
create procedure addToPhysicalOrder(
    in customer varchar(20),
    in book varchar(20),
    in edition int,
    in amount int
)
begin
	if customer is null then
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '`customer` parameter is null!';
    end if;
    
    if not exists(select * from customer where customer.id=customer) then
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Customer not found!';
    end if;
    
    if book is null then
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '`book` parameter is null!';
    end if;
    
    if edition is null then
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '`edition` parameter is null!';
    end if;
    
    if not exists(select * from edition where id=book and number=edition) then
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'The provided book and its edition is not found!';
    end if;
    
    if amount is null then
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '`amount` parameter is null!';
    end if;
    
    if amount is not null and amount<1 then
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '`amount` parameter value invalid!';
    end if;
    
    begin
	declare orderId varchar(20) default null;
	if not exists(select * from customerOrder join physicalOrder on physicalOrder.orderId=customerOrder.id where customerOrder.customer=customer and customerOrder.status=false order by cast(substr(customerOrder.id,6) as unsigned) desc limit 1) then
		begin
			declare counter int default 0;
            select cast(substr(id,6) as unsigned) into counter from customerOrder ORDER BY cast(substr(id,6) as unsigned) DESC LIMIT 1;
            set counter:=counter+1;
			insert into customerOrder(id,orderTime,customer) values(concat('ORDER',counter),now(),customer);
            insert into physicalOrder values(concat('ORDER',counter));
        end;
    end if;
    
    select customerOrder.id into orderId from customerOrder join physicalOrder on physicalOrder.orderId=customerOrder.id where customerOrder.customer=customer and customerOrder.status=false order by cast(substr(customerOrder.id,6) as unsigned) desc limit 1;
    insert into physicalOrderContain values(edition,book,orderId,amount);
    
	call updateOrderCost(orderId);  
    end;
end//
delimiter ;

drop procedure if exists removeFromFileOrder;
delimiter //
create procedure removeFromFileOrder(
    in customer varchar(20),
    in book varchar(20),
    in edition int
)
begin
	if customer is null then
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '`customer` parameter is null!';
    end if;
    
    if not exists(select * from customer where customer.id=customer) then
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Customer not found!';
    end if;
    
    if book is null then
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '`book` parameter is null!';
    end if;
    
    if edition is null then
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '`edition` parameter is null!';
    end if;
    
    if not exists(select * from edition where id=book and number=edition) then
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'The provided book and its edition is not found!';
    end if;
    
    begin
	declare orderId varchar(20) default null;
    select customerOrder.id into orderId from customerOrder join fileOrder on fileOrder.orderId=customerOrder.id where customerOrder.customer=customer and customerOrder.status=false order by cast(substr(customerOrder.id,6) as unsigned) desc limit 1;
    delete from fileOrderContain where fileOrderContain.orderId=orderId and fileOrderContain.book=book and fileOrderContain.number=edition;
    
    call updateOrderCost(orderId);
    end;
end//
delimiter ;

drop procedure if exists removeFromPhysicalOrder;
delimiter //
create procedure removeFromPhysicalOrder(
    in customer varchar(20),
    in book varchar(20),
    in edition int,
    in amount int
)
begin
	if customer is null then
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '`customer` parameter is null!';
    end if;
    
    if not exists(select * from customer where customer.id=customer) then
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Customer not found!';
    end if;
    
    if book is null then
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '`book` parameter is null!';
    end if;
    
    if edition is null then
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '`edition` parameter is null!';
    end if;
    
    if not exists(select * from edition where id=book and number=edition) then
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'The provided book and its edition is not found!';
    end if;
    
    begin
	declare orderId varchar(20) default null;
    declare currentAmount int default 1;
    
    select customerOrder.id into orderId from customerOrder join physicalOrder on physicalOrder.orderId=customerOrder.id where customerOrder.customer=customer and customerOrder.status=false order by cast(substr(customerOrder.id,6) as unsigned) desc limit 1;
    select physicalOrderContain.amount into currentAmount from physicalOrderContain where physicalOrderContain.orderId=orderId and physicalOrderContain.book=book and physicalOrderContain.number=edition;
    
    if amount is null or (amount is not null and amount>=currentAmount) then
		delete from physicalOrderContain where physicalOrderContain.orderId=orderId and physicalOrderContain.book=book and physicalOrderContain.number=edition;
	else
		update physicalOrderContain set physicalOrderContain.amount=physicalOrderContain.amount-amount where physicalOrderContain.orderId=orderId and physicalOrderContain.book=book and physicalOrderContain.number=edition;
    end if;
    
    call updateOrderCost(orderId);
    end;
end//
delimiter ;

drop procedure if exists updateOrderCost;
delimiter //
create procedure updateOrderCost(
    in orderId varchar(20)
)
begin
	if orderId is null then
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '`orderId` parameter is null!';
    end if;
    
    if not exists(select * from customerOrder where id=orderId) then
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Order not found!';
    end if;

	begin
    declare orderStatus boolean default false;
    select status into orderStatus from customerOrder where id=orderId;
    if orderStatus then
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'This order has already been paid and can not be updated!';
    end if;
    
    update customerOrder set totalCost=0,totalDiscount=0 where id=orderId;
    delete from discountApply where discountApply.orderID=orderId;
    
    begin
		declare isFound boolean default false;
        select exists(select * from customerOrder join fileOrder on fileOrder.orderID=customerOrder.id where customerOrder.id=orderId) into isFound;
        if isFound then
			begin
				DECLARE done BOOLEAN DEFAULT FALSE;
				declare bookId varchar(20) default null;
				DECLARE myCursor CURSOR FOR SELECT book FROM fileOrderContain where fileOrderContain.orderID=orderId;
				DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
				OPEN myCursor;
				loop_start: LOOP
					set bookId:=null;
					FETCH myCursor INTO bookId;
					IF done THEN
						LEAVE loop_start;
					END IF;
                    begin
						declare bookOriginalPrice double default null;
                        declare bookPriceAfterDiscount double default null;
                        
                        select price into bookOriginalPrice from book where id=bookId;
                        select priceAfterDiscount(bookId,now(),orderId) into bookPriceAfterDiscount;
                        
                        update customerOrder set totalCost=totalCost+bookPriceAfterDiscount,totalDiscount=totalDiscount+(bookOriginalPrice-bookPriceAfterDiscount) where id=orderId;
                    end;
				END LOOP loop_start;
				CLOSE myCursor;
            end;
        else
			select exists(select * from customerOrder join physicalOrder on physicalOrder.orderID=customerOrder.id where customerOrder.id=orderId) into isFound;
            if isFound then
				begin
					DECLARE done BOOLEAN DEFAULT FALSE;
					declare bookId varchar(20) default null;
                    declare orderAmount int default null;
					DECLARE myCursor CURSOR FOR SELECT book,amount FROM physicalOrderContain where physicalOrderContain.orderID=orderId;
					DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
					OPEN myCursor;
					loop_start: LOOP
						set bookId:=null;
                        set orderAmount:=null;
						FETCH myCursor INTO bookId,orderAmount;
						IF done THEN
							LEAVE loop_start;
						END IF;
						begin
							declare bookOriginalPrice double default null;
							declare bookPriceAfterDiscount double default null;
                        
							select price into bookOriginalPrice from book where id=bookId;
							select priceAfterDiscount(bookId,now(),orderId) into bookPriceAfterDiscount;
                            
                            update customerOrder set totalCost=totalCost+bookPriceAfterDiscount*orderAmount,totalDiscount=totalDiscount+(bookOriginalPrice-bookPriceAfterDiscount)*orderAmount where id=orderId;
                        end;
					END LOOP loop_start;
					CLOSE myCursor;
                end;
            else
				SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Order type not identified!';
            end if;
        end if;
        begin
			declare counter int default 0;
			declare customerId varchar(20) default null;
			declare refDiscount varchar(20) default null;
			declare refDiscountValue double default null;
            declare originalPrice double default null;
                            
			select customerOrder.customer into customerId from customerOrder where customerOrder.id=orderId;
			select count(*) into counter from customer where referrer=customerId;
			select discount,discountPercent into refDiscount,refDiscountValue from referrerDiscount where counter>=numberOfPeople order by discountPercent desc limit 1;
                            
			if refDiscountValue is not null and refDiscount is not null then
				if not exists(select * from discountApply where discountApply.orderID=orderId and discountApply.discount=refDiscount) then
					insert into discountApply values(orderId,refDiscount);
				end if;
				select totalCost+totalDiscount into originalPrice from customerOrder where id=orderId;
				update customerOrder set totalCost=totalCost*(100-refDiscountValue)/100 where id=orderId;
				update customerOrder set totalDiscount=originalPrice-totalCost where id=orderId;
			end if;
		end;
        begin
			declare point double default null;
            declare customerId varchar(20) default null;
            declare pointDiscount varchar(20) default null;
			declare pointDiscountValue double default null;
            declare originalPrice double default null;
            
            select customerOrder.customer into customerId from customerOrder where customerOrder.id=orderId;
            select customer.point into point from customer where id=customerId;
            select discount,discountPercent into pointDiscount,pointDiscountValue from customerDiscount where point>=customerDiscount.point order by discountPercent desc limit 1;
            
            if pointDiscountValue is not null and pointDiscount is not null then
				if not exists(select * from discountApply where discountApply.orderID=orderId and discountApply.discount=pointDiscount) then
					insert into discountApply values(orderId,pointDiscount);
				end if;
				select totalCost+totalDiscount into originalPrice from customerOrder where id=orderId;
				update customerOrder set totalCost=totalCost*(100-pointDiscount)/100 where id=orderId;
				update customerOrder set totalDiscount=originalPrice-totalCost where id=orderId;
			end if;
        end;
    end;
    end;
end//
delimiter ;

drop procedure if exists refreshOrderCostProcedure;
delimiter //
create procedure refreshOrderCostProcedure()
begin
	DECLARE done BOOLEAN DEFAULT FALSE;
    declare orderId varchar(20) default null;
	DECLARE myCursor CURSOR FOR SELECT id FROM customerOrder where status=false;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
	OPEN myCursor;
		loop_start: LOOP
			set orderId:=null;
			FETCH myCursor INTO orderId;
			IF done THEN
				LEAVE loop_start;
			END IF;
            call updateOrderCost(orderId);
			END LOOP loop_start;
	CLOSE myCursor;
end//
delimiter ;

drop procedure if exists customerPayUp;
delimiter //
create procedure customerPayUp(
    in orderId varchar(20)
)
begin
	if orderId is null then
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '`orderId` parameter is null!';
    end if;
    
    if not exists(select * from customerOrder where id=orderId) then
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Order not found!';
    end if;
    
    begin
	declare isPaid boolean default false;
    select status into isPaid from customerOrder where id=orderId;
	if isPaid then
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'This order has already been paid!';
	end if;
    
	begin
		declare customerId varchar(20) default null;
        declare total double default 0;
        declare discount double default 0;
        declare addedPoints double default 0;
        
		select customerOrder.customer into customerId from customerOrder where id=orderId;
        select totalCost into total from customerOrder where id=orderId;
        select discountPercentOnTotalCost into discount from discountConfig limit 1;
        
        set addedPoints:=total*discount/100.0;
        
        update customer set point=point+addedPoints where id=customerId;
        update customerOrder set status=true,orderTime=now() where id=orderId;
    end;
    end;
end//
delimiter ;

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

drop procedure if exists GetTop5BestSellers; -- existence is questionable?
DELIMITER //
CREATE PROCEDURE GetTop5BestSellers(
    IN startDateParam DATE,
    IN endDateParam DATE,
    in atLeast int
)
BEGIN
	if startDateParam is null then
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '`startDateParam` parameter is null!';
    end if;
    
    if endDateParam is null then
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '`endDateParam` parameter is null!';
    end if;
    
    if startDateParam>endDateParam then
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '`startDateParam` value is larger than `endDateParam` value?';
    end if;
    
    if atLeast is null then
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '`atLeast` parameter is null!';
    end if;
    
    if atLeast<0 then
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '`atLeast` parameter value negative!';
    end if;
    
	SELECT
        b.id AS BookID,
        b.name AS BookName,
        SUM(sales.TotalSales) AS TotalSales
    FROM (
		SELECT poc.book, sum(poc.amount) AS TotalSales
		FROM customerOrder co
		JOIN physicalOrderContain poc ON co.id = poc.orderID
		WHERE co.orderTime BETWEEN startDateParam AND endDateParam AND co.status = 1
		GROUP BY poc.book
        
		UNION
        
        SELECT foc.book, COUNT(foc.orderID) AS TotalSales
        FROM customerOrder co
        JOIN fileOrderContain foc ON co.id = foc.orderID
        WHERE co.orderTime BETWEEN startDateParam AND endDateParam AND co.status = 1
        GROUP BY foc.book
    ) AS sales
    JOIN book b ON sales.book = b.id
    GROUP BY BookID, BookName
    having TotalSales>=atLeast
    ORDER BY TotalSales DESC,BookName
    LIMIT 5;
END //
DELIMITER ;
-- CALL GetTop5BestSellers('2023-01-01', '2023-12-01',2);