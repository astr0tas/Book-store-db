create user 'ABS'@'localhost' identified with mysql_native_password by 'ABS123';
-- Or use this line if the above one does not work
-- create user 'owner'@'localhost' identified by 'owner123';

grant all privileges on bookstore.* to 'ABS'@'localhost';

grant file on *.* to 'ABS'@'localhost';