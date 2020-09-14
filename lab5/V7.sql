use AdventureWorks2012;
go

/*
 * 1
 * Создайте scalar-valued функцию, которая будет 
 * принимать в качестве входного параметра код валюты 
 * (Sales.Currency.CurrencyCode) и возвращать последний 
 * установленный курс по отношению к USD 
 * (Sales.CurrencyRate.ToCurrencyCode).
 */

 create function Sales.LastCurrencyRateUsd (@currencyCode nchar(3))
 returns money as
 begin
	declare @lastDate datetime
	declare @lastCurrencyRate money
	
	select @lastDate = max(CurrencyRateDate)
	from Sales.CurrencyRate
	where FromCurrencyCode = N'USD' 
	      and ToCurrencyCode = @currencyCode;

	select @lastCurrencyRate = EndOfDayRate
	from Sales.CurrencyRate
	where FromCurrencyCode = N'USD' 
	      and ToCurrencyCode = @currencyCode 
		  and CurrencyRateDate = @lastDate;
				
	return @lastCurrencyRate;
 end
 go

print(Sales.LastCurrencyRateUsd(N'CAD'));
go

select 
	CurrencyRateID,
	CurrencyRateDate,
	FromCurrencyCode,
	ToCurrencyCode, 
	EndOfDayRate 
from Sales.CurrencyRate 
where FromCurrencyCode = N'USD'
	  and ToCurrencyCode = N'CAD'
order by CurrencyRateDate desc; 
go

/*
 * 2
 * Создайте inline table-valued функцию, которая 
 * будет принимать в качестве входного параметра 
 * id продукта (Production.Product.ProductID), 
 * а возвращать детали заказа на покупку данного 
 * продукта из Purchasing.PurchaseOrderDetail, 
 * где количество заказанных позиций более 1000 (OrderQty).
 */

create function Purchasing.GetPurchaseOrderDetail(@productID int)
returns table 
as
return 
	select *
	from Purchasing.PurchaseOrderDetail
	where ProductID = @productID
		  and OrderQty > 1000;
go

select 
	count(PurchaseOrderID) 
from Purchasing.GetPurchaseOrderDetail(325);
go

select 
	count(PurchaseOrderID)
from Purchasing.PurchaseOrderDetail
where ProductID = 325 and OrderQty > 1000;
go

/*
 * 3
 * Вызовите функцию для каждого продукта, применив оператор 
 * CROSS APPLY. Вызовите функцию для каждого продукта, 
 * применив оператор OUTER APPLY.
 */

 select 
	Product.ProductID,
	Product.Name,
	PurchaseOrderID,
	PurchaseOrderDetailID,
	OrderQty 
 from Production.Product
 cross apply Purchasing.GetPurchaseOrderDetail(ProductID);
 go

  select 
	Product.ProductID,
	Product.Name,
	PurchaseOrderID,
	PurchaseOrderDetailID,
	OrderQty 
 from Production.Product
 outer apply Purchasing.GetPurchaseOrderDetail(ProductID);
 go

/*
 * 4
 * Измените созданную inline table-valued функцию, сделав ее 
 * multistatement table-valued (предварительно сохранив для 
 * проверки код создания inline table-valued функции).
 */

 create function Purchasing.GetPurchaseOrderDetailMulti(@productID int)
 returns @resultTable table (
	PurchaseOrderID int, 
	PurchaseOrderDetailID int,
	DueDate datetime,
	OrderQty smallint,
	ProductID int,
	UnitPrice money,
	LineTotal money,
	ReceivedQty decimal(8,2),
	RejectedQty decimal(8,2),
	StockedQty decimal(9,2),
	ModifiedDate datetime) 
as 
begin
	insert into @resultTable
		select 
			PurchaseOrderID,
			PurchaseOrderDetailID,
			DueDate,
			OrderQty,
			ProductID,
			UnitPrice,
			LineTotal,
			ReceivedQty,
			RejectedQty,
			StockedQty,
			ModifiedDate
		from Purchasing.PurchaseOrderDetail
		where ProductID = @productID
			  and OrderQty > 1000;
	return
end
go


select 
	PurchaseOrderID,
	PurchaseOrderDetailID,
	ProductID,
	OrderQty
from Purchasing.GetPurchaseOrderDetailMulti(325);
go

select 
	PurchaseOrderID,
	PurchaseOrderDetailID,
	ProductID,
	OrderQty
from Purchasing.GetPurchaseOrderDetail(325);
go


