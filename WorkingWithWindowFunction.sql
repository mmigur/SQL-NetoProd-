--===============Just Pain Mayor==========================================================


--ЗАДАНИЕ №1
--Сделайте запрос к таблице payment и с помощью оконных функций добавьте вычисляемые колонки согласно условиям:
--Пронумеруйте все платежи от 1 до N по дате
SELECT 
	p.customer_id,
	p.payment_id,
	p.payment_date,
	ROW_NUMBER() OVER(ORDER BY p.payment_date)
FROM payment p;

--Пронумеруйте платежи для каждого покупателя, сортировка платежей должна быть по дате
SELECT 
	p.customer_id,
	p.payment_id,
	p.payment_date,
	ROW_NUMBER() OVER(PARTITION BY p.customer_id ORDER BY p.payment_date)
FROM payment p;

--Посчитайте нарастающим итогом сумму всех платежей для каждого покупателя, сортировка должна 
--быть сперва по дате платежа, а затем по сумме платежа от наименьшей к большей
SELECT 
	p.customer_id,
	p.payment_id,
	p.payment_date,
	SUM(p.amount) OVER(PARTITION BY p.customer_id ORDER BY p.payment_date, p.amount ASC) AS "column_3"
FROM payment p

--Пронумеруйте платежи для каждого покупателя по стоимости платежа от наибольших к меньшим 
--так, чтобы платежи с одинаковым значением имели одинаковое значение номера.
SELECT 
	p.customer_id,
	p.payment_id,
	p.payment_date,
	RANK() OVER(PARTITION BY p.customer_id ORDER BY p.amount DESC)
FROM payment p


--С помощью оконной функции выведите для каждого покупателя стоимость платежа и стоимость 
--платежа из предыдущей строки со значением по умолчанию 0.0 с сортировкой по дате.
SELECT 
	p.customer_id,
	p.payment_id,
	p.payment_date,
	p.amount,
	LAG(p.amount, 1, 0.00) OVER(
		PARTITION BY p.customer_id ORDER BY p.payment_date
	) AS "last_amount"
FROM payment p;


--С помощью оконной функции определите, на сколько каждый следующий платеж покупателя больше или меньше текущего.
SELECT
	p.customer_id,
	p.payment_id,
	p.payment_date,
	p.amount,
	p.amount - LEAD(p.amount, 1) OVER(PARTITION BY p.customer_id ORDER BY p.payment_date)
FROM payment p;


--С помощью оконной функции для каждого покупателя выведите данные о его последней оплате аренды.
SELECT 
	t.customer_id,
	t.payment_id,
	t.payment_date,
	t.amount
FROM (
	SELECT 
		p.customer_id,
		p.payment_id,
		p.payment_date,
		p.amount,
		row_number() OVER(PARTITION BY p.customer_id ORDER BY p.payment_date DESC)
	FROM payment p 
	) AS t
WHERE row_number = 1;


--С помощью оконной функции выведите для каждого сотрудника сумму продаж за август 2005 года 
--с нарастающим итогом по каждому сотруднику и по каждой дате продажи (без учёта времени) 
--с сортировкой по дате.
WITH cte AS(
	SELECT 
		s.staff_id, 
		p.payment_date::DATE,
		sum(p.amount) AS "amount_sum_everyday"
	FROM staff s
	LEFT JOIN payment p USING(staff_id)
	WHERE p.payment_date::DATE >= '2005-08-01' AND p.payment_date::DATE <= '2005-08-31'
	GROUP BY s.staff_id, p.payment_date::DATE
	ORDER BY s.staff_id, p.payment_date::DATE
)
SELECT
	cte.staff_id,
	cte.payment_date,
	cte.amount_sum_everyday,
	SUM(cte.amount_sum_everyday) OVER(
		PARTITION BY cte.staff_id 
		ORDER BY cte.payment_date::DATE
		) AS "sum"
FROM cte


--20 августа 2005 года в магазинах проходила акция: покупатель каждого сотого платежа получал
--дополнительную скидку на следующую аренду. С помощью оконной функции выведите всех покупателей,
--которые в день проведения акции получили скидку
SELECT
	t.customer_id,
	t.payment_date,
	t.payment_number
FROM
(
	SELECT 
		p.customer_id,
		p.payment_date,
		ROW_NUMBER() OVER(ORDER BY p.payment_date) AS "payment_number"
	FROM payment p 
	WHERE p.payment_date::DATE = '2005-08-20'
) AS t
WHERE t.payment_number % 100 = 0;
--WHERE mod(t.payment_number, 100) = 0