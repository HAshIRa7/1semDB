--перенапрвляем пациента к другому врачу(начальнику этого же врача), если у него ухудшилось состояние --
create trigger test2 
on List_status --изменяется таблица текущее состояние пациента -> делаем триггер, такой, что при изменение состяония пациента, изменяется врач, который должен будет его лечить.
AFTER update --изменения происходят после изменения 
as -- собственно тело нашего триггера      
begin                                    
DECLARE @Mytable table( --Далее заведем таблицу, в которой будем хранить старое и новое значение переменных статуса состояния пациента
		visit int not null,
		old_status int, 
		new_status int,
		id int );
DECLARE @Doc table (
doctor int not null, 
manager int not null
);
select doctor_id as doctor, manager_id as manager into #Doc from Doctors
SELECT deleted.visit_id as visit, deleted.actual_status_number as old_status, inserted.actual_status_number as new_status, row_number() over (order by(select null)) as id into #Mytable from deleted 
inner join inserted on deleted.status_id = inserted.visit_id
declare @s int
set @s = (select count(*) from #Mytable) 
declare @i int
set @i = 1 
while(@i <= @s) 
	begin
	declare @first int, @second int
	set @first = (select old_status from @Mytable where  @i = id)
	set @second = (select new_status from @Mytable where  @i = id)
	if(@second > @first) 
	begin
		UPDATE Visit 
		SET doctor_id = (select doctor_id from podchineny  where manager_id = NULL and doctor_id in (select manager_id from podchineny))
		FROM Visit INNER JOIN List_status ON List_status.visit_id = Visit.visit_id
	end
	set @i = @i + 1
	end 
end
drop trigger test2
select * from sys.triggers 