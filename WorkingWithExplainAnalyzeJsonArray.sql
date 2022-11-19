--===============Just Pain Mayor==========================================================


--Напишите SQL-запрос, который выводит всю информацию о фильмах 
--со специальным атрибутом "Behind the Scenes".
SELECT 
  f.film_id,
  f.title,
  f.special_features
FROM film f
WHERE (f.special_features) && (ARRAY['Behind the Scenes'])


--Напишите еще 2 варианта поиска фильмов с атрибутом "Behind the Scenes",
--используя другие функции или операторы языка SQL для поиска значения в массиве.
SELECT 
  f.film_id,
  f.title,
  f.special_features
FROM film f
WHERE (f.special_features) @> (ARRAY['Behind the Scenes'])

SELECT
  f.film_id,
  f.title,
  f.special_features
FROM film f
WHERE 'Behind the Scenes' = ANY(f.special_features)


--Для каждого покупателя посчитайте сколько он брал в аренду фильмов 
--со специальным атрибутом "Behind the Scenes.
--Обязательное условие для выполнения задания: используйте запрос из задания 1, 
--помещенный в CTE. CTE необходимо использовать для решения задания.
WITH behind_the_scenes_film AS (
	SELECT 
	  f.film_id,
	  f.title,
	  f.special_features
	FROM film f
	WHERE (f.special_features) && (ARRAY['Behind the Scenes'])
)
SELECT
  c.customer_id,
  COUNT(bsf.film_id) AS "film_count"
FROM customer c
LEFT JOIN rental r ON c.customer_id = r.customer_id
LEFT JOIN inventory i ON r.inventory_id = i.inventory_id
LEFT JOIN behind_the_scenes_film bsf ON i.film_id = bsf.film_id 
GROUP BY c.customer_id 
ORDER BY c.customer_id


--Для каждого покупателя посчитайте сколько он брал в аренду фильмов
-- со специальным атрибутом "Behind the Scenes".
--Обязательное условие для выполнения задания: используйте запрос из задания 1,
--помещенный в подзапрос, который необходимо использовать для решения задания.
SELECT 
  c.customer_id,
  COUNT(bsf.film_id) AS "film_count"
FROM customer c
LEFT JOIN rental r ON c.customer_id = r.customer_id
LEFT JOIN inventory i ON r.inventory_id = i.inventory_id
LEFT JOIN (
	SELECT 
	  f.film_id,
	  f.title,
	  f.special_features
	FROM film f
	WHERE (f.special_features) && (ARRAY['Behind the Scenes'])
) AS bsf ON i.film_id = bsf.film_id
GROUP BY c.customer_id 
ORDER BY c.customer_id


--Создайте материализованное представление с запросом из предыдущего задания
--и напишите запрос для обновления материализованного представления
CREATE MATERIALIZED VIEW mv as(
  select 
    c.customer_id,
    COUNT(bsf.film_id) AS "film_count"
  FROM customer c
  LEFT JOIN rental r ON c.customer_id = r.customer_id
  LEFT JOIN inventory i ON r.inventory_id = i.inventory_id
  LEFT JOIN (
    SELECT 
      f.film_id,
      f.title,
      f.special_features
    FROM film f
    WHERE (f.special_features) && (ARRAY['Behind the Scenes'])
  ) as bsf on i.film_id = bsf.film_id
  GROUP BY c.customer_id 
  ORDER BY c.customer_id
)

REFRESH MATERIALIZED VIEW 
mv;


--Используя оконную функцию выведите для каждого сотрудника
--сведения о самой первой продаже этого сотрудника.
WITH cte AS (
SELECT 
  p.staff_id,
  f.film_id,
  f.title,
  p.amount,
  p.payment_date,
  c.first_name,
  c.last_name,
  ROW_NUMBER() OVER(PARTITION BY p.staff_id ORDER BY p.payment_date) AS "number_payment"
FROM payment p
LEFT JOIN customer c ON p.customer_id = c.customer_id
LEFT JOIN rental r ON p.rental_id = r.rental_id 
LEFT JOIN inventory i ON r.inventory_id = i.inventory_id
LEFT JOIN film f ON i.film_id = f.film_id
)
SELECT 
  cte.staff_id,
  cte.film_id,
  cte.title,
  cte.amount,
  cte.payment_date,
  cte.first_name,
  cte.last_name
FROM cte
WHERE cte.number_payment = 1