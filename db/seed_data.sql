use bookstore;

-- Inserting data into the 'category' table
INSERT INTO category (name) VALUES
('Fiction'),
('Non-Fiction'),
('Children'),
('Science Fiction'),
('Memoir'),
('Fantasy'),
('Mystery'),
('Adventure'),
('Romance'),
('Horror'),
('Political'),
('Historical Fiction'),
('Biography');

-- Inserting data into the 'author' table
INSERT INTO author (id, name, gender, pob, dob) VALUES
('AUTHOR1', 'J.K. Rowling', 'F', 'Yate, United Kingdom', '1965-07-31'),
('AUTHOR2', 'George R.R. Martin', 'M', 'Bayonne, New Jersey', '1948-09-20'),
('AUTHOR3', 'Stephen King', 'M', 'Portland, Maine', '1947-09-21'),
('AUTHOR4', 'Elizabeth Gilbert', 'F', 'Worcester, Massachusetts', '1969-02-10'),
('AUTHOR5', 'Neil Gaiman', 'M', 'Portsmouth, England', '1960-11-10'),
('AUTHOR6', 'Dan Brown', 'M', 'Exeter, New Hampshire', '1964-06-22'),
('AUTHOR7', 'Agatha Christie', 'F', 'Torquay, Devon', '1890-09-15'),
('AUTHOR8', 'Paulo Coelho', 'M', 'Sete Lagoas, Brazil', '1947-08-24'),
('AUTHOR9', 'John Green', 'M', 'Indianapolis, Indiana', '1977-08-07'),
('AUTHOR10', 'Khaled Hosseini', 'M', 'Amirkabir, Afghanistan', '1965-09-14');

-- Inserting data into the 'book' table
INSERT INTO book (id, name, isbn, ageRestriction, price) VALUES
('BOOK1', 'Harry Potter and the Philosopher\'s Stone', '9780439358071', 9, 27.99),
('BOOK2', 'A Game of Thrones', '9780553103547', 16, 28.99),
('BOOK3', 'The Shining', '9780345330133', 17, 27.49),
('BOOK4', 'Eat, Pray, Love', '9780385349243', 17, 17.99),
('BOOK5', 'American Gods', '9780002880339', 17, 18.99),
('BOOK6', 'The Da Vinci Code', '9780307279779', 17, 27.99),
('BOOK7', 'Murder on the Orient Express', '9780006419289', 16, 26.99),
('BOOK8', 'The Alchemist', '9780062315002', 12, 16.49),
('BOOK9', 'Paper Towns', '9780062269609', 17, 26.99),
('BOOK10', 'The Kite Runner', '9780375414581', 16, 17.99);

-- Inserting data into the 'bookCategory' table
INSERT INTO bookCategory (book, category) VALUES
('BOOK1', 'Fantasy'),
('BOOK2', 'Fantasy'),
('BOOK2', 'Political'),
('BOOK3', 'Horror'),
('BOOK4', 'Memoir'),
('BOOK5', 'Fantasy'),
('BOOK6', 'Adventure'),
('BOOK6', 'Mystery'),
('BOOK7', 'Mystery'),
('BOOK8', 'Fiction'),
('BOOK8', 'Adventure'),
('BOOK9', 'Mystery'),
('BOOK10', 'Fiction');

-- Inserting data into the 'publisher' table
INSERT INTO publisher (name) VALUES
('HarperCollins'),
('Bantam Spectra'),
('Doubleday'),
('Bloomsbury'),
('William Morrow'),
('Collins Crime Club'),
('Viking Penguin'),
('Dutton Books'),
('Riverhead Books');

-- Inserting data into the 'edition' table
insert into edition(id,number,publisher,publishDate) values
('BOOK1',1,'Bloomsbury','1997-06-26'),
('BOOK2',1,'Bantam Spectra','1996-08-06'),
('BOOK3',1,'Doubleday','1977-01-28'),
('BOOK4',1,'Viking Penguin','2006-02-16'),
('BOOK5',1,'William Morrow','2001-06-19'),
('BOOK6',1,'Doubleday','2003-03-18'),
('BOOK7',1,'Collins Crime Club','1934-01-01'),
('BOOK8',1,'HarperCollins','1993-01-01'),
('BOOK9',1,'Dutton Books','2008-10-16'),
('BOOK10',1,'Riverhead Books','2003-05-29');

-- Inserting data into the 'authorWrite' table
INSERT INTO authorWrite (book, number, author) VALUES
('BOOK1',1, 'AUTHOR1'),
('BOOK2',1, 'AUTHOR2'),
('BOOK3',1, 'AUTHOR3'),
('BOOK4',1, 'AUTHOR4'),
('BOOK5',1, 'AUTHOR5'),
('BOOK6',1, 'AUTHOR6'),
('BOOK7',1, 'AUTHOR7'),
('BOOK8',1, 'AUTHOR8'),
('BOOK9',1, 'AUTHOR9'),
('BOOK10',1, 'AUTHOR10');

-- Inserting data into the 'physicalCopy' table
insert into physicalCopy (book,number,numberInStock) values
('BOOK1',1,10),
('BOOK2',1,0),
('BOOK3',1,5),
('BOOK4',1,100),
('BOOK5',1,20),
('BOOK6',1,13),
('BOOK7',1,1),
('BOOK8',1,15),
('BOOK9',1,21),
('BOOK10',1,10);

-- Inserting data into the 'fileCopy' table
insert into fileCopy (book,number,filePath) values
('BOOK1',1,'data/books/book1'),
('BOOK2',1,'data/books/book2'),
('BOOK3',1,'data/books/book3'),
('BOOK4',1,'data/books/book4'),
('BOOK5',1,null),
('BOOK6',1,'data/books/book6'),
('BOOK7',1,'data/books/book7'),
('BOOK8',1,'data/books/book8'),
('BOOK9',1,'data/books/book9'),
('BOOK10',1,null);

-- Inserting data into the 'customer' table
INSERT INTO customer (id, name, dob, address, phone, cardNumber, point, email, username, password, referrer) VALUES
('CUSTOMER1', 'John Doe', '1990-05-15', '123 Main St, Cityville', '1234567890', '123456789012345', 2.3639, 'john.doe@email.com', 'john_doe', 'password123', NULL),
('CUSTOMER2', 'Jane Smith', '1985-08-22', '456 Oak St, Townsville', '9876543210', '987654321098765', 6.53695, 'jane.smith@email.com', 'jane_smith', 'securePW567', 'CUSTOMER1'),
('CUSTOMER3', 'Bob Johnson', '1978-12-10', '789 Pine St, Villagetown', '5551112222', '111122223333444', 5.30285, 'bob.johnson@email.com', 'bob_j', 'pass123word', 'CUSTOMER2');

-- Inserting data into the 'wishlist' table
insert into wishlist(book,number,customer) values
('BOOK10',1,'CUSTOMER1'),
('BOOK5',1,'CUSTOMER1'),
('BOOK1',1,'CUSTOMER2'),
('BOOK5',1,'CUSTOMER2'),
('BOOK2',1,'CUSTOMER3');

-- Inserting data into the 'customerOrder' table
insert into customerOrder(id,totalCost,orderTime,totalDiscount,customer,status) values
('ORDER1',63.577,null,19.393,'CUSTOMER1',false),
('ORDER2',47.278,'2023-01-01 15:01:30',17.692,'CUSTOMER1',true),
('ORDER3',130.739,'2023-01-01 18:01:30',43.181,'CUSTOMER2',true),
('ORDER4',14.392,null,3.598,'CUSTOMER3',false),
('ORDER5',47.278,'2023-01-01 15:01:30',17.692,'CUSTOMER3',true),
('ORDER6',58.779,'2023-01-01 18:01:30',25.191,'CUSTOMER3',true),
('ORDER7',30.9365,null,14.5435,'CUSTOMER1',false),
('ORDER8',48.38,null,23.09,'CUSTOMER3',false),
('ORDER9',49.08,null,23.39,'CUSTOMER2',false),
('ORDER10',31.2865,null,14.6935,'CUSTOMER2',false);

-- Inserting data into the 'physicalOrder' table
insert into physicalOrder(orderID,destinationAddress) values
('ORDER1','123 Main St, Cityville'),
('ORDER3','456 Oak St, Townsville'),
('ORDER6','789 Pine St, Villagetown'),
('ORDER8','789 Pine St, Villagetown'),
('ORDER9','456 Oak St, Townsville');

-- Inserting data into the 'fileOrder' table
insert into fileOrder(orderID) values
('ORDER2'),
('ORDER5'),
('ORDER4'),
('ORDER7'),
('ORDER10');

-- Inserting data into the 'fileOrderContain' table
insert into fileOrderContain(book,number,orderID) values -- this will need a trigger check for age appropriate
('BOOK1',1,'ORDER2'),
('BOOK5',1,'ORDER2'),
('BOOK10',1,'ORDER2'),
('BOOK1',1,'ORDER5'),
('BOOK5',1,'ORDER5'),
('BOOK10',1,'ORDER5'),
('BOOK4',1,'ORDER4'),
('BOOK3',1,'ORDER7'),
('BOOK4',1,'ORDER7'),
('BOOK6',1,'ORDER10'),
('BOOK4',1,'ORDER10');

-- Inserting data into the 'physicalOrderContain' table
insert into physicalOrderContain(book,number,orderID,amount) values -- this will need a trigger check for age appropriate
('BOOK3',1,'ORDER1',2),
('BOOK6',1,'ORDER1',1),
('BOOK10',1,'ORDER3',5),
('BOOK1',1,'ORDER3',3),
('BOOK1',1,'ORDER6',3),
('BOOK3',1,'ORDER8',2),
('BOOK8',1,'ORDER8',1),
('BOOK1',1,'ORDER9',2),
('BOOK8',1,'ORDER9',1);

-- Inserting data into the 'discount' table
insert into discount(id) values
('C_DISCOUNT1'),
('C_DISCOUNT2'),
('C_DISCOUNT3'),
('R_DISCOUNT1'),
('R_DISCOUNT2'),
('R_DISCOUNT3'),
('E_DISCOUNT1'),
('E_DISCOUNT2'),
('E_DISCOUNT3'),
('E_DISCOUNT4'),
('E_DISCOUNT5'),
('E_DISCOUNT6');

-- Inserting data into the 'discountApply' table
insert into discountApply(orderId,discount) values
('ORDER2','E_DISCOUNT1'),
('ORDER2','E_DISCOUNT2'),
('ORDER3','E_DISCOUNT1'),
('ORDER3','E_DISCOUNT2'),
('ORDER5','E_DISCOUNT1'),
('ORDER5','E_DISCOUNT2'),
('ORDER6','E_DISCOUNT2'),
('ORDER7','E_DISCOUNT3'),
('ORDER7','E_DISCOUNT5'),
('ORDER8','E_DISCOUNT3'),
('ORDER8','E_DISCOUNT6'),
('ORDER9','E_DISCOUNT6'),
('ORDER9','E_DISCOUNT3'),
('ORDER10','E_DISCOUNT5'),
('ORDER10','E_DISCOUNT3');

-- Inserting data into the 'customerDiscount' table
insert into customerDiscount(discount,point,discountPercent) values
('C_DISCOUNT1',300,3),
('C_DISCOUNT2',500,5),
('C_DISCOUNT3',750,7);

-- Inserting data into the 'referrerDiscount' table
insert into referrerDiscount(discount,numberOfPeople,discountPercent) values
('R_DISCOUNT1',5,3),
('R_DISCOUNT2',7,5),
('R_DISCOUNT3',10,7);

-- Inserting data into the 'eventDiscount' table
insert into eventDiscount(discount,discountPercent,applyForAll,startDate,endDate) values
('E_DISCOUNT1',20,true,'2023-01-01','2023-12-01'),
('E_DISCOUNT2',30,false,'2023-01-01','2023-12-01'),
('E_DISCOUNT3',30,true,now(),date_add(now(),interval 7 day)),
('E_DISCOUNT4',25,false,now(),date_add(now(),interval 7 day)),
('E_DISCOUNT5',35,false,now(),date_add(now(),interval 7 day)),
('E_DISCOUNT6',40,false,now(),date_add(now(),interval 7 day));

-- Inserting data into the 'eventApply' table
insert into eventApply(discount,book) values
('E_DISCOUNT2','BOOK1'),
('E_DISCOUNT2','BOOK2'),
('E_DISCOUNT2','BOOK5'),
('E_DISCOUNT2','BOOK6'),
('E_DISCOUNT4','BOOK3'),
('E_DISCOUNT5','BOOK4'),
('E_DISCOUNT6','BOOK8');

-- Inserting data into the 'rating' table
insert into rating(book,number,customer,star) values
('BOOK1',1,'CUSTOMER1',4),
('BOOK5',1,'CUSTOMER1',5),
('BOOK10',1,'CUSTOMER2',3);

-- Inserting data into the 'comment' table
insert into comment(book,number,customer) values
('BOOK1',1,'CUSTOMER1'),
('BOOK5',1,'CUSTOMER1'),
('BOOK10',1,'CUSTOMER2');

-- Inserting data into the 'commentContent' table
insert into commentContent(book,number,customer,commentText,commentTime) values
('BOOK1',1,'CUSTOMER1','Good book','2023-11-18 15:00:00'),
('BOOK1',1,'CUSTOMER1','Not so good anymore :(','2023-11-18 15:30:00'),
('BOOK5',1,'CUSTOMER1','Meh','2023-11-18 16:00:00'),
('BOOK10',1,'CUSTOMER2','Kinda okay','2023-11-18 16:00:00'),
('BOOK10',1,'CUSTOMER2','Bad','2023-11-18 18:30:00');