use AdventureWorks2012;
go

/*
 * Создайте хранимую процедуру, которая будет возвращать 
 * сводную таблицу (оператор PIVOT), отображающую данные 
 * о количестве сотрудников (HumanResources.Employee), 
 * работающих в определенную смену (HumanResources.Shift). 
 * Вывести информацию необходимо для каждого отдела 
 * (HumanResources.Department). 
 * 
 * Список названий смен передайте в процедуру через 
 * входной параметр.
 * 
 * Таким образом, вызов процедуры будет выглядеть следующим образом:
 * EXECUTE dbo.EmpCountByShift ‘[Day],[Evening],[Night]’
 */

create procedure HumanResources.GetShiftEmplCounts @shifts nvarchar(max)
as
begin
	declare @sql nvarchar(max) = '
	select * from (
		select 
			e.BusinessEntityID,
			d.Name as DepName,
			s.Name as ShiftName 
		from HumanResources.EmployeeDepartmentHistory as edh
		inner join HumanResources.Employee as e
		on edh.BusinessEntityID = e.BusinessEntityID
		inner join HumanResources.Department as d
		on edh.DepartmentID = d.DepartmentID
		inner join HumanResources.Shift as s
		on edh.ShiftID = s.ShiftID
		where edh.EndDate is null
	) as t
	pivot (
		count(BusinessEntityID)
		for shiftName in (' + @shifts + ')
	) as pivotTable;';
	execute sp_executesql @sql;
end
go

EXEC HumanResources.GetShiftEmplCounts @shifts = '[Day],[Evening],[Night]';
go