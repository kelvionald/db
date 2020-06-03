use lab5;

-- 1. Добавить внешние ключи.
  
ALTER TABLE dealer ADD FOREIGN KEY (id_company) REFERENCES company (id_company);
ALTER TABLE production ADD FOREIGN KEY (id_company) REFERENCES company (id_company);
ALTER TABLE production ADD FOREIGN KEY (id_medicine) REFERENCES medicine (id_medicine);
ALTER TABLE [order] ADD FOREIGN KEY (id_dealer) REFERENCES dealer (id_dealer);
ALTER TABLE [order] ADD FOREIGN KEY (id_production) REFERENCES production (id_production);
ALTER TABLE [order] ADD FOREIGN KEY (id_pharmacy) REFERENCES pharmacy (id_pharmacy);


-- 2. Выдать информацию по всем заказам лекарства “Кордерон” компании “Аргус” с 
-- указанием названий аптек, дат, объема заказов

SELECT ph.name AS pharmacy_name, o.date, o.quantity
FROM [order] AS o
LEFT JOIN production pr ON pr.id_production = o.id_production
LEFT JOIN company c ON c.id_company = pr.id_company
LEFT JOIN medicine m ON m.id_medicine = pr.id_medicine
LEFT JOIN pharmacy ph ON ph.id_pharmacy = o.id_pharmacy
WHERE
	m.name = 'Кордерон' AND
	c.name = 'Аргус'


-- 3. Дать список лекарств компании “Фарма”, на которые не были сделаны заказы
-- до 25 января.

SELECT m.name 
FROM medicine AS m
LEFT JOIN production AS pr ON pr.id_medicine = m.id_medicine
LEFT JOIN company AS c ON c.id_company = pr.id_company
LEFT JOIN [order] AS o ON o.id_production = pr.id_production
WHERE c.name = 'Фарма' AND pr.id_production NOT IN (
	SELECT o.id_production 
	FROM [order] AS o
	WHERE o.date < '25-01-2019'
)
GROUP BY m.name


-- 4. Дать минимальный и максимальный баллы лекарств каждой фирмы, которая
-- оформила не менее 120 заказов.

SELECT
	c.name, 
	MIN(pr.rating) AS min_rating, 
	MAX(pr.rating) AS max_rating
FROM production AS pr
LEFT JOIN company AS c ON pr.id_company = c.id_company
LEFT JOIN [order] AS o ON pr.id_production = o.id_production
GROUP BY c.id_company, c.name
HAVING COUNT(o.id_order) >= 120


-- 5. Дать списки сделавших заказы аптек по всем дилерам компании “AstraZeneca”.
-- Если у дилера нет заказов, в названии аптеки проставить NULL.

SELECT 
	d.id_dealer, 
	d.name,
	ph.name
FROM dealer AS d
LEFT JOIN company AS c ON d.id_company = c.id_company
LEFT JOIN [order] AS o ON o.id_dealer = d.id_dealer 
LEFT JOIN pharmacy AS ph ON ph.id_pharmacy = o.id_pharmacy
WHERE c.name = 'AstraZeneca'
ORDER BY d.id_dealer


-- 6. Уменьшить на 20% стоимость всех лекарств, если она превышает 3000, а
-- длительность лечения не более 7 дней.

UPDATE production
SET production.price = production.price * 0.8
WHERE production.id_production IN (
	SELECT pr.id_production
	FROM production AS pr
	LEFT JOIN medicine ON pr.id_medicine = medicine.id_medicine
	WHERE pr.price > 3000 AND medicine.cure_duration <= 7
)


-- 7. Добавить необходимые индексы.

CREATE NONCLUSTERED INDEX [IX_dealer_id_company] ON dealer (id_company)
CREATE NONCLUSTERED INDEX [IX_company_name] ON company (name)
CREATE NONCLUSTERED INDEX [IX_medicine_name] ON medicine (name)
CREATE NONCLUSTERED INDEX [IX_production_id_company] ON production (id_company)
CREATE NONCLUSTERED INDEX [IX_production_id_medicine] ON production (id_medicine)
CREATE NONCLUSTERED INDEX [IX_order_id_production] ON [order] (id_production)
CREATE NONCLUSTERED INDEX [IX_order_id_dealer] ON [order] (id_dealer)
CREATE NONCLUSTERED INDEX [IX_order_id_pharmacy] ON [order] (id_pharmacy)