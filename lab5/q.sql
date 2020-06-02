use lab5;

-- 1. Добавить внешние ключи.

ALTER TABLE [dbo].[dealer]  WITH CHECK ADD  CONSTRAINT [FK_dealer_company] FOREIGN KEY([id_company])
REFERENCES [dbo].[company] ([id_company])
GO
ALTER TABLE [dbo].[dealer] CHECK CONSTRAINT [FK_dealer_company]
GO
ALTER TABLE [dbo].[order]  WITH CHECK ADD  CONSTRAINT [FK_order_dealer] FOREIGN KEY([id_dealer])
REFERENCES [dbo].[dealer] ([id_dealer])
GO
ALTER TABLE [dbo].[order] CHECK CONSTRAINT [FK_order_dealer]
GO
ALTER TABLE [dbo].[order]  WITH CHECK ADD  CONSTRAINT [FK_order_pharmacy] FOREIGN KEY([id_pharmacy])
REFERENCES [dbo].[pharmacy] ([id_pharmacy])
GO
ALTER TABLE [dbo].[order] CHECK CONSTRAINT [FK_order_pharmacy]
GO
ALTER TABLE [dbo].[order]  WITH CHECK ADD  CONSTRAINT [FK_order_production] FOREIGN KEY([id_production])
REFERENCES [dbo].[production] ([id_production])
GO
ALTER TABLE [dbo].[order] CHECK CONSTRAINT [FK_order_production]
GO
ALTER TABLE [dbo].[production]  WITH CHECK ADD  CONSTRAINT [FK_production_company] FOREIGN KEY([id_company])
REFERENCES [dbo].[company] ([id_company])
GO
ALTER TABLE [dbo].[production] CHECK CONSTRAINT [FK_production_company]
GO
ALTER TABLE [dbo].[production]  WITH CHECK ADD  CONSTRAINT [FK_production_medicine] FOREIGN KEY([id_medicine])
REFERENCES [dbo].[medicine] ([id_medicine])
GO
ALTER TABLE [dbo].[production] CHECK CONSTRAINT [FK_production_medicine]
GO


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
-- 4. Дать минимальный и максимальный баллы лекарств каждой фирмы, которая
-- оформила не менее 120 заказов.
-- 5. Дать списки сделавших заказы аптек по всем дилерам компании “AstraZeneca”.
-- Если у дилера нет заказов, в названии аптеки проставить NULL.
-- 6. Уменьшить на 20% стоимость всех лекарств, если она превышает 3000, а
-- длительность лечения не более 7 дней.
-- 7. Добавить необходимые индексы.