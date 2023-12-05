use bookstore;

select * from category;
select * from publisher;
select * from author;
select * from book;
select * from bookCategory;
select * from edition;
select * from authorWrite;
select * from physicalCopy;
select * from fileCopy;
select * from customer;
select * from rating;
select * from wishlist;
select * from comment;
select * from commentContent;
select * from customerOrder;
select * from physicalOrder;
select * from fileOrder;
select * from fileOrderContain;
select * from physicalOrderContain;
select * from discount;
select * from discountApply;
select * from customerDiscount;
select * from referrerDiscount;
select * from eventDiscount;
select * from eventApply;
select * from discountConfig;

-- Insert procedure for customer table
call insertNewCustomer('Morty Smith','2002-01-01',null,'1236567890',null,'mortySmith@gmail.com','morty','password123','john.doe@email.com');
select * from customer;
call insertNewCustomer('Morty Smith','2010-01-01',null,'2236567890',null,'mortySmith1@gmail.com','morty1','password123','john.doe@email.com');
call insertNewCustomer('Morty Smith','2002-01-01',null,'1236567890',null,'mortySmith1@gmail.com','morty1','password123','john.doe@email.com');
call insertNewCustomer('Morty Smith','2002-01-01',null,'2236567890',null,'mortySmith@gmail.com','morty1','password123','john.doe@email.com');
call insertNewCustomer('Morty Smith','2002-01-01',null,'2236567890',null,'mortySmith1@gmail.com','morty','password123','john.doe@email.com');

-- Update procedure for customer table
call updateACustomer('CUSTOMER3',null,null,null,null,null,null,null);
call updateACustomer('CUSTOMER3','TEST',null,null,null,null,null,null);
select * from customer;
call updateACustomer('CUSTOMER3',null,'2001-01-01',null,null,null,null,null);
select * from customer;
call updateACustomer('CUSTOMER3',null,null,'VIET NAM',null,null,null,null);
select * from customer;
call updateACustomer('CUSTOMER3',null,null,null,'9531876502',null,null,null);
select * from customer;
call updateACustomer('CUSTOMER3',null,null,null,null,'913548103515',null,null);
select * from customer;
call updateACustomer('CUSTOMER3',null,null,null,null,null,'bob@gmail.com',null);
select * from customer;
call updateACustomer('CUSTOMER3',null,null,null,null,null,null,'bob1234567890');
select * from customer;

-- Delete procedure for customer table
call deleteACustomer('CUSTOMER3');
select * from customer;
call deleteACustomer('CUSTOMER4');
select * from customer;

-- Trigger 1
insert into rating(book,number,customer,star) values('BOOK8',1,'CUSTOMER1',4);
update rating set book='BOOK10' where book='BOOK1' and customer='CUSTOMER1';
select * from rating;
select * from edition;
insert into rating(book,number,customer,star) values('BOOK1',1,'CUSTOMER3',3.5);
select * from rating;
select * from edition;
update rating set star='4.5' where book='BOOK1' and customer='CUSTOMER3';
select * from rating;
select * from edition;
delete from rating where book='BOOK1' and number = 1 and customer='CUSTOMER1';
select * from rating;
select * from edition;

-- Trigger 2
insert into eventApply(discount,book) values('E_DISCOUNT3','BOOK1');
SET SQL_SAFE_UPDATES = 0;
update eventApply set discount='E_DISCOUNT1' where discount='E_DISCOUNT4';
SET SQL_SAFE_UPDATES = 1;
update eventDiscount set applyForAll=true where discount='E_DISCOUNT4';
select * from eventApply;

-- Procedure 1
CALL GetTop5BestSellers('2023-01-01', '2023-12-31',1);
CALL GetTop5BestSellers('2023-01-01', '2023-12-31',5);

-- Procedure 2
select*from eventDiscount;
Select * from eventApply;
select * from customerOrder where id='ORDER1' or id='ORDER4';
select * from discountApply where orderID='ORDER1' or orderID='ORDER4';
call updateOrderCost('ORDER1');
call updateOrderCost('ORDER4');
select * from customerOrder where id='ORDER1' or id='ORDER4';
select * from discountApply where orderID='ORDER1' or orderID='ORDER4';

-- Function 1
select * from fileOrderContain where orderID='ORDER4';
SELECT * FROM discountApply where orderID='ORDER4';
select * from book where id='BOOK4';
select * from eventDiscount;
select * from eventApply;
select priceAfterDiscount('BOOK4',NOW(),'ORDER4');
SELECT * FROM discountApply where orderID='ORDER4';

select * from physicalOrderContain where orderID='ORDER1';
SELECT * FROM discountApply where orderID='ORDER1';
select * from book where id='BOOK3';
select * from eventDiscount;
select * from eventApply;
select priceAfterDiscount('BOOK3',NOW(),'ORDER1');
SELECT * FROM discountApply where orderID='ORDER1';

-- Function 2 (new)
select * from edition;
SELECT GetTopRatedBooks() AS TopRatedBooks;

-- Function 2 (old)
select * from discountApply join customerOrder on customerOrder.id=discountApply.orderID where customerOrder.status=true;
select GetnthEventDiscount('2023-01-01','2023-12-31',1);
select GetnthEventDiscount('2023-01-01','2023-12-31',2);