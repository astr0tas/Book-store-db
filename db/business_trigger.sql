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

drop trigger if exists ratingInsertTrigger;
delimiter //
create trigger ratingInsertTrigger
before insert on rating
for each row
begin
    declare isFound boolean default false;
    select exists(
    select * from customerOrder
    join physicalOrder on physicalOrder.orderId=customerOrder.id
    join physicalOrderContain on physicalOrderContain.orderID=customerOrder.id
    where physicalOrderContain.number=new.number and physicalOrderContain.book=new.book and customerOrder.customer=new.customer
    ) into isFound;
    
    if not isFound then
		select exists(
		select * from customerOrder
		join fileOrder on fileOrder.orderId=customerOrder.id
		join fileOrderContain on fileOrderContain.orderID=customerOrder.id
		where fileOrderContain.number=new.number and fileOrderContain.book=new.book and customerOrder.customer=new.customer
		) into isFound;
        if not isFound then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Customer hasn\'t buy this book yet, rating is not allowed!';
        end if;
    end if;
end//
delimiter ;

drop trigger if exists ratingUpdateTrigger;
delimiter //
create trigger ratingUpdateTrigger
before update on rating
for each row
begin
    declare isFound boolean default false;
    select exists(
    select * from customerOrder
    join physicalOrder on physicalOrder.orderId=customerOrder.id
    join physicalOrderContain on physicalOrderContain.orderID=customerOrder.id
    where physicalOrderContain.number=new.number and physicalOrderContain.book=new.book and customerOrder.customer=new.customer
    ) into isFound;
    
    if not isFound then
		select exists(
		select * from customerOrder
		join fileOrder on fileOrder.orderId=customerOrder.id
		join fileOrderContain on fileOrderContain.orderID=customerOrder.id
		where fileOrderContain.number=new.number and fileOrderContain.book=new.book and customerOrder.customer=new.customer
		) into isFound;
        if not isFound then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Customer hasn\'t buy this book yet, rating is not allowed!';
        end if;
    end if;
end//
delimiter ;

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
    where physicalOrderContain.number=new.number and physicalOrderContain.book=new.book and customerOrder.customer=new.customer
    ) into isFound;
    
    if not isFound then
		select exists(
		select * from customerOrder
		join fileOrder on fileOrder.orderId=customerOrder.id
		join fileOrderContain on fileOrderContain.orderID=customerOrder.id
		where fileOrderContain.number=new.number and fileOrderContain.book=new.book and customerOrder.customer=new.customer
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
    declare isFound boolean default false;
    select exists(
    select * from customerOrder
    join physicalOrder on physicalOrder.orderId=customerOrder.id
    join physicalOrderContain on physicalOrderContain.orderID=customerOrder.id
    where physicalOrderContain.number=new.number and physicalOrderContain.book=new.book and customerOrder.customer=new.customer
    ) into isFound;
    
    if not isFound then
		select exists(
		select * from customerOrder
		join fileOrder on fileOrder.orderId=customerOrder.id
		join fileOrderContain on fileOrderContain.orderID=customerOrder.id
		where fileOrderContain.number=new.number and fileOrderContain.book=new.book and customerOrder.customer=new.customer
		) into isFound;
        if not isFound then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Customer hasn\'t buy this book yet, comments are not allowed!';
        end if;
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