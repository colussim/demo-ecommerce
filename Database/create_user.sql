CREATE USER 'app'@'%' IDENTIFIED BY 'your_password';
GRANT ALL PRIVILEGES ON mydb.* TO 'app'@'%';
FLUSH PRIVILEGES;