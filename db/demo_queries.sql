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

call insertNewCustomer('Morty Smith','2002-01-01',null,'1236567890',null,'mortySmith@gmail.com','morty','password123','john.doe@email.com');
select * from customer;
call insertNewCustomer('Morty Smith','20010-01-01',null,'2236567890',null,'mortySmith1@gmail.com','morty1','password123','john.doe@email.com');

-- SET SQL_SAFE_UPDATES = 0;
-- delete from publisher where name='Bloomsbury';
-- SELECT * FROM EDITION;
-- SET SQL_SAFE_UPDATES = 1;

-- insert into rating(book,number,customer,star) values('BOOK10',1,'CUSTOMER1',4);
-- update rating set book='BOOK10' where book='BOOK1' and customer='CUSTOMER1';

-- insert into comment(book,number,customer) values('BOOK10',1,'CUSTOMER1');
-- update comment set book='BOOK10' where book='BOOK1' and customer='CUSTOMER1';

-- insert into eventApply(discount,book) values ('E_DISCOUNT1','BOOK1');
-- update eventApply set discount='E_DISCOUNT1' where discount='E_DISCOUNT2' and book='BOOK1';

-- SET SQL_SAFE_UPDATES = 0;
-- update eventDiscount set applyForAll=true where discount='E_DISCOUNT2';
-- select * from eventApply;
-- SET SQL_SAFE_UPDATES = 1;

-- insert into physicalOrder(orderID,destinationAddress) values('ORDER1',null);
-- select * from physicalOrder;

-- update physicalOrder set destinationAddress=null where orderID='ORDER3';
-- select * from physicalOrder;

-- select * from customerOrder where status=false order by id;
-- select * from physicalOrderContain;
-- select * from customer;
-- call customerPayUp('ORDER8');
-- call customerPayUp('ORDER10');
-- call customerPayUp('ORDER7');
-- call removeFromPhysicalOrder('CUSTOMER2','BOOK1',1,1);
-- select * from discountApply;