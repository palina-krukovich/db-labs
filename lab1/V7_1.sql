create database NewDatabase;
go

use NewDatabase;
go

create schema sales;
go

create schema personas;
go

create table sales.Orders(OrderNum int null);
go

backup database NewDatabase
to disk = 'D:\study\DB\lab1\POLINA_KRUKOVICH.bak';
go

use master;
go

drop database NewDatabase;
go

restore database NewDatabase
from disk = 'D:\study\DB\lab1\POLINA_KRUKOVICH.bak';
go

