use AdventureWorks2012;
go

select Employee.BusinessEntityID, JobTitle, max(RateChangeDate) as LastRateDate
from HumanResources.Employee
inner join HumanResources.EmployeePayHistory 
on Employee.BusinessEntityID = EmployeePayHistory.BusinessEntityID
group by Employee.BusinessEntityID, JobTitle;
go

select 
	Employee.BusinessEntityID, 
	Employee.JobTitle, 
	Department.Name as DepName, 
	EmployeeDepartmentHistory.StartDate,
	EmployeeDepartmentHistory.EndDate,
	datediff(year, StartDate, isnull(EndDate, CURRENT_TIMESTAMP)) as Years
from HumanResources.Employee
inner join HumanResources.EmployeeDepartmentHistory
on Employee.BusinessEntityID = EmployeeDepartmentHistory.BusinessEntityID
inner join HumanResources.Department
on EmployeeDepartmentHistory.DepartmentID = Department.DepartmentID;
go

select 
	Employee.BusinessEntityID,
	Employee.JobTitle,
	Department.Name as DepName,
	Department.GroupName,
	left(GroupName, CHARINDEX(' ', GroupName)) as DepGroup
from HumanResources.Employee
inner join HumanResources.EmployeeDepartmentHistory
on Employee.BusinessEntityID = EmployeeDepartmentHistory.BusinessEntityID
inner join HumanResources.Department
on EmployeeDepartmentHistory.DepartmentID = Department.DepartmentID
where EndDate is null;
go

