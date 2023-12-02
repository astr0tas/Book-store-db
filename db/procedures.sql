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
    select physicalOrderContain.amount into currentAmount where physicalOrderContain.orderId=orderId and physicalOrderContain.book=book and physicalOrderContain.number=edition;
    
    if amount is null or (amount is not null and amount>currentAmount) then
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
    if status then
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
                        
                        update customerOrder set totalCost=totalCost+priceAfterDiscount,totalDiscount=totalDiscount+(bookOriginalPrice-priceAfterDiscount) where id=orderId;
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
                            
                            update customerOrder set totalCost=totalCost+priceAfterDiscount*orderAmount,totalDiscount=totalDiscount+(bookOriginalPrice-priceAfterDiscount)*orderAmount where id=orderId;
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
    
    update customerOrder set status=true,orderTime=now() where id=orderId;
    
	begin
		declare customerId varchar(20) default null;
        declare total double default 0;
        declare discount double default 0;
        declare addedPoints double default 0;
        
		select customerOrder.customer into customerId from customerOrder where id=orderId;
        select totalCost into total from customerOrder where id=orderId;
        select discountPercentOnTotalCost into discount from discountConfig limit 1;
        
        set addedPoints:=totalCost*discountPercentOnTotalCost/100.0;
        
        update customer set point=point+addedPoints where id=customerId;
    end;
    end;
end//
delimiter ;

drop procedure if exists insertNewCustomer;
delimiter //
create procedure insertNewCustomer(
    in name varchar(100),
    in dob date,
    in address text,
    in phone varchar(10),
    in cardNumber varchar(16),
    in email varchar(100),
    in username varchar(20),
    in password varchar(20),
    in referrerEmail varchar(100)
)
begin
	declare referrerID varchar(20) default null;
    
	if name is null then
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'This customer doesn\'t have a name?';
    end if;
    
    if dob is null then
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No date of birth provided!';
    else
		if date_add(dob,interval 16 year)>curdate() then
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Customer must be at least 16 years old!';
		end if;
    end if;
    
    if phone is null then
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No phone number provided!';
    else
		if not phone REGEXP '^[0-9]{10}$' then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Customer\'s phone contain non-numeric character!';
		else
            begin
				declare isFound boolean default false;
                select exists(select * from customer where customer.phone=phone) into isFound;
                if isFound then
					SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'The provided phone has already been used!';
                end if;
            end;
		end if;
    end if;
    
    if email is null then
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No email provided!';
    else
		if not email REGEXP '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+\\.[A-Z|a-z]{2,4}$' then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Customer\'s email format is not valid!';
		else
			begin
				declare isFound boolean default false;
                select exists(select * from customer where customer.email=email) into isFound;
                if isFound then
					SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'The provided email has already been used!';
                end if;
            end;
		end if;
    end if;
    
    if username is null then
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No username provided!';
    else
		begin
			declare isFound boolean default false;
			select exists(select * from customer where customer.username=username) into isFound;
			if isFound then
				SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'The provided username has already been used!';
			end if;
		end;
    end if;
    
    if password is null then
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No password provided!';
    end if;
    
    if cardNumber is not null and not cardNumber REGEXP '^[0-9]{8,16}$' then
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Customer card number contain non-numeric character!';
    end if;
    
    select referrer into referrerID from customer where email=referrerEmail;
    
    if referrerID is null then
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Referrer\'s email not found!';
    end if;
    
    IF LENGTH(password) <= 8 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Password must be more than 8 characters long!';
    END IF;
    
    begin
		declare counter int default 0;
        select cast(substr(id,9) as unsigned) into counter from customer ORDER BY cast(substr(id,9) as unsigned) DESC LIMIT 1;
        set counter:=counter+1;
        insert into customer values(concat('CUSTOMER',counter),name,dob,address,phone,cardNumber,0,email,username,password,referrerID);
    end;
end//
delimiter ;

drop procedure if exists deleteACustomer;
delimiter //
create procedure deleteACustomer(
    in customerID varchar(20)
)
begin
	if customerID is null then
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '`customerID` parameter is null!';
    end if;
    
    if not exists(select * from customer where id=customerID) then
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Customer not found!';
    end if;
    
	if exists(select * from customerOrder where customerOrder.status=true and customerOrder.customer=customerID) then
		update customer set status=false where id=customerID;
	else
		delete from customer where id=customerID;
    end if;
end//
delimiter ;

drop procedure if exists updateACustomer;
delimiter //
create procedure updateACustomer(
    in customerID varchar(20),
    in name varchar(100),
    in dob date,
    in address text,
    in phone varchar(10),
    in cardNumber varchar(16),
    in email varchar(100),
    in password varchar(20)
)
begin
	if customerID is null then
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '`customerID` parameter is null!';
    end if;
    
    if not exists(select * from customer where id=customerID) then
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Customer not found!';
    end if;
    
    if name is not null then
		update customer set customer.name=name where customer.id=customerID;
    end if;
    
    if dob is not null then
		if date_add(dob,interval 16 year)>curdate() then
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Customer must be at least 16 years old!';
		else
			update customer set customer.dob=dob where customer.id=customerID;
		end if;
    end if;
    
    if address is not null then
		update customer set customer.address=address where customer.id=customerID;
    end if;
    
    if phone is not null then
		if not phone REGEXP '^[0-9]{10}$' then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Customer\'s phone contain non-numeric character!';
		else
			if exists(select * from customer where customer.id=customerID and customer.phone=phone) then
				SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Customer\'s phone update to the same value?';
            end if;
            
			begin
				declare isFound boolean default false;
                select exists(select * from customer where customer.phone=phone) into isFound;
                if isFound then
					SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'The provided phone has already been used!';
				else
					update customer set customer.phone=phone where customer.id=customerID;
                end if;
            end;
		end if;
    end if;
    
    if cardNumber is not null then
		if not cardNumber REGEXP '^[0-9]{8,16}$' then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Customer\'s card number contain non-numeric character!';
		else
			update customer set customer.cardNumber=cardNumber where customer.id=customerID;
		end if;
    end if;
    
    if email is not null then
		if not email REGEXP '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+\\.[A-Z|a-z]{2,4}$' then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Customer\'s email format is not valid!';
		else
			if exists(select * from customer where customer.id=customerID and customer.email=email) then
				SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Customer\'s email update to the same value?';
            end if;
            
			begin
				declare isFound boolean default false;
                select exists(select * from customer where customer.email=email) into isFound;
                if isFound then
					SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'The provided email has already been used!';
				else
					update customer set customer.email=email where customer.id=customerID;
                end if;
            end;
		end if;
    end if;
    
    if password is not null then
		IF LENGTH(password) <= 8 THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Password must be more than 8 characters long!';
		else
			update customer set customer.password=password where customer.id=customerID;
		END IF;
    end if;
end//
delimiter ;

drop procedure if exists GetTop5BestSellers;
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