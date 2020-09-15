use AdventureWorks2012;
go

/*
 * Вывести значения полей [ProductID], [Name] 
 * из таблицы [Production].[Product] и полей 
 * [ProductModelID] и [Name] из таблицы 
 * [Production].[ProductModel] в виде xml, 
 * сохраненного в переменную. 
 */

 declare @xml xml; 
 
 set @xml = (
	 select top 2
		p.ProductID as [@ID],
		p.Name,
		pm.ProductModelID as [Model/@ID],
		pm.Name as [Model/Name]
	 from Production.Product as p
	 inner join Production.ProductModel pm
	 on p.ProductModelID = pm.ProductModelID
	 for xml path ('Product'), root('Products')
 );

 select @xml;
 go

