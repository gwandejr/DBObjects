/* Create a database called DBObjects.
	Create a table called Employees with the following columns
	ID nvarchar(40) (GUID using NewID()) Primary Key
	BadgeNum INT NOT NULL UNIQUE
	SSN int Not Null (using 9 digits of random numbers)
	Title VARCHAR(20) NULL
	DATEHired DateTime2 Not NULL default to current date */

if DB_ID('DB_Objects') is not null
begin
	drop database DB_Objects;
end;
go

create database DB_Objects;
go

use DB_Objects;
go

set nocount on;
go

create table Employees
(ID nvarchar(40) not null PRIMARY KEY,
 BadgeNum int not null unique,
 SSN int not null,
 Title varchar(20) null,
 DateHired datetime2 not null);
 go

/* Place a trigger on the Employees table for every insert, it will update the Title with the following verbiage.
	If BadgeNum = 0-300, Title=Clerk
	If BadgeNum = 300-699, Title=Office Employee
	If BadgeNum = 700-899, Title=Manager
	If BadgeNum = 900-1000, Title=Director */

create trigger trg_MakeTitle on Employees
 after insert
 as
 update Employees
 set Title = (case when BadgeNum between 0 and 299 then 'Clerk'
					when BadgeNum between 300 and 699 then 'Office Employee'
					when BadgeNum between 700 and 899 then 'Manager'
					when BadgeNum between 900 and 1000 then 'Director'
			 end)
 where ID is not null;
 go

 /* Begin Loop 25 times
	 Generate a random number between 0 and 1000 for the BadgeNum
	 Insert a rec into Employees table 
	 BadgeNum = newly generated random number
	 Title=Null
	 End loop */

declare @counter int = 1;
declare @guid_ID nvarchar(40);
declare @rndmNumSSN int;
declare @rndmNumBadge int;

while @counter <= 25
begin
	set @guid_ID = NEWID();
	set @rndmNumSSN = cast(rand() * 899999999 as int) + 100000000;
	set @rndmNumBadge = cast(rand() * 1000 as int);

	insert Employees (ID, BadgeNum, SSN, Title, DateHired)
			   values(@guid_ID, @rndmNumBadge, @rndmNumSSN, null, GetDate());

set @counter += 1;
end;
go

/* Generate a cursor from the Employees table for all records
	Loop through entire cursor and display all fields on the same 
	line for each record, separated by spaces. */

declare @ID nvarchar(40);
declare @BadgeNum int;
declare @SSN int;
declare @Title varchar(20);
declare @DateHired datetime2;

declare CursorEmployees cursor fast_forward for
	select ID, BadgeNum, SSN, Title, DateHired
	from Employees;
	
open CursorEmployees;

fetch next from CursorEmployees into @ID, @BadgeNum, @SSN, @Title, @DateHired;

while @@FETCH_STATUS = 0
begin
	print @ID + ' ' + cast(@BadgeNum as varchar) + ' ' + cast(@SSN as varchar) +
		' ' + @Title + ' ' + cast(@DateHired as varchar);
	fetch next from CursorEmployees into @ID, @BadgeNum, @SSN, @Title, @DateHired;
end;

close CursorEmployees;
deallocate CursorEmployees;
go

/* Create a view showing only ID, BadgeNum, and Title */

create view vw_Employees as
select ID, BadgeNum, Title
from Employees;
go

select * from vw_Employees;