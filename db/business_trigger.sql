use bookstore;

-- if a `publisher` is deleted from the database, all editions of books that have it as their publisher will have `publisher` value set to "N/A"
drop trigger if exists deletePublisher;
delimiter //
create trigger deletePublisher
before delete on publisher
for each row
begin
	update edition set publisher="N/A" where publisher=old.name;
end//
delimiter ;

-- SET SQL_SAFE_UPDATES = 0;
-- delete from publisher where name='Bloomsbury';
-- SELECT * FROM EDITION;
-- SET SQL_SAFE_UPDATES = 1;

-- check whether the customer has bought the product or not in order to rate it
drop trigger if exists ratingBeforeInsertTrigger;
delimiter //
create trigger ratingBeforeInsertTrigger
before insert on rating
for each row
begin
    declare isFound boolean default false;
    select exists(
    select * from customerOrder
    join physicalOrder on physicalOrder.orderId=customerOrder.id
    join physicalOrderContain on physicalOrderContain.orderID=customerOrder.id
    where physicalOrderContain.number=new.number and physicalOrderContain.book=new.book and customerOrder.customer=new.customer and customerOrder.status=true
    ) into isFound;
    
    if not isFound then
		select exists(
		select * from customerOrder
		join fileOrder on fileOrder.orderId=customerOrder.id
		join fileOrderContain on fileOrderContain.orderID=customerOrder.id
		where fileOrderContain.number=new.number and fileOrderContain.book=new.book and customerOrder.customer=new.customer and customerOrder.status=true
		) into isFound;
        if not isFound then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Customer hasn\'t buy this book yet, rating is not allowed!';
        end if;
    end if;
end//
delimiter ;

drop trigger if exists ratingBeforeUpdateTrigger;
delimiter //
create trigger ratingBeforeUpdateTrigger
before update on rating
for each row
begin
    if new.book!=old.book or new.number!=old.number or new.customer!=old.customer then
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Changing `book`, `number` or `customer` columns is not allowed, only `star` is allowed to change!';
    end if;
end//
delimiter ;

drop trigger if exists ratingAfterInsertTrigger;
DELIMITER //
CREATE TRIGGER ratingAfterInsertTrigger
AFTER insert ON rating
FOR EACH ROW
BEGIN
    DECLARE total_star_Ratings double default 0;
    DECLARE totalRatings int default 0;
    DECLARE newAverageRating double default 0;

    SELECT COUNT(*), SUM(star) INTO totalRatings, total_star_Ratings FROM rating WHERE book = NEW.book AND number = NEW.number;
    
    IF totalRatings > 0 THEN
		SET newAverageRating := total_star_Ratings / totalRatings;
    END IF;
    UPDATE edition SET avgStar = newAverageRating WHERE book = NEW.book AND number = NEW.number;
END//
DELIMITER ;

drop trigger if exists ratingAfterUpdateTrigger;
DELIMITER //
CREATE TRIGGER ratingAfterUpdateTrigger
AFTER update ON rating
FOR EACH ROW
BEGIN
    DECLARE total_star_Ratings double default 0;
    DECLARE totalRatings int default 0;
    DECLARE newAverageRating double default 0;

    SELECT COUNT(*), SUM(star) INTO totalRatings, total_star_Ratings FROM rating WHERE book = NEW.book AND number = NEW.number;
    
    IF totalRatings > 0 THEN
		SET newAverageRating := total_star_Ratings / totalRatings;
    END IF;
    UPDATE edition SET avgStar = newAverageRating WHERE book = NEW.book AND number = NEW.number;
END//
DELIMITER ;

drop trigger if exists ratingAfterDeleteTrigger;
DELIMITER //
CREATE TRIGGER ratingAfterDeleteTrigger
AFTER delete ON rating
FOR EACH ROW
BEGIN
    DECLARE total_star_Ratings double default 0;
    DECLARE totalRatings int default 0;
    DECLARE newAverageRating double default 0;

    SELECT COUNT(*), SUM(star) INTO totalRatings, total_star_Ratings FROM rating WHERE book = old.book AND number = old.number;
    
    IF totalRatings > 0 THEN
		SET newAverageRating := total_star_Ratings / totalRatings;
    END IF;
    UPDATE edition SET avgStar = newAverageRating WHERE book = old.book AND number = old.number;
END//
DELIMITER ;

-- insert into rating(book,number,customer,star) values('BOOK10',1,'CUSTOMER1',4);
-- update rating set book='BOOK10' where book='BOOK1' and customer='CUSTOMER1';

-- check whether the customer has bought the product or not in order to write comments about it
drop trigger if exists commentInsertTrigger;
delimiter //
create trigger commentInsertTrigger
before insert on comment
for each row
begin
    declare isFound boolean default false;
    select exists(
    select * from customerOrder
    join physicalOrder on physicalOrder.orderId=customerOrder.id
    join physicalOrderContain on physicalOrderContain.orderID=customerOrder.id
    where physicalOrderContain.number=new.number and physicalOrderContain.book=new.book and customerOrder.customer=new.customer and customerOrder.status=true
    ) into isFound;
    
    if not isFound then
		select exists(
		select * from customerOrder
		join fileOrder on fileOrder.orderId=customerOrder.id
		join fileOrderContain on fileOrderContain.orderID=customerOrder.id
		where fileOrderContain.number=new.number and fileOrderContain.book=new.book and customerOrder.customer=new.customer and customerOrder.status=true
		) into isFound;
        if not isFound then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Customer hasn\'t buy this book yet, comments are not allowed!';
        end if;
    end if;
end//
delimiter ;

drop trigger if exists commentUpdateTrigger;
delimiter //
create trigger commentUpdateTrigger
before update on comment
for each row
begin
    if new.book!=old.book or new.number!=old.number or new.customer!=old.customer then
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Changing `book`, `number` or `customer` columns is not allowed!';
    end if;
end//
delimiter ;

-- insert into comment(book,number,customer) values('BOOK10',1,'CUSTOMER1');
-- update comment set book='BOOK10' where book='BOOK1' and customer='CUSTOMER1';

-- check whether the event in `eventApply` is set to discount a limited number of books or not before the insertion
drop trigger if exists eventApplyInsertTrigger;
delimiter //
create trigger eventApplyInsertTrigger
before insert on eventApply
for each row
begin
	declare isForAll boolean default true;
    select applyForAll into isForAll from eventDiscount where discount=new.discount;
    
    if isForAll then
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'This discount event is apply for all books, no need to list specific book(s) into this table!';
    end if;
end//
delimiter ;

-- admin can only update the books that are applied for the discount event, not the other way around
drop trigger if exists eventApplyUpdateTrigger;
delimiter //
create trigger eventApplyUpdateTrigger
before update on eventApply
for each row
begin
    if old.discount!=new.discount then
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Can only update the books that are applied for the discount event, not the other way around!';
    end if;
end//
delimiter ;

-- insert into eventApply(discount,book) values ('E_DISCOUNT1','BOOK1');
-- update eventApply set discount='E_DISCOUNT1' where discount='E_DISCOUNT2' and book='BOOK1';

-- if `applyForAll` of `eventDiscount` is set to true, delete all relevant rows in `eventApply`
drop trigger if exists eventDiscountUpdateTrigger;
delimiter //
create trigger eventDiscountUpdateTrigger
before update on eventDiscount
for each row
begin
    if new.applyForAll then
		delete from eventApply where discount=new.discount;
    end if;
end//
delimiter ;

-- SET SQL_SAFE_UPDATES = 0;
-- update eventDiscount set applyForAll=true where discount='E_DISCOUNT2';
-- select * from eventApply;
-- SET SQL_SAFE_UPDATES = 1;

-- if `destinationAddress` in `physicalOrder`is null, get the customer default address, if that also null, return error
drop trigger if exists physicalOrderInsertTrigger;
delimiter //
create trigger physicalOrderInsertTrigger
before insert on physicalOrder
for each row
begin
	declare address text default null;

    if new.destinationAddress is null then
		select customer.address into address from customer join customerOrder on customerOrder.customer=customer.id where customerOrder.id=new.orderID;
        if address is null then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Customer did not provide destination address nor fill in the `address` field in the profile!';
		else
			set new.destinationAddress:=address;
        end if;
    end if;
end//
delimiter ;

-- insert into physicalOrder(orderID,destinationAddress) values('ORDER1',null);
-- select * from physicalOrder;

drop trigger if exists physicalOrderUpdateTrigger;
delimiter //
create trigger physicalOrderUpdateTrigger
before update on physicalOrder
for each row
begin
	declare address text default null;

    if new.destinationAddress is null then
		select customer.address into address from customer join customerOrder on customerOrder.customer=customer.id join physicalOrder on physicalOrder.orderID=customerOrder.id where physicalOrder.orderID=new.orderID;
        if address is null then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Customer did not provide destination address nor fill in the `address` field in the profile!';
		else
			set new.destinationAddress:=address;
        end if;
    end if;
end//
delimiter ;

-- update physicalOrder set destinationAddress=null where orderID='ORDER3';
-- select * from physicalOrder;