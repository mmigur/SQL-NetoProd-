--===================Зачетная работа по курсу SQL=================
--===================Выполнил: Мигур Максим=======================

--ЗАДАНИЕ №1
--Какие самолеты имеют более 50 посадочных мест?
SELECT
a.aircraft_code,
count(s.seat_no) AS "count_seats"
FROM aircrafts a
LEFT JOIN seats s ON a.aircraft_code = s.aircraft_code 
GROUP BY a.aircraft_code
HAVING count(s.seat_no) > 50


--ЗАДАНИЕ №2
--В каких аэропортах есть рейсы,
--в рамках которых можно добраться бизнес - 
--классом дешевле, чем эконом - классом?
--Обязательные требования: CTE
WITH max_economy_amount AS (
	SELECT 
	tf.flight_id,
	MAX(tf.amount) AS "max_economy_price"
	FROM ticket_flights tf 
	WHERE tf.fare_conditions = 'Economy'
	GROUP BY tf.flight_id
),
min_business_amount AS (
	SELECT 
	tf.flight_id,
	MIN(tf.amount) AS "min_business_price"
	FROM ticket_flights tf 
	WHERE tf.fare_conditions = 'Business'
	GROUP BY tf.flight_id
)
SELECT
	a.airport_name,
	t.flight_id,
	t.min_business_price,
	t.max_economy_price
FROM (
	SELECT
		min_business_amount.flight_id AS "flight_id",
		min_business_amount.min_business_price,
		max_economy_amount.max_economy_price
	FROM min_business_amount
	LEFT JOIN max_economy_amount USING(flight_id)
) AS t
LEFT JOIN flights f USING(flight_id)
LEFT JOIN airports a ON f.arrival_airport = a.airport_code
WHERE t.min_business_price < t.max_economy_price


--ЗАДАНИЕ №3
--Есть ли самолеты, не имеющие бизнес - класса?
--Обязательные требования: array_agg 
SELECT
t.aircraft_code
FROM(
	SELECT 
	a.aircraft_code,
	ARRAY_AGG(s.fare_conditions) AS "array_type_class"
	FROM aircrafts a 
	LEFT JOIN seats s ON a.aircraft_code = s.aircraft_code
	GROUP BY a.aircraft_code) AS t
WHERE NOT ('Business' = ANY(t.array_type_class))


--ЗАДАНИЕ №5
--Найдите процентное соотношение перелетов по маршрутам от общего количества перелетов. 
--Выведите в результат названия аэропортов и процентное отношение.
--Обязательные требования: Оконная функция, оператор Round
SELECT
a.airport_name,
percentage_flights.percentage_of_the_total
FROM (
SELECT
	f.departure_airport, 
	f.arrival_airport,
	ROUND((COUNT(*) OVER(PARTITION BY f.departure_airport, f.arrival_airport))::NUMERIC / 
	(
		SELECT 
			COUNT(f2.flight_id)::NUMERIC 
		FROM flights f2) * 100, 2) AS "percentage_of_the_total"
FROM flights f) AS percentage_flights
LEFT JOIN airports a ON percentage_flights.arrival_airport = a.airport_code


--ЗАДАНИЕ №6
--Выведите количество пассажиров по каждому коду сотового оператора, 
--если учесть, что код оператора - это три символа после +7
SELECT 
operators.operator_code as "Код оператора",
COUNT(operators.operator_code) as "Количество пассажиров по коду оператора"
FROM (
    SELECT 
    SUBSTRING(t.contact_data ->> 'phone' FROM 3 FOR 3) AS "operator_code"
    FROM tickets t
) AS operators
GROUP BY operators.operator_code


--ЗАДАНИЕ №7
--Между какими городами не существует перелетов?
--Обязательные требования: Декартово произведение, оператор EXCEPT 
--Всевозможные перелеты между городами 
SELECT
    a.city, 
    a2.city 
FROM airports a 
CROSS JOIN airports a2
WHERE a.city <> a2.city
--Города между которыми, есть перелеты
EXCEPT
SELECT 
    a.city,
    a2.city
FROM flights f
LEFT JOIN airports a ON f.departure_airport = a.airport_code
LEFT JOIN airports a2 ON f.arrival_airport = a2.airport_code


--ЗАДАНИЕ №8
--Классифицируйте финансовые обороты (сумма стоимости билетов) по маршрутам:
--До 50 млн - low
--От 50 млн включительно до 150 млн - middle
--От 150 млн включительно - high
--Выведите в результат количество маршрутов в каждом классе.
SELECT 
t2.category_sum,
COUNT(*) AS "Количество маршрутов в каждом классе"
FROM (
	SELECT
		t.departure_airport,
		t.arrival_airport,
		CASE
			WHEN SUM(tf.amount) < 50000000 THEN 'low'
			WHEN (SUM(tf.amount) >= 50000000) AND (SUM(tf.amount) <= 150000000) THEN 'middle'
			WHEN SUM(tf.amount) > 150000000 THEN 'hign'
		END AS "category_sum"
	FROM (
		SELECT 
		f.departure_airport,
		f.arrival_airport,
		f.flight_id 
		FROM flights f 
		GROUP BY f.departure_airport, f.arrival_airport, f.flight_id 
		ORDER BY f.departure_airport, f.arrival_airport
	) AS t 
	RIGHT JOIN ticket_flights tf USING(flight_id)
	GROUP BY t.departure_airport, t.arrival_airport
	ORDER BY t.departure_airport, t.arrival_airport
) AS t2
GROUP BY t2.category_sum

--ЗАДАНИЕ №9
--Выведите пары городов между которыми расстояние более 5000 км
--Обязательные требования: Оператор RADIANS или использование sind/cosd
SELECT
shortest_distance_table.city_a,
shortest_distance_table.city_b,
shortest_distance_table.shortest_distance * 6371 AS "distance"
FROM(
	SELECT 
		a.city AS "city_a",
		a2.city AS "city_b",
		ACOS(
		SIN(a.latitude) * SIN(a2.latitude) 
		+ COS(a.latitude) * COS(a2.latitude) 
		* COS(a.longitude - a2.longitude)) AS "shortest_distance"
	FROM airports a 
	CROSS JOIN airports a2 
	WHERE a.city <> a2.city
) AS shortest_distance_table
WHERE shortest_distance_table.shortest_distance * 6371 > 5000