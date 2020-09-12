use AdventureWorks2012;
go

create table dbo.PersonPhone(
	BusinessEntityID int not null,
	PhoneNumber nvarchar(25) not null,
	PhoneNumberTypeID int not null,
	ModifiedDate datetime not null);
go

alter table dbo.PersonPhone
add constraint PK_PersonPhone_BusinessEntityID_PhoneNumber 
primary key (BusinessEntityID, PhoneNumber);
go

alter table dbo.PersonPhone
add PostalCode nvarchar(15) not null;
go

alter table dbo.PersonPhone
add constraint CHECK_PersonPhone_PostalCode
check (patindex('%[a-zA-Z]%',	PostalCode) = 0);
go

alter table dbo.PersonPhone
add constraint DEFAULT_PersonPhone_PostalCode
default '0' for PostalCode;
go

insert into dbo.PersonPhone (
	BusinessEntityID, 
	PhoneNumber, 
	PhoneNumberTypeID, 
	ModifiedDate)
select 
	Person.PersonPhone.BusinessEntityID, 
	Person.PersonPhone.PhoneNumber, 
	Person.PersonPhone.PhoneNumberTypeID, 
	Person.PersonPhone.ModifiedDate
from Person.PersonPhone
inner join Person.PhoneNumberType
on Person.PersonPhone.PhoneNumberTypeID = Person.PhoneNumberType.PhoneNumberTypeID
where Person.PhoneNumberType.Name = 'Cell';
go

select 
	dbo.PersonPhone.BusinessEntityID,
	dbo.PersonPhone.PhoneNumber,
	dbo.PersonPhone.PhoneNumberTypeID,
	Person.PhoneNumberType.Name as PhoneNumberTypeName,
	dbo.PersonPhone.ModifiedDate,
	dbo.PersonPhone.PostalCode
from dbo.PersonPhone
inner join Person.PhoneNumberType
on dbo.PersonPhone.PhoneNumberTypeID = Person.PhoneNumberType.PhoneNumberTypeID;
go

alter table dbo.PersonPhone
alter column PhoneNumberTypeID bigint null;
go


