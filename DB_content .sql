/*Создание таблиц*/
CREATE TABLE public.persons (
    pers_id SERIAL primary KEY,
    fio varchar(255),
    login varchar(255) UNIQUE not null ,
    password varchar(255) not null,
    role  varchar(255) not null,
    pers_info_id integer);

COMMENT ON COLUMN persons.pers_id is 'ID персонажа';
COMMENT ON COLUMN persons.fio is 'ФИО персонажа';
COMMENT ON COLUMN persons.login is 'Уникальный логин персонажа';
COMMENT ON COLUMN persons.password is'Незащищенный пароль персонажа';
COMMENT ON COLUMN persons.role is 'Роль в приложении (admin/user)';
COMMENT ON column persons.pers_info_id is 'Ссылка на персоанльную информацию (personal_info)';

insert into public.persons (fio,login,password,role,pers_info_id) values
('Корнеев.В.С.', 'korneevvs', '1337','admin',1),
('Корнеев.C.С.', 'korneevss', '1337','admin',2),
('Ролевой', 'rolevoi', '1337','user',3);

select * from persons

CREATE TABLE public.personal_info (
    pers_info_id SERIAL primary key,
	pers_id integer NOT NULL,
    sex varchar(255),
    adress varchar(255),
    email varchar(255),
    phone_number varchar(255))
	kash integer;

COMMENT ON column personal_info.pers_info_id is 'ID персональной инфморации';
COMMENT ON COLUMN personal_info.pers_id is 'ID персонажа (ссылка на persons)';
COMMENT ON COLUMN personal_info.sex is 'Пол персонажа';
COMMENT ON COLUMN personal_info.adress is 'Место жительства персонажа';
COMMENT ON COLUMN personal_info.email is'Email персонажа';
COMMENT ON COLUMN personal_info.phone_number is 'Номер телефона персонажа';
COMMENT ON COLUMN personal_info.kash is 'Количество денег персонажа';

insert into public.personal_info (pers_id,sex,adress,email,phone_number,kash) values
(1,'M','vrn','kvs4848@yandex.ru','89112868121',10000),
(2,'M','hlv', null,'89052860948',5000),
(3,'W',null, null,null,0)

select * from personal_info;

/*Создание ограничений*/

alter table persons add constraint persons_fk FOREIGN key (pers_info_id) references personal_info(pers_info_id);

alter table personal_info add constraint pinfo_fk FOREIGN key (pers_id) references persons(pers_id)

ALTER TABLE public.persons ALTER COLUMN "role" SET DEFAULT 'user'; --Любой добавляемый пользоваель создаётся юзером, админом его назначает другой админ.

/*Настройки логирования*/

ALTER DATABASE postgres set log_destination = csvlog; -- Запись логов в формате CSV, что удобно для программной обработки и в целом для чтения

SELECT pg_current_logfile(); --Результатом запроса будет путь и название лог-файла после пути вида "C:\Program Files\PostgreSQL\{version}\data\"

/*Работа с вьюхами(представлениями)*/
CREATE OR REPLACE VIEW public.last3persons as
(select * from persons
order by pers_id desc
limit 3);

grant select on last3persons to postgres; --Даёт доступ к вьюхе (только на чтение)

select * from last3persons;

/*Создание и вызов процедур*/

-- Создаём процедуру увеличения значения в поле Kash табилицы personal_info
-- Процедура 2 параметрами id (кому увелчичивать) и bump_value(на сколько увеличивать)
CREATE OR REPLACE PROCEDURE bump_for_person(id integer, bump_value integer)
LANGUAGE plpgsql AS  
$$  
BEGIN  
    update personal_info set kash = kash + bump_value where pers_id = id;  
    COMMIT;
END;  
$$  

--Вызов в ручную процедуры
call bump_for_person(1,10000);


-- Получаем список созданных процедур, а также их параметров и исполняемых ими скриптов.
select
	namespace.nspname,
	procedure.proname,
	procedure. proargnames,
	procedure.prosrc
from
	pg_catalog.pg_namespace namespace
join pg_catalog.pg_proc procedure on
	procedure.pronamespace = namespace.oid
where
	procedure.prokind = 'procedure'
	and namespace.nspname = 'public'