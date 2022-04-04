----1----
/*/*Вывести всех пациентов, которые лечились у конкретногo врача  и сколько дней  */
WITH visit_list (visit, date, redirected, doctor_id, patient_id) 
AS (
SELECT v1.visit_id as visit, v1.visit_time as date, v1.redirection_id as redirected, v1.doctor_id, v1.patient_id
FROM Visit v1
INNER JOIN Visit v2 ON v1.redirection_id = v2.visit_id 
WHERE (v1.doctor_id = v2.doctor_id) and (v1.patient_id = v2.patient_id) 
UNION 
SELECT v4.visit_id as visit, v4.visit_time as date, v4.redirection_id as redirected, v4.doctor_id, v4.patient_id
FROM Visit v3
INNER JOIN Visit v4 ON v3.redirection_id = v4.visit_id 
WHERE (v3.doctor_id = v4.doctor_id) and (v3.patient_id = v4.patient_id)  
),
start_of_healing (visit, date, redirected,doctor_id,patient_id,row) as (
select visit, date, redirected,doctor_id, patient_id, ROW_NUMBER() OVER(PARTITION BY doctor_id, patient_id  ORDER BY date ASC) as row
from visit_list 
where visit not in (
select redirected from visit_list
where redirected IS NOT NULL 
)), 
end_of_healing (visit, date, redirected,doctor_id,patient_id,row) as (
select  visit, date, redirected,doctor_id,patient_id, ROW_NUMBER() OVER(PARTITION BY doctor_id, patient_id  ORDER BY date ASC) as row
from visit_list 
where redirected IS NULL ) 
SELECT soh.doctor_id, soh.patient_id, DATEDIFF(day, soh.date, eoh.date) as time_of_healing
from start_of_healing soh 
INNER JOIN  end_of_healing eoh ON eoh.patient_id = soh.patient_id and eoh.doctor_id = soh.doctor_id 
WHERE eoh.row = soh.row */
------------------------------------------------------------------------------------------------------------------------------------------
----2---- 
/*Врачи которые не работают во вторник*/
/*SELECT People.first_name, People.last_name, Doctors.doctor_id, Specialization.profession_name 
FROM People
INNER JOIN Doctors ON People.human_id = Doctors.doctor_id   
INNER JOIN Profession ON Doctors.doctor_id = Profession.doctor_id
INNER JOIN Specialization ON Profession.profession_id = Specialization.profession_id
where
Doctors.doctor_id NOT IN (select doctor_id 
              from time_of_work
			  where day_of_work = 'Вторник')
GROUP BY Doctors.doctor_id, People.first_name, People.last_name, Specialization.profession_name  */
------------------------------------------------------------------------------------------------------------------
----3----
/*/*Доктора, которые работали исключительно с инвалидами*/
SELECT DISTINCT Doctors.doctor_id, People.first_name, People.last_name 
FROM Doctors INNER JOIN People ON People.human_id = Doctors.doctor_id 
INNER JOIN Visit ON Visit.doctor_id = Doctors.doctor_id
INNER JOIN  Patients ON Visit.patient_id = Patients.patient_id
INNER JOIN Social_status ON Social_status.patient_id = Patients.patient_id
INNER JOIN Social_status_name ON Social_status_name.social_status_number = Social_status.social_status_number
where Social_status_name.social_status_name ='Инвалид' AND Doctors.doctor_id NOT IN 
(SELECT  Doctors.doctor_id
FROM Doctors 
INNER JOIN Visit ON Visit.doctor_id = Doctors.doctor_id
INNER JOIN  Patients ON Visit.patient_id = Patients.patient_id
INNER JOIN Social_status ON Social_status.patient_id = Patients.patient_id
INNER JOIN Social_status_name ON Social_status_name.social_status_number = Social_status.social_status_number 
WHERE Social_status_name.social_status_name !='Инвалид'
group by doctors.doctor_id) */ 
-------------------------------------------------------
---4---
/*количество подчиненных у каждого доктора  */
/*WITH doc_count AS (
SELECT manager_id, COUNT(*) as doc_count
FROM Doctors
GROUP BY manager_id
) 
SELECT doc.doctor_id, dc.doc_count
FROM Doctors doc
INNER JOIN doc_count dc ON doc.doctor_id = dc.manager_id */
-------------------------------------------------------------------------
----5---- 
/*Рекурсия докторов*/
/*WITH DOCTOR (doctor_id, hire_date, manager_id, Leveldoc) 
AS (
	SELECT doctor_id, hire_date, manager_id, 0 AS Leveldoc 
	FROM Doctors
	WHERE manager_id IS NULL AND  doctor_id IN (SELECT manager_id FROM Doctors)
	UNION ALL 

	SELECT doc1.doctor_id, doc1.hire_date, doc1.manager_id, tc.Leveldoc + 1
	FROM Doctors doc1
	INNER JOIN DOCTOR tc ON doc1.manager_id = tc.doctor_id
	)
  SELECT *  FROM DOCTOR 
  ORDER BY Leveldoc */
 ---------------------------------------------------------------------------
 ---6---
 /*Определить пациентов, которые лечились у врачей всех специальностей */
 /*
 WITH consta as (
 SELECT vis1.patient_id, prof1.profession_id,peop.first_name,peop.last_name, ROW_NUMBER() OVER(PARTITION BY vis1.patient_id, prof1.profession_id ORDER BY prof1.profession_id) as row
 FROM Visit vis1
 INNER JOIN Doctors doc1 ON doc1.doctor_id = vis1.doctor_id 
 INNER JOIN Profession prof1 ON prof1.doctor_id = doc1.doctor_id 
 INNER JOIN Patients pat1 ON vis1.patient_id = pat1.patient_id
 INNER JOIN People peop ON peop.human_id =pat1.patient_id
)
SELECT consta.patient_id, consta.first_name, consta.last_name 
FROM consta
WHERE consta.row = 1  
GROUP BY consta.patient_id, consta.first_name, consta.last_name  
HAVING SUM(profession_id) = (SELECT (COUNT(*) + 2 * MIN(profession_id)) / 2 * COUNT(*) FROM Specialization )   
*/
----------------------------------------------------------------------------------------------------------
---7--- 
/*Вывести пациента, которого перенаправляли несколько раз к другому доктору*/ 
/*
WITH db_perenapravili as (
SELECT v1.visit_id as visit, v1.visit_time as date, v1.redirection_id as redirected, v1.doctor_id, v1.patient_id
FROM Visit v1
INNER JOIN Visit v2 ON v1.redirection_id = v2.visit_id 
WHERE (v1.doctor_id != v2.doctor_id) and (v1.patient_id = v2.patient_id) 
UNION 
SELECT v4.visit_id as visit, v4.visit_time as date, v4.redirection_id as redirected, v4.doctor_id, v4.patient_id
FROM Visit v3
INNER JOIN Visit v4 ON v3.redirection_id = v4.visit_id 
WHERE (v3.doctor_id != v4.doctor_id) and (v3.patient_id = v4.patient_id) 
)

SELECT per.patient_id, COUNT(*) - 1  AS [count of reproduced], peop.first_name, peop.last_name
from db_perenapravili  per 
INNER JOIN People peop ON peop.human_id = per.patient_id 
GROUP  BY patient_id */

--------------------------------------------------------------------------------------------
---8--- 
/*Есть ли врачи, которые приходили в поликлинику, как пациенты и их диагноз(когда был поставлен)*/ 
/*SELECT DISTINCT People.human_id,Visit.visit_id, People.first_name, People.last_name, diagnosis_name, List_status.actual_status_starts 
FROM People 
INNER JOIN Patients ON Patients.patient_id = People.human_id 
INNER JOIN Doctors ON Doctors.doctor_id = People.human_id 
INNER JOIN Visit ON Visit.patient_id = Patients.patient_id
INNER JOIN diagnosis ON diagnosis.visit_id = Visit.visit_id
INNER JOIN List_status ON List_status.visit_id = Visit.visit_id */ 
---------------------------------------------------------------------------------------------------------------------
--9---
/*сколько процентов от всех пациентов болело ОРВИ*/
/*
WITH injured AS (
SELECT DISTINCT patient_id AS bad
FROM Visit vis
INNER JOIN diagnosis d ON d.visit_id = vis.patient_id
WHERE d.diagnosis_name = 'ОРВИ'), 
yt AS (
SELECT  DISTINCT patient_id as pat
FROM Visit), 
first AS( 
SELECT COUNT(*)  as col
FROM injured 
UNION 
SELECT COUNT(*) as col
FROM yt),
sec AS (
SELECT col, ROW_NUMBER() OVER(ORDER BY col ASC) as row
FROM first
),
third as (
SELECT sec1.col as col1 ,sec2.col as col2
FROM sec sec1 
INNER JOIN sec sec2 ON sec1.row + 1 = sec2.row 
) 
SELECT cast((cast(col1 as decimal(10,2)) * 100 / col2 ) as decimal(10,2)) as percents
FROM third 
*/