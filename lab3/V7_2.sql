/* 
 * 1
 * Добавьте в таблицу dbo.PersonPhone поля OrdersCount INT и CardType NVARCHAR(50). 
 * Также создайте в таблице вычисляемое поле IsSuperior, которое будет хранить 1, 
 * если тип карты ‘SuperiorCard’ и 0 для остальных карт.
 */

 alter table dbo.PersonPhone
 add OrdersCount int;
 go

 alter table dbo.PersonPhone
 add CardType nvarchar(50);
 go

 alter table dbo.PersonPhone
 add IsSuperior as iif(CardType = 'SuperiorCard', 1, 0);
 go

 select * from dbo.PersonPhone;
 go

 /*
  * 2
  * Создайте временную таблицу #PersonPhone, с первичным ключом по полю BusinessEntityID. 
  * Временная таблица должна включать все поля таблицы dbo.PersonPhone за исключением поля
  * IsSuperior.
  */

 create table #PersonPhone (
	BusinessEntityID int not null,
	PhoneNumber nvarchar(25) not null,
	PhoneNumberTypeID bigint,
	ModifiedDate datetime not null,
	PostalCode nvarchar(15) not null,
	OrdersCount int,
	CardType nvarchar(50));
 go

 alter table #PersonPhone
 add constraint PK_PersonPhone_BusinessEntityID primary key (BusinessEntityID);
 go

 /*
  * 3
  * Заполните временную таблицу данными из dbo.PersonPhone. 
  * Поле CardType заполните данными из таблицы Sales.CreditCard. 
  * Посчитайте количество заказов, оплаченных каждой картой (CreditCardID) 
  * в таблице Sales.SalesOrderHeader и заполните этими значениями поле OrdersCount. 
  * Подсчет количества заказов осуществите в Common Table Expression (CTE).
  */

 with CardOrders (CardID, CardOrdersCount) as (
	select 
		Sales.SalesOrderHeader.CreditCardID,
		count(Sales.SalesOrderHeader.CreditCardID)
	from Sales.SalesOrderHeader
	group by Sales.SalesOrderHeader.CreditCardID
 )
 insert into #PersonPhone (
	BusinessEntityID,
	PhoneNumber,
	PhoneNumberTypeID,
	ModifiedDate,
	PostalCode,
	OrdersCount,
	CardType)
 select 
	dbo.PersonPhone.BusinessEntityID,
	dbo.PersonPhone.PhoneNumber,
	dbo.PersonPhone.PhoneNumberTypeID,
	dbo.PersonPhone.ModifiedDate,
	dbo.PersonPhone.PostalCode,
	CardOrders.CardOrdersCount,
	Sales.CreditCard.CardType
 from dbo.PersonPhone
 left join Sales.PersonCreditCard
 on dbo.PersonPhone.BusinessEntityID = Sales.PersonCreditCard.BusinessEntityID
 left join Sales.CreditCard
 on Sales.PersonCreditCard.CreditCardID = Sales.CreditCard.CreditCardID
 left join CardOrders
 on Sales.CreditCard.CreditCardID = CardOrders.CardID;
 go

 select * from #PersonPhone
 order by BusinessEntityID asc;
 go

 /*
  * 4
  * Удалите из таблицы dbo.PersonPhone одну строку (где BusinessEntityID = 297)
  */

  select * from dbo.PersonPhone
  where BusinessEntityID = 297;
  go

  delete from dbo.PersonPhone 
  where BusinessEntityID = 297;
  go

  select * from dbo.PersonPhone
  where BusinessEntityID = 297;
  go

  /*
   * 5
   * Напишите Merge выражение, использующее dbo.PersonPhone как target, 
   * а временную таблицу как source. Для связи target и source используйте 
   * BusinessEntityID. 
   * Обновите поля OrdersCount и CardType, если запись присутствует в source 
   * и target. Если строка присутствует во временной таблице, но не существует 
   * в target, добавьте строку в dbo.PersonPhone. Если в dbo.PersonPhone 
   * присутствует такая строка, которой не существует во временной таблице, 
   * удалите строку из dbo.PersonPhone.
   */

   insert into dbo.PersonPhone (
		BusinessEntityID,
		PhoneNumber,
		ModifiedDate,
		PostalCode)
   values (
		987654321,
		'987654321',
		CURRENT_TIMESTAMP,
		'987654321');
   go

   select * from dbo.PersonPhone
   where BusinessEntityID = 987654321;
   go

   merge dbo.PersonPhone t 
   using #PersonPhone s
   on (t.BusinessEntityID = s.BusinessEntityID)
   when matched 
		then update set 
			t.OrdersCount = s.OrdersCount, 
			t.CardType = s.CardType
   when not matched by target
		then insert (
			BusinessEntityID,
			PhoneNumber,
			PhoneNumberTypeID,
			ModifiedDate,
			PostalCode,
			OrdersCount,
			CardType) 
		values (
			s.BusinessEntityID,
			s.PhoneNumber,
			s.PhoneNumberTypeID,
			s.ModifiedDate,
			s.PostalCode,
			s.OrdersCount,
			s.CardType)
   when not matched by source
		then delete;
   go

   select * from dbo.PersonPhone
   where BusinessEntityID = 297 or BusinessEntityID = 987654321;
   go
