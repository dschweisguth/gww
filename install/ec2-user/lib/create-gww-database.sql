create user gww_prod identified by 'gww_prod';
grant all on gww_prod.* to gww_prod;
grant process on *.* to gww_prod; # needed for mysqldump
create database gww_prod collate utf8mb4_unicode_ci;
