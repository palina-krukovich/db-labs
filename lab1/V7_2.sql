use AdventureWorks2012;
go

select count(DepartmentID) as DepartmentCount
from HumanResources.Department
where GroupName = 'Executive General and Administration';
go

select top 5 BusinessEntityID, JobTitle, Gender, BirthDate
from HumanResources.Employee
order by BirthDate desc;
go

select 
	BusinessEntityID, 
	JobTitle, 
	Gender, 
	HireDate, 
	replace(LoginID, 'adventure-works', 'adventure-works2012')
from HumanResources.Employee
where Gender = 'F' and datename(dw, HireDate) = 'Tuesday';