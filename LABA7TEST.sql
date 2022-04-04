use proekt1;

go 
select * from People 

go 
update People set first_name = 'Юрая' 
where human_id = 9 

go 
insert into People (first_name, last_name, birth_date, gender_name) values
('Дмитрий', 'Панаев', '24/07/2002', 'M');


go 
select doctor_id, start_of_work, end_of_work from time_of_work 

go 
update time_of_work set 
			start_of_work = '10:00:00', 
			end_of_work = '15:00:00'       
where doctor_id = 49 

go 
select * from Doctors 

go 
select diagnosis_name from diagnosises

go 
update diagnosises set diagnosis_name = 'Коронавирус'
where diagnosis_name = 'ОРВИ' 

go
select diagnosis_name from diagnosises