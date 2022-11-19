--===============Just Pain Mayor==========================================================


--Выведите для каждого покупателя его адрес проживания, 
--город и страну проживания.
SELECT 
CONCAT(c.last_name  , ' ', c.first_name) AS CustomerName,
	a.address,
	c2.city,
	c3.country
FROM customer c 
LEFT JOIN address a USING(address_id)
LEFT JOIN city c2 USING(city_id)
LEFT JOIN country c3 USING(country_id)


--С помощью SQL-запроса посчитайте для каждого магазина количество его покупателей.
SELECT 
	s.store_id,
	COUNT(c.customer_id)
FROM store s 
LEFT JOIN customer c USING(store_id)
GROUP BY s.store_id

--Доработайте запрос и выведите только те магазины, 
--у которых количество покупателей больше 300-от.
--Для решения используйте фильтрацию по сгруппированным строкам 
--с использованием функции агрегации.
SELECT 
	s.store_id,
	COUNT(c.customer_id)
FROM store s 
LEFT JOIN customer c USING(store_id)
GROUP BY s.store_id
HAVING COUNT(c.customer_id) >= 300

-- Доработайте запрос, добавив в него информацию о городе магазина, 
--а также фамилию и имя продавца, который работает в этом магазине.
SELECT 
	s.store_id AS "ID Магазина",
	COUNT(c.customer_id) AS "Количество сотрудников",
	c2.city AS "Город",
	CONCAT(s2.last_name, ' ', s2.first_name) AS "Имя сотрудника"
FROM store s 
LEFT JOIN customer c ON s.store_id = c.store_id
LEFT JOIN address a ON s.address_id = a.address_id
LEFT JOIN city c2 ON a.city_id = c2.city_id
LEFT JOIN staff s2 ON s.manager_staff_id = s2.staff_id
GROUP BY s.store_id, c2.city_id, s2.staff_id
HAVING COUNT(c.customer_id) >= 300


--Выведите ТОП-5 покупателей, 
--которые взяли в аренду за всё время наибольшее количество фильмов
SELECT 
	CONCAT(c.last_name, ' ', c.first_name) AS "Фамилия и имя покупателя",
	COUNT(r.inventory_id) AS "Количество фильмов"
FROM customer c 
LEFT JOIN rental r ON c.customer_id = r.customer_id 
GROUP BY r.customer_id, CONCAT(c.last_name, ' ', c.first_name) --GROUP BY c.customer_id
ORDER BY COUNT(r.inventory_id) DESC LIMIT 5;


--Посчитайте для каждого покупателя 4 аналитических показателя:
--  1. количество фильмов, которые он взял в аренду
--  2. общую стоимость платежей за аренду всех фильмов (значение округлите до целого числа)
--  3. минимальное значение платежа за аренду фильма
--  4. максимальное значение платежа за аренду фильма
SELECT 
	CONCAT(c.last_name, ' ', c.first_name) AS "Фамилия и имя покупателя",
	COUNT(r.inventory_id) AS "Количество фильмов",
	ROUND(SUM(p.amount)) AS "Общая стоимость платежей",
	MIN(p.amount) AS "Минимальная стоимость платежа",
	MAX(p.amount) AS "Максимальная стоимость платежа"
FROM customer c 
LEFT JOIN rental r ON c.customer_id = r.customer_id
LEFT JOIN payment p  ON r.rental_id = p.rental_id 
GROUP BY r.customer_id, CONCAT(c.last_name, ' ', c.first_name) -- GROUP BY c.customer_id


--Используя данные из таблицы городов составьте одним запросом всевозможные пары городов таким образом,
 --чтобы в результате не было пар с одинаковыми названиями городов. 
 --Для решения необходимо использовать декартово произведение.
SELECT 
	c.city, 
	c2.city 
FROM city c 
CROSS JOIN city c2
WHERE c.city <> c2.city --исправил!!!


--Используя данные из таблицы rental о дате выдачи фильма в аренду (поле rental_date)
--и дате возврата фильма (поле return_date), 
--вычислите для каждого покупателя среднее количество дней, за которые покупатель возвращает фильмы.
SELECT 
	r.customer_id AS "ID покупателя",
	TO_CHAR(AVG(r.return_date::date - r.rental_date::date), '0.00') AS "Среднее количество дней на возврат"
FROM rental r 
GROUP BY r.customer_id
ORDER BY r.customer_id


--Посчитайте для каждого фильма сколько раз его брали в аренду и значение общей стоимости аренды фильма за всё время.
SELECT 
	f.title AS "Название фильма",
	f.rating AS "Рейтинг",
	c.name AS "Жанр",
	f.release_year AS "Год выпуска",
	l."name" AS "Язык",
	COUNT(r.inventory_id) AS "Количество аренд",
	SUM(p.amount) AS "Общая стоимость аренды"
FROM film f 
LEFT JOIN film_category fc ON fc.film_id  = f.film_id
LEFT JOIN category c ON fc.category_id = c.category_id
LEFT JOIN  "language" l  ON f.language_id = l.language_id
LEFT JOIN inventory i ON f.film_id = i.film_id 
LEFT JOIN rental r ON i.inventory_id = r.inventory_id
LEFT JOIN payment p ON r.rental_id = p.rental_id
GROUP BY f.film_id , c.name , l."name"
ORDER BY f.title 


--Доработайте запрос из предыдущего задания и выведите с помощью запроса фильмы, которые ни разу не брали в аренду.
SELECT 
	f.title AS "Название фильма",
	f.rating AS "Рейтинг",
	c.name AS "Жанр",
	f.release_year AS "Год выпуска",
	l."name" AS "Язык",
	COUNT(r.inventory_id) AS "Количество аренд",
	SUM(p.amount) AS "Общая стоимость аренды"
FROM film f 
LEFT JOIN film_category fc ON fc.film_id  = f.film_id
LEFT JOIN category c ON fc.category_id = c.category_id
LEFT JOIN  "language" l  ON f.language_id = l.language_id
LEFT JOIN inventory i ON f.film_id = i.film_id 
LEFT JOIN rental r ON i.inventory_id = r.inventory_id
LEFT JOIN payment p ON r.rental_id = p.rental_id
GROUP BY f.film_id , c.name , l."name"
HAVING COUNT(r.inventory_id) = 0
ORDER BY f.title 


--Посчитайте количество продаж, выполненных каждым продавцом. Добавьте вычисляемую колонку "Премия".
--Если количество продаж превышает 7300, то значение в колонке будет "Да", иначе должно быть значение "Нет".
SELECT 
	s.staff_id,
	COUNT(p.staff_id) AS "Количество продаж",
	CASE 
		WHEN count(p.staff_id) > 7300 THEN 'Да'
		ELSE 'Нет'
	END AS "Премия"
FROM staff s 
LEFT JOIN payment p ON s.staff_id = p.staff_id 
GROUP BY s.staff_id