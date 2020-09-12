use AdventureWorks2012;
go

/*
 * 1
 * Добавьте в таблицу dbo.PersonPhone поле City типа nvarchar(30);
 */

alter table dbo.PersonPhone
add City nvarchar(30);
go

/*
 * 2
 * Объявите табличную переменную с такой же структурой как dbo.PersonPhone 
 * и заполните ее данными из dbo.PersonPhone. Поле City заполните значениями 
 * из таблицы Person.Address поля City, а поле PostalCode значениями из 
 * Person.Address поля PostalCode. Если поле PostalCode содержит буквы — 
 * заполните поле значением по умолчанию
 */

declare @dboPersonPhone table (
	BusinessEntityID int not null,
	PhoneNumber nvarchar(25) not null,
	PhoneNumberTypeID bigint,
	ModifiedDate datetime not null,
	PostalCode nvarchar(15) not null,
	City nvarchar(30));

insert into @dboPersonPhone (
	BusinessEntityID,
	PhoneNumber,
	PhoneNumberTypeID,
	ModifiedDate,
	PostalCode,
	City)
select 
	PersonPhone.BusinessEntityID,
	PersonPhone.PhoneNumber,
	PersonPhone.PhoneNumberTypeID,
	PersonPhone.ModifiedDate,
	iif(patindex('%[a-zA-Z]%', Address.PostalCode) = 0, Address.PostalCode, '0'),
	Address.City
 from dbo.PersonPhone
 inner join Person.BusinessEntityAddress
 on dbo.PersonPhone.BusinessEntityID = Person.BusinessEntityAddress.BusinessEntityID
 inner join Person.Address
 on Person.BusinessEntityAddress.AddressID = Person.Address.AddressID;

/*
 * 3
 * Обновите данные в полях PostalCode и City в dbo.PersonPhone данными 
 * из табличной переменной. Также обновите данные в поле PhoneNumber. 
 * Добавьте код ‘1 (11)’ для тех телефонов, для которых этот код не указан
 */
 
 update dbo.PersonPhone
 set dbo.PersonPhone.PostalCode = dboPersonPhone.PostalCode,
	 dbo.PersonPhone.City = dboPersonPhone.City,
	 dbo.PersonPhone.PhoneNumber = iif(patindex(
		'%1 (11)%', dbo.PersonPhone.PhoneNumber) = 0, 
		'1 (11)' + dbo.PersonPhone.PhoneNumber,
		dbo.PersonPhone.PhoneNumber)	
 from dbo.PersonPhone 
 inner join @dboPersonPhone as dboPersonPhone
 on dbo.PersonPhone.BusinessEntityID = dboPersonPhone.BusinessEntityID;
 go

 select * from dbo.PersonPhone;
 go

 /*
  * 4
  * Удалите данные из dbo.PersonPhone для сотрудников компании, 
  * то есть где PersonType в Person.Person равен ‘EM’
  */

 select BusinessEntityID, PersonType from Person.Person;
 go

 delete from dbo.PersonPhone 
 where exists (
	select BusinessEntityID, PersonType
	from Person.Person
	where dbo.PersonPhone.BusinessEntityID = Person.Person.BusinessEntityID 
		  and Person.Person.PersonType = 'EM'); 
 go

 select * from dbo.PersonPhone;
 go

 /*
  * 5
  * Удалите полe City из таблицы, удалите все созданные ограничения 
  * и значения по умолчанию
  */

 alter table dbo.PersonPhone
 drop column City;
 go

 select * from dbo.PersonPhone;
 go

 alter table dbo.PersonPhone
 drop constraint CHECK_PersonPhone_PostalCode;
 go

 alter table dbo.PersonPhone
 drop constraint DEFAULT_PersonPhone_PostalCode;
 go

 /*
  * 6
  * Удалите таблицу dbo.PersonPhone
  */

 drop table dbo.PersonPhone;
 go

 select * from dbo.PersonPhone;
 go