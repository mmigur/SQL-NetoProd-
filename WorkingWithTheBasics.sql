--===============Just Pain Mayor=========================================================

--Выведите уникальные названия городов из таблицы городов.
SELECT 
    DISTINCT city 
FROM city;


--Доработайте запрос из предыдущего задания, чтобы запрос выводил только те города,
--названия которых начинаются на “L” и заканчиваются на “a”, и названия не содержат пробелов.
SELECT 
    DISTINCT city 
FROM city
WHERE city LIKE 'L%a' AND city NOT LIKE '% %';


--Получите из таблицы платежей за прокат фильмов информацию по платежам, которые выполнялись 
--в промежуток с 17 июня 2005 года по 19 июня 2005 года включительно, 
--и стоимость которых превышает 1.00.
--Платежи нужно отсортировать по дате платежа
SELECT 
    * 
FROM payment
WHERE payment_date BETWEEN '2005-06-17 00:00:00.000' AND '2005-06-20 00:00:00.000' 
    AND amount > 1
ORDER BY payment_date;


-- Выведите информацию о 10-ти последних платежах за прокат фильмов.
SELECT 
    payment_id, 
    payment_date, 
    amount 
FROM payment
ORDER BY payment_date DESC LIMIT 10;


--Выведите следующую информацию по покупателям:
--  1. Фамилия и имя (в одной колонке через пробел)
--  2. Электронная почта
--  3. Длину значения поля email
--  4. Дату последнего обновления записи о покупателе (без времени)
--Каждой колонке задайте наименование на русском языке.
SELECT 
    CONCAT(first_name,' ',last_name) AS "Имя Фамилия",
    email AS "Электронная почта",
    character_length(email) AS "Длина email",
    last_update::date  AS "Дата"
FROM customer;


--Выведите одним запросом только активных покупателей, имена которых KELLY или WILLIE.
--Все буквы в фамилии и имени из верхнего регистра должны быть переведены в нижний регистр.
SELECT
    LOWER(last_name) AS last_name, 
    LOWER(first_name) AS first_name, 
    active 
FROM customer
WHERE (first_name =  'KELLY' OR 
    first_name = 'WILLIE') AND 
    active = 1;


--Выведите одним запросом информацию о фильмах, у которых рейтинг "R" 
--и стоимость аренды указана от 0.00 до 3.00 включительно, 
--а также фильмы c рейтингом "PG-13" и стоимостью аренды больше или равной 4.00.
SELECT 
    film_id, 
    title, 
    description, 
    rating, 
    rental_rate  
FROM film
WHERE rating = 'R' AND rental_rate BETWEEN 0 AND 3.1 
    OR (rating = 'PG-13' AND rental_rate  >= 4);


--Получите информацию о трёх фильмах с самым длинным описанием фильма.
SELECT 
    film_id, 
    title, 
    description 
FROM film 
ORDER BY character_length(description) DESC LIMIT 3; 


-- Выведите Email каждого покупателя, разделив значение Email на 2 отдельных колонки:
--в первой колонке должно быть значение, указанное до @, 
--во второй колонке должно быть значение, указанное после @.
SELECT 
    customer_id, 
    email, 
    split_part(email, '@', 1)  AS "Email before @",
    split_part(email, '@', 2)  AS "Email after @"
FROM customer;


--Доработайте запрос из предыдущего задания, скорректируйте значения в новых колонках: 
--первая буква должна быть заглавной, остальные строчными.
SELECT 
    customer_id, 
    email, 
    CONCAT(UPPER(SUBSTRING(SPLIT_PART(email, '@', 1), 1, 1)),
    LOWER(SUBSTRING(SPLIT_PART(email, '@', 1),2))) AS "Email before @",
    CONCAT(UPPER(SUBSTRING(SPLIT_PART(email, '@', 2), 1, 1)),
    LOWER(SUBSTRING(split_part(email, '@', 2),2))) AS "Email after @"
FROM customer;