use AdventureWorks2012;
go

/*
 * 1
 * Создайте таблицу Sales.CurrencyHst, которая будет хранить 
 * информацию об изменениях в таблице Sales.Currency.
 * 
 * Обязательные поля, которые должны присутствовать в таблице: 
 * ID — первичный ключ IDENTITY(1,1); 
 * Action — совершенное действие (insert, update или delete); 
 * ModifiedDate — дата и время, когда была совершена операция; 
 * SourceID — первичный ключ исходной таблицы; 
 * UserName — имя пользователя, совершившего операцию. 
 * 
 * Создайте другие поля, если считаете их нужными.
 */

create table Sales.CurrencyHst (
	ID int identity(1,1) primary key,
	Action nvarchar(15) not null,
	ModifiedDate datetime not null,
	SourceID nchar(3) not null,
	UserName nvarchar(25));
go
/*
 * 2
 * Создайте три AFTER триггера для трех операций 
 * INSERT, UPDATE, DELETE для таблицы Sales.Currency. 
 * Каждый триггер должен заполнять таблицу Sales.CurrencyHst 
 * с указанием типа операции в поле Action.
 */

create trigger Sales.trgSalesCurrencyInsert
on Sales.Currency	
after insert as
begin
	set nocount on;
	insert into Sales.CurrencyHst (
		Action, 
		ModifiedDate,
		SourceID,
		UserName)
	select 
		'INSERT',
		CURRENT_TIMESTAMP,
		CurrencyCode,
		CURRENT_USER
	from inserted;
end
go

create trigger Sales.trgSalesCurrencyDelete
on Sales.Currency	
after delete as
begin
	set nocount on;
	insert into Sales.CurrencyHst (
		Action, 
		ModifiedDate,
		SourceID,
		UserName)
	select 
		'DELETE',
		CURRENT_TIMESTAMP,
		CurrencyCode,
		CURRENT_USER
	from deleted;
end
go

create trigger Sales.trgSalesCurrencyUpdate
on Sales.Currency	
after update as
begin
	set nocount on;
	insert into Sales.CurrencyHst (
		Action, 
		ModifiedDate,
		SourceID,
		UserName)
	select 
		'UPDATE',
		CURRENT_TIMESTAMP,
		CurrencyCode,
		CURRENT_USER
	from inserted;
end
go

/*
 * 3
 * Создайте представление VIEW, отображающее все поля таблицы Sales.Currency. 
 * Сделайте невозможным просмотр исходного кода представления. 
 */

 create view Sales.vCurrency 
 with encryption as
 select * from Sales.Currency;
 go

 select definition 
 from sys.sql_modules 
 where object_id = object_id('Sales.vCurrency');
 go

 select * from Sales.vCurrency order by Name;
 go

 /*
  * 4
  * Вставьте новую строку в Sales.Currency через представление. 
  * Обновите вставленную строку. 
  * Удалите вставленную строку. 
  * Убедитесь, что все три операции отображены в Sales.CurrencyHst.
  */

 insert into Sales.vCurrency (
	CurrencyCode,
	Name,
	ModifiedDate)
 values (
	N'MYD',
	'My Dollar',
	CURRENT_TIMESTAMP); 
 go

 update Sales.vCurrency 
 set Name = 'My Ruble'
 where CurrencyCode = N'MYD';
 go

 delete from Sales.vCurrency
 where CurrencyCode = N'MYD';
 go 


select * from Sales.CurrencyHst;
go