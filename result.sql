/*вывести всех пилотов, которые летали в качестве 2 пилота в шереметьево 3 раза и больше в августе этого года*/
with pilotes_second_gear as ( 
	select second_pilot_id from Рейсы 
    where destination = "Шереметьево" and extract(year from flight_dt) = year(curdate()) and month(flight_dt) = 8
    group by second_pilot_id   
    having count(second_pilot_id) > 3
)  

select * from Пилоты 
inner join pilotes_second_gear 
on pilotes_second_gear.pilot_id = Пилоты.pilot_id  

/*Вывести пилотов старше 45 лет, совершавшие 
полеты на самолетах с количеством пассажирова больше 30*/ 

select distinct * from Пилоты
inner join Рейсы
on Пилоты.pilot_id = Рейсы.first_pilot_id  
inner join Самолеты 
on Самолеты.plane_id = Рейсы.plane_id  
where cargo_flg = 0 and capacity > 30 and age > 45 

union  

select distinct * from Пилоты  
inner join Рейсы 
on Пилоты.pilot_id = Рейсы.second_pilot_id 
inner join Самолеты 
on Самолеты.plane_id = Рейсы.plane_id 
where cargo_flg = 0 and capacity > 30 and age > 45 

/*топ-10 главных пилотов по числу грузовых перевозок*/
with t1 as (
  select 
    plane_id 
  from
    Самолеты 
  where 
    cargo_flg = 1
), t2 as (
  select 
    first_pilot_id as pil_id
  from
    Рейсы
  where 
    year(flight_dt) = year(curdate())
  and 
    plane_id in (select t1.plane_id from t1)
), t3 as (
  select
      pil_id
    , count(*) as flight_count 
  from
    t2
  group by 
    1
  order by 
    flight_count desc 
  limit
    10
)

select 
    Пилоты.pilot_id
  , Пилоты.name
  , Пилоты.age
  , Пилоты.rank
  , Пилоты.education_level
  , t3.flight_count
from 
  Пилоты
join
  t3
on 
  Пилоты.pilot_id = t3.pil_id
order by  
	flight_count desc




