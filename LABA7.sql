use proekt1  

drop login test;
go 

drop user test;
go 

drop role test_role;
go 
 
create login test with password = 'EgorMIPT',
default_database = proekt1; 
select name, sid FROM sys.sql_logins WHERE name = 'test';
go 

create user test for login test;
go   

grant select, insert, update ON object :: dbo.People to test 
go 

grant select, update ON object :: dbo.time_of_work(start_of_work, end_of_work, doctor_id) to test 
go  

grant select ON object :: dbo.Doctors to test 
go

grant select ON object :: dbo.season_sickness to test 
go 

create role test_role 
go 

grant select, update on object :: dbo.diagnosises(diagnosis_name) to test_role 
go  

alter role test_role add member test 
go  
 
alter login test with password = 'egorMIPT';






