/*Разобьем таблицу на случаи 
1. Пациент пришел, у него диагноз  должен быть не 'Здоров',но и не 'Диагноз не поставлен' соответственно перенапрваление тоже не нулевое,
 перенапрваляет врач к себе же.
2. Врач лечил пациента и в Конце концов у него 'Диагноз не поставлен', его перенаправляют к жругому врачу, соответсвенно 
доктора из двух таблиц visit _id не равны
*/ 
/*IF(OBJECT_ID('healing') IS NOT NULL)
		DROP VIEW healing;

go

CREATE VIEW  healing AS 
WITH list as (
SELECT vis1.visit_id, vis1.visit_time as date, vis1.redirection_id as redirected,vis1.doctor_id, vis1.patient_id, diag1.diagnosis_name as diagnosis 
FROM Visit vis1 
INNER JOIN Diagnosis diag1 ON diag1.visit_id = vis1.visit_id
INNER JOIN Visit vis2 ON vis2.visit_id = vis1.redirection_id
WHERE vis1.redirection_id IS NOT NULL
and vis1.doctor_id = vis2.doctor_id 
and diag1.diagnosis_name != 'Здоров'
and diag1.diagnosis_name != 'Дигноз не поставлен' 
UNION 
SELECT vis4.visit_id, vis4.visit_time as date, vis4.redirection_id as redirected,vis4.doctor_id, vis4.patient_id, diag2.diagnosis_name as diagnosis 
FROM Visit vis4 
INNER JOIN Visit vis3  ON vis3.redirection_id = vis4.visit_id
INNER JOIN diagnosis diag2 ON diag2.visit_id = vis4.visit_id
WHERE vis3.doctor_id = vis4.doctor_id
AND (
diag2.diagnosis_name = 'Здоров' OR 
diag2.diagnosis_name = 'Диагноз не поставлен'
)),
/*2. Врач лечил пациента и в Конце концов у него 'Диагноз не поставлен', его перенаправляют к жругому врачу, соответсвенно 
доктора из двух таблиц visit _id не равны  */ 
helpful as (
SELECT list1.visit_id, list1.date, list1.redirected as redirected, list1.doctor_id, list1.patient_id, list1.diagnosis
FROM list list1 
INNER JOIN list list2 ON list2.visit_id = list1.redirected
WHERE 
 list1.doctor_id != list2.doctor_id   
 and list1.diagnosis = 'Диагноз не поставлен' 
 ),
 /* Среди таблисты list надо найти минимальный день приема и максимальный день приема, когда пациент здоров*/
start_of_healing (visit, date, redirected,doctor_id,patient_id,row) as (
select visit_id, date, redirected,doctor_id, patient_id, ROW_NUMBER() OVER(PARTITION BY doctor_id, patient_id  ORDER BY date ASC) as row
from list
where (visit_id not in (
select redirected from list
where redirected IS NOT NULL 
))  OR visit_id IN (select redirected from helpful)),
end_of_healing (visit, date, redirected,doctor_id,patient_id,row) as (
select  visit_id, date, redirected,doctor_id,patient_id, ROW_NUMBER() OVER(PARTITION BY doctor_id, patient_id  ORDER BY date ASC) as row
from list 
where redirected IS NULL OR visit_id IN (SELECT visit_id from helpful)) 
SELECT soh.doctor_id, peop.first_name as name1, peop.last_name as last_name, soh.patient_id, peo.first_name as name2, peo.last_name as last_name2, DATEDIFF(day, soh.date, eoh.date) as time_of_healing
from start_of_healing soh 
INNER JOIN  end_of_healing eoh ON eoh.patient_id = soh.patient_id and eoh.doctor_id = soh.doctor_id  
INNER JOIN People peop ON  peop.human_id = soh.doctor_id
INNER JOIN People peo ON  peo.human_id = soh.patient_id
WHERE eoh.row = soh.row
 */

 /*
		IF(OBJECT_ID('season_sickness') IS NOT NULL)
				DROP VIEW season_sickness;

go

CREATE VIEW season_sickness AS
SELECT month(v2.visit_time) as month, d1.diagnosis_name,ssn.social_status_name, COUNT(*) AS summ
 FROM Visit v2
 INNER JOIN Visit v1 ON v1.redirection_id = v2.visit_id
 INNER JOIN diagnosis d1 ON d1.visit_id = v1.visit_id
 INNER JOIN diagnosis d2 ON d2.visit_id = v2.visit_id
 INNER JOIN Patients p ON v2.patient_id = p.patient_id
 INNER JOIN Social_status ss ON p.patient_id = ss.patient_id 
 INNER JOIN Social_status_name ssn ON ssn.social_status_number = ss.social_status_number
 WHERE d1.diagnosis_name != 'Здоров' 
 AND d2.diagnosis_name = 'Здоров'
 AND v1.redirection_id IS NOT NULL
 GROUP  BY month(v2.visit_time), d1.diagnosis_name, ssn.social_status_name
 */
 /* 
 IF(ODJECT_ID('doctor_list') IS NOT NULL)
		DROP VIEW doctor_list

go 


 CREATE VIEW doctor_list as
 with heal as(
 SELECT v2.doctor_id, year(v2.visit_time) as year, COUNT(*) as summ1
 FROM Visit v2  
 INNER JOIN Visit v1 ON v1.redirection_id = v2.visit_id 
 INNER JOIN diagnosis d1 ON d1.visit_id = v2.visit_id 
 INNER JOIN diagnosis d2 ON d2.visit_id = v1.visit_id
 WHERE d1.diagnosis_name = 'Здоров' 
 and d2.diagnosis_name != 'Здоров'
 GROUP BY v2.doctor_id, year(v2.visit_time) ), 
 all_patients as ( 
 SELECT v2.doctor_id, year(v2.visit_time) as year, COUNT(*) as summ2
 FROM Visit v2  
 INNER JOIN Visit v1 ON v1.redirection_id = v2.visit_id 
 GROUP BY v2.doctor_id, year(v2.visit_time)),
 first as(
 SELECT heal.doctor_id, heal.year, heal.summ1, all_patients.summ2
 FROM heal 
 INNER JOIN all_patients ON heal.doctor_id = all_patients.doctor_id
 and heal.year = all_patients.year )
 SELECT first.doctor_id, first.year, first.summ1, first.summ2 
 FROM first 
 UNION 
 SELECT al.doctor_id, al.year, 0 as summ1, al.summ2
 FROM all_patients al
 WHERE al.year NOT IN (select year from first)
 */
 /*Год рождения, количество пациентов этого года рождения, чаще всего встречающийся у них диагноз.*/ 
 
 /*if (object_id('years') is not NULL)
		 DROP VIEW years 
		go 



 CREATE VIEW years AS
 WITH start as (
 SELECT year(p.birth_date) as year, COUNT(*) as count, d.diagnosis_name
 FROM People p 
 INNER JOIN Patients pat ON pat.patient_id = p.human_id 
 INNER JOIN Visit vis1 ON vis1.patient_id = pat.patient_id
 INNER JOIN diagnosis d ON  d.visit_id = vis1.visit_id
 INNER JOIN Visit vis2 ON vis2.visit_id = vis1.redirection_id
 INNER JOIN Diagnosis d2 ON d2.visit_id = vis2.visit_id
 WHERE d.diagnosis_name != 'Здоров'
 and d.diagnosis_name != 'Диагноз не поставлен'
 and d2.diagnosis_name = 'Здоров'
 GROUP BY year(p.birth_date), d.diagnosis_name),
middle as(
 SELECT year, MAX(COUNT) as injured 
 FROM start 
 GROUP BY year
),
finish as(
SELECT m.year, s.diagnosis_name 
FROM start s 
INNER JOIN middle m ON m.year=s.year 
and m.injured = s.count
),
restart as (
SELECT year(birth_date) as year, COUNT(*) as quantity
FROM People 
GROUP BY year(birth_date) 
) 
SELECT f.year, f.diagnosis_name, r.quantity
FROM finish f 
INNER JOIN restart r ON r.year = f.year  

go 
select * 
from  season_sickness
 */
 if(object_id('diagnosises') is not null)
 drop view diagnosises 
 go 

 CREATE VIEW diagnosises as 
 select diagnosis_name, visit_id
 from diagnosis 

