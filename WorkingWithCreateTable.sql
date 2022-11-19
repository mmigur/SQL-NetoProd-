--===============Just Pain Mayor==========================================================


--База данных: если подключение к облачной базе, то создаёте новую схему с префиксом в --виде фамилии, название должно быть на латинице в нижнем регистре и таблицы создаете --в этой новой схеме, если подключение к локальному серверу, то создаёте новую схему и --в ней создаёте таблицы.

--Спроектируйте базу данных, содержащую три справочника:
--· язык (английский, французский и т. п.);
--· народность (славяне, англосаксы и т. п.);
--· страны (Россия, Германия и т. п.).
--Две таблицы со связями: язык-народность и народность-страна, отношения многие ко многим. Пример таблицы со связями — film_actor.
--Требования к таблицам-справочникам:
--· наличие ограничений первичных ключей.
--· идентификатору сущности должен присваиваться автоинкрементом;
--· наименования сущностей не должны содержать null-значения, не должны допускаться --дубликаты в названиях сущностей.
--Требования к таблицам со связями:
--· наличие ограничений первичных и внешних ключей.

--В качестве ответа на задание пришлите запросы создания таблиц и запросы по --добавлению в каждую таблицу по 5 строк с данными.
 
--СОЗДАНИЕ ТАБЛИЦЫ ЯЗЫКИ
CREATE TABLE "language"(
	language_id serial PRIMARY KEY,
	"language" VARCHAR(256) UNIQUE NOT NULL
);
--ВНЕСЕНИЕ ДАННЫХ В ТАБЛИЦУ ЯЗЫКИ
INSERT INTO "language" ("language")
VALUES 
('English'),
('Russian'),
('French'),
('Deutsch'),
('Japanese');


--СОЗДАНИЕ ТАБЛИЦЫ НАРОДНОСТИ
CREATE TABLE nationality(
	nationality_id serial PRIMARY KEY,
	nationality VARCHAR(256) UNIQUE NOT NULL
);
--ВНЕСЕНИЕ ДАННЫХ В ТАБЛИЦУ НАРОДНОСТИ
INSERT INTO nationality(nationality)
VALUES 
('Slavs'),
('Anglo-Saxons'),
('Ukrainians'),
('Belarusians'),
('Tatars');


--СОЗДАНИЕ ТАБЛИЦЫ СТРАНЫ
CREATE TABLE country(
	country_id serial PRIMARY KEY,
	country VARCHAR(256) UNIQUE NOT NULL
);

--ВНЕСЕНИЕ ДАННЫХ В ТАБЛИЦУ СТРАНЫ
INSERT INTO country(country)
VALUES 
('Russia'), 
('Germany'),
('China'),
('Japan'),
('Ukraine');


--СОЗДАНИЕ ПЕРВОЙ ТАБЛИЦЫ СО СВЯЗЯМИ
CREATE TABLE language_nationality(
	language_id INTEGER,
	nationality_id INTEGER,
	FOREIGN KEY(language_id) REFERENCES "language" (language_id),
	FOREIGN KEY(nationality_id) REFERENCES nationality (nationality_id),
	PRIMARY KEY (language_id, nationality_id)
);
--ВНЕСЕНИЕ ДАННЫХ В ТАБЛИЦУ СО СВЯЗЯМИ
INSERT INTO language_nationality(language_id, nationality_id)
VALUES 
(1,3),
(2,3),
(4,3),
(2,4),
(5,1);


--СОЗДАНИЕ ВТОРОЙ ТАБЛИЦЫ СО СВЯЗЯМИ
CREATE TABLE nationality_country(
	nationality_id INTEGER,
	country_id INTEGER,
	FOREIGN KEY(nationality_id) REFERENCES nationality (nationality_id),
	FOREIGN KEY(country_id) REFERENCES country (country_id),
	PRIMARY KEY (nationality_id, country_id)
);
--ВНЕСЕНИЕ ДАННЫХ В ТАБЛИЦУ СО СВЯЗЯМИ
INSERT INTO nationality_country(nationality_id, country_id)
VALUES
(1,4),
(2,4),
(5,1),
(2,3),
(5,4);


--Создайте новую таблицу film_new со следующими полями:
--·   	film_name - название фильма - тип данных varchar(255) и ограничение not null
--·   	film_year - год выпуска фильма - тип данных integer, условие, что значение должно быть больше 0
--·   	film_rental_rate - стоимость аренды фильма - тип данных numeric(4,2), значение по умолчанию 0.99
--·   	film_duration - длительность фильма в минутах - тип данных integer, ограничение not null и условие, что значение должно быть больше 0
--Если работаете в облачной базе, то перед названием таблицы задайте наименование вашей схемы.
CREATE TABLE film_new(
	film_name VARCHAR(256) NOT NULL,
	film_year INTEGER CHECK (film_year > 0),
	film_rental_rate NUMERIC(4,2) DEFAULT 0.99,
	film_duration INTEGER NOT NULL CHECK (film_duration > 0)
);


--Заполните таблицу film_new данными с помощью SQL-запроса, где колонкам соответствуют массивы данных:
--·       film_name - array['The Shawshank Redemption', 'The Green Mile', 'Back to the Future', 'Forrest Gump', 'Schindlers List']
--·       film_year - array[1994, 1999, 1985, 1994, 1993]
--·       film_rental_rate - array[2.99, 0.99, 1.99, 2.99, 3.99]
--·   	  film_duration - array[142, 189, 116, 142, 195]
INSERT INTO film_new(film_name, film_year, film_rental_rate, film_duration)
VALUES 
('The Shawshank Redemption', 1994, 2.99, 142),
('The Green Mile', 1999, 0.99, 189),
('Back to the Future', 1985, 1.99, 116),
('Forrest Gump', 1994, 2.99, 142),
('Schindlers List', 1993, 3.99, 195);
--Вариант на заметку
--insert into table (column_name_1, column_name_2)
--select unnest(array[‘name1’, ‘name2’, ‘name3’]), unnest(array[1916, 1837, 1840])


--Обновите стоимость аренды фильмов в таблице film_new с учетом информации, 
--что стоимость аренды всех фильмов поднялась на 1.41
UPDATE film_new
SET film_rental_rate = film_rental_rate + 1.41


--Фильм с названием "Back to the Future" был снят с аренды, 
--удалите строку с этим фильмом из таблицы film_new
DELETE 
FROM film_new 
WHERE film_name = 'Back to the Future'


--Добавьте в таблицу film_new запись о любом другом новом фильме
INSERT INTO film_new(film_name, film_year, film_rental_rate, film_duration)
VALUES ('We are the Millers', 2013, 5.99, 184)


--Напишите SQL-запрос, который выведет все колонки из таблицы film_new, 
--а также новую вычисляемую колонку "длительность фильма в часах", округлённую до десятых
ALTER TABLE film_new ADD column time_in_hours INTEGER
UPDATE film_new
SET time_in_hours = film_duration / 60
SELECT "column_name" FROM information_schema.columns 
WHERE table_catalog = 'homework' AND table_schema = 'public' AND table_name = 'film_new';


--Удалите таблицу film_new
DROP TABLE film_new;