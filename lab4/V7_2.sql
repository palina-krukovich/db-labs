use AdventureWorks2012;
go

/*
 * 1
 * Создайте представление VIEW, отображающее данные из таблиц 
 * Sales.Currency и Sales.CurrencyRate. 
 * Таблица Sales.Currency должна отображать название валюты 
 * для поля ToCurrencyCode. 
 * Создайте уникальный кластерный индекс в представлении по полю 
 * CurrencyRateID.
 */

 create view Sales.vCurrencyRate 
 with schemabinding, encryption
 as
 select 
	Sales.CurrencyRate.CurrencyRateID,
	Sales.CurrencyRate.CurrencyRateDate,
	Sales.CurrencyRate.FromCurrencyCode,
	Sales.Currency.Name as ToCurrencyCodeName,
	Sales.CurrencyRate.AverageRate,
	Sales.CurrencyRate.EndOfDayRate,
	Sales.CurrencyRate.ModifiedDate
 from Sales.CurrencyRate
 inner join Sales.Currency
 on Sales.CurrencyRate.ToCurrencyCode = Sales.Currency.CurrencyCode;
 go 

 create unique clustered index 
	idxCurrencyRateID
 on Sales.vCurrencyRate (CurrencyRateID);
 go

 select * from Sales.vCurrencyRate;
 go

 /*
  * 2
  * Создайте один INSTEAD OF триггер для представления 
  * на три операции INSERT, UPDATE, DELETE. 
  * Триггер должен выполнять соответствующие операции 
  * в таблицах Sales.Currency и Sales.CurrencyRate.
  */

  create trigger Sales.trg_vCurrencyRate
  on Sales.vCurrencyRate
  instead of insert, update, delete
  as
  begin
		set nocount on;
		if exists(select * from inserted) and exists(select * from deleted)  
		begin
			update scr set 
				scr.CurrencyRateDate = i.CurrencyRateDate,
				scr.FromCurrencyCode = i.FromCurrencyCode,
				scr.ToCurrencyCode = sc.CurrencyCode,
				scr.AverageRate = i.AverageRate,
				scr.EndOfDayRate = i.EndOfDayRate,
				scr.ModifiedDate = i.ModifiedDate
			from Sales.CurrencyRate as scr
			inner join inserted as i
			on scr.CurrencyRateID = i.CurrencyRateID
			inner join Sales.Currency as sc
			on i.ToCurrencyCodeName = sc.Name; 
		end
		else if exists(select * from inserted)    
			insert into Sales.CurrencyRate (
				CurrencyRateDate,
				FromCurrencyCode,
				ToCurrencyCode,
				AverageRate,
				EndOfDayRate,
				ModifiedDate)
			select 
				i.CurrencyRateDate,
				i.FromCurrencyCode,
				sc.CurrencyCode,
				i.AverageRate,
				i.EndOfDayRate,
				i.ModifiedDate
			from inserted as i
			inner join Sales.Currency as sc
			on i.ToCurrencyCodeName = sc.Name;
		else if exists(select * from deleted) 
			delete scr 
			from Sales.CurrencyRate as scr
			inner join deleted as d
			on scr.CurrencyRateID = d.CurrencyRateID;
  end
  go

/*
 * 3
 * Вставьте новую строку в представление, 
 * указав новые данные для Currency и CurrencyRate 
 * (укажите FromCurrencyCode = ‘USD’). 
 * Триггер должен добавить новые строки в таблицы 
 * Sales.Currency и Sales.CurrencyRate. 
 * Обновите вставленные строки через представление. 
 * Удалите строки.
 */

 insert into Sales.vCurrencyRate (
	CurrencyRateDate,
	FromCurrencyCode,
	ToCurrencyCodeName,
	AverageRate,
	EndOfDayRate,
	ModifiedDate)
 values (
	CURRENT_TIMESTAMP,
	N'USD',
	'US Dollar',
	1.00,
	1.00,
	CURRENT_TIMESTAMP);	
 go

 select * from Sales.CurrencyRate
 order by ModifiedDate desc;
 go

 update Sales.vCurrencyRate
 set FromCurrencyCode = N'CAD'
 where CurrencyRateID = 13534;
 go

 delete from Sales.vCurrencyRate
 where CurrencyRateID = 13534;
 go