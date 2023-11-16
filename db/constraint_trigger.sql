use bookstore;

-- author

drop trigger if exists authorInsertTrigger;
delimiter //
create trigger authorInsertTrigger
before insert on author
for each row
begin
    if new.dob>curdate() then
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Author date of birth must not be in the future!';
    end if;
end//
delimiter ;

drop trigger if exists authorUpdateTrigger;
delimiter //
create trigger authorUpdateTrigger
before update on author
for each row
begin
    if new.dob>curdate() then
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Author date of birth must not be in the future!';
    end if;
end//
delimiter ;

-- edition

drop trigger if exists editionInsertTrigger;
delimiter //
create trigger editionInsertTrigger
before insert on edition
for each row
begin
    if new.publishDate>curdate() then
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "The book's edition release date must not be in the future!";
    end if;
end//
delimiter ;

drop trigger if exists editionUpdateTrigger;
delimiter //
create trigger editionUpdateTrigger
before update on edition
for each row
begin
    if new.publishDate>curdate() then
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'The book\'s edition release date must not be in the future!';
    end if;
end//
delimiter ;

-- customer

drop trigger if exists customerInsertTrigger;
delimiter //
create trigger customerInsertTrigger
before insert on customer
for each row
begin
    if date_add(new.dob,interval 12 year)>curdate() then
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Customer must be at least 12 years old!';
    end if;
end//
delimiter ;

drop trigger if exists customerUpdateTrigger;
delimiter //
create trigger customerUpdateTrigger
before update on customer
for each row
begin
    if date_add(new.dob,interval 12 year)>curdate() then
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Customer must be at least 12 years old!';
    end if;
end//
delimiter ;

-- commentContent

drop trigger if exists commentContentInsertTrigger;
delimiter //
create trigger commentContentInsertTrigger
before insert on commentContent
for each row
begin
    if new.commentTime>now() then
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Comment upload time must not be in the future!';
    end if;
end//
delimiter ;

drop trigger if exists commentContentUpdateTrigger;
delimiter //
create trigger commentContentUpdateTrigger
before update on commentContent
for each row
begin
    if new.commentTime>now() then
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Comment upload time must not be in the future!';
    end if;
end//
delimiter ;

-- customerOrder

drop trigger if exists customerOrderInsertTrigger;
delimiter //
create trigger customerOrderInsertTrigger
before insert on customerOrder
for each row
begin
    if new.orderTime>now() then
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Customer order time must not be in the future!';
    end if;
end//
delimiter ;

drop trigger if exists customerOrderUpdateTrigger;
delimiter //
create trigger customerOrderUpdateTrigger
before update on customerOrder
for each row
begin
    if new.orderTime>now() then
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Customer order time must not be in the future!';
    end if;
end//
delimiter ;

-- eventDiscount

drop trigger if exists eventDiscountInsertTrigger;
delimiter //
create trigger eventDiscountInsertTrigger
before insert on eventDiscount
for each row
begin
    if new.startDate>now() then
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Event discount start date time must not be in the past!';
    end if;
end//
delimiter ;

drop trigger if exists eventDiscountUpdateTrigger;
delimiter //
create trigger eventDiscountUpdateTrigger
before update on eventDiscount
for each row
begin
    if new.startDate>now() then
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Event discount start date time must not be in the past!';
    end if;
end//
delimiter ;