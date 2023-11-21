drop database if exists bookstore;

create database bookstore;

use bookstore;

create table discountConfig(
	discountPercentOnTotalCost int primary key
);

insert into discountConfig values(5);

create table category(
	name varchar(50) primary key
);

create table publisher(
	name varchar(100) primary key
);

create table author(
	id varchar(10) primary key,
    name varchar(100) not null,
    gender varchar(1) not null check(gender='F' or gender='M' or gender='O'),
    pob text,
    dob date
    -- dob date check(dob<=curdate())
);

create table book(
	id varchar(10) primary key,
    name varchar(100) not null,
    isbn varchar(13) not null unique,
    ageRestriction int,
    price double not null check(price>0)
);

create table bookCategory(
	book varchar(10) references book(id) on delete cascade on update cascade,
    category varchar(50) references category(name) on delete cascade on update cascade,
    primary key (book,category)
);

create table edition(
	id varchar(10) references book(id) on delete cascade on update cascade,
    number int,
    primary key(id,number),
    publisher varchar(100) not null references publisher(name) on update cascade,
    publishDate date not null,
    avgStar double default 0.0 check(avgStar>=0 and avgStar<=5)
    -- publishDate date not null check(publishDate<=curdate())
);

ALTER TABLE edition ADD INDEX idx_edition_number_id (number, id);

create table authorWrite(
	author varchar(10) references author(id) on delete cascade on update cascade,
    number int,
    book varchar(10),
    primary key(author,number,book),
    foreign key(number,book) references edition(number,id) on delete cascade on update cascade
);

create table physicalCopy(
	book varchar(10),
    number int,
    primary key(book,number),
    foreign key(book,number) references edition(id,number) on delete cascade on update cascade,
    numberInStock int not null default 0 check (numberInStock>=0)
);

ALTER TABLE physicalCopy ADD INDEX idx_physicalCopy_number_id (number, book);

create table fileCopy(
	book varchar(10),
    number int,
    primary key(book,number),
    foreign key(book,number) references edition(id,number) on delete cascade on update cascade,
    filePath text
);

ALTER TABLE fileCopy ADD INDEX idx_fileCopy_number_id (number, book);

create table customer(
	id varchar(10) primary key,
    name varchar(100) not null,
    dob date not null,
    -- dob date not null check(dob<=curdate()),
    address text,
    phone varchar(10) unique not null,
    cardNumber varchar(15),
    point int default 0 check(point>=0),
    email varchar(100) unique not null,
    username varchar(20) unique not null,
    password varchar(20) not null,
    referrer varchar(10) references customer(id) on delete set null on update cascade,
    status boolean not null default true
);

create table rating(
	book varchar(10),
    number int,
    customer varchar(10) references customer(id) on delete cascade on update cascade,
    primary key(book,number,customer),
    foreign key(book,number) references edition(id,number) on delete cascade on update cascade,
    star int not null default 0 check(star>=0 and star<=5)
);

create table wishlist(
	book varchar(10),
    number int,
    customer varchar(10) references customer(id) on delete cascade on update cascade,
    primary key(book,number,customer),
    foreign key(book,number) references edition(id,number) on delete cascade on update cascade
);

create table comment(
	book varchar(10),
    number int,
    customer varchar(10) references customer(id) on delete cascade on update cascade,
    primary key(book,number,customer),
    foreign key(book,number) references edition(id,number) on delete cascade on update cascade
);

create table commentContent(
	commentText varchar(200),
	commentTime datetime,
    -- commentTime datetime check(commentTime<=now()),
    book varchar(10),
    number int,
    customer varchar(10),
    primary key(commentText,commentTime,book,number,customer),
    foreign key(book,number,customer) references comment(book,number,customer)
);

create table customerOrder(
	id varchar(10) primary key,
    totalCost double not null check(totalCost>=0),
    orderTime datetime not null,
    -- orderTime datetime not null check(orderTime<=now()),
    totalDiscount double default 0 check (totalDiscount>=0),
    customer varchar(10) not null references customer(id) on delete cascade on update cascade,
    status boolean not null default false -- false mean that the customer hasn't paid yet
);

create table physicalOrder(
	orderID varchar(10) primary key references customerOrder(id) on delete cascade on update cascade,
    destinationAddress text not null
);

create table fileOrder(
	orderID varchar(10) primary key references customerOrder(id) on delete cascade on update cascade
);

create table fileOrderContain(
	number int,
    book varchar(10),
    orderID varchar(10) references fileOrder(orderID) on delete cascade on update cascade,
    primary key(number,book,orderID),
    foreign key(book,number) references fileCopy(book,number) on delete cascade on update cascade
);

create table physicalOrderContain(
	number int,
    book varchar(10),
    orderID varchar(10) references physicalOrder(orderID) on delete cascade on update cascade,
    primary key(number,book,orderID),
    foreign key(book,number) references physicalCopy(book,number) on delete cascade on update cascade,
	amount int not null default 1 check(amount>=1)
);

create table discount(
	id varchar(20) primary key
);

create table discountApply(
	orderID varchar(10) references customerOrder(orderID) on delete cascade on update cascade,
    discount varchar(20) references discount(id) on delete cascade on update cascade,
    primary key(orderID,discount)
);

create table customerDiscount(
	discount varchar(20) primary key references discount(id) on delete cascade on update cascade,
    point double unique not null check(point>0),
    discountPercent double not null check(0<discountPercent and discountPercent<100)
);

create table referrerDiscount(
	discount varchar(20) primary key references discount(id) on delete cascade on update cascade,
    numberOfPeople int unique not null check(numberOfPeople>=1),
    discountPercent double not null check(0<discountPercent and discountPercent<100)
);

create table eventDiscount(
	discount varchar(20) primary key references discount(id) on delete cascade on update cascade,
    discountPercent double not null check(0<discountPercent and discountPercent<100),
    applyForAll boolean default false not null,
    startDate date not null,
    -- startDate date not null check(startDate>=curdate()),
    endDate date not null
);

create table eventApply(
	book varchar(10) references book(id) on delete cascade on update cascade,
    discount varchar(20) references eventDiscount(discount) on delete cascade on update cascade,
    primary key(book,discount)
);