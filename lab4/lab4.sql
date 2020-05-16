USE lab4;

-- 1. Добавить внешние ключи.
ALTER TABLE room ADD FOREIGN KEY (id_room_category) REFERENCES room_category (id_room_category) ON

DELETE CASCADE

ALTER TABLE room ADD FOREIGN KEY (id_hotel) REFERENCES hotel (id_hotel) ON

DELETE CASCADE

ALTER TABLE room_in_booking ADD FOREIGN KEY (id_room) REFERENCES room (id_room) ON

DELETE CASCADE

ALTER TABLE room_in_booking ADD FOREIGN KEY (id_booking) REFERENCES booking (id_booking) ON

DELETE CASCADE

ALTER TABLE booking ADD FOREIGN KEY (id_client) REFERENCES client (id_client) ON

DELETE CASCADE


-- 2. Выдать информацию о клиентах гостиницы “Космос”, проживающих в номерах категории “Люкс” на 1 апреля 2019г.

SELECT client.*
FROM booking
LEFT JOIN client ON client.id_client = booking.id_client
LEFT JOIN room_in_booking ON room_in_booking.id_booking = booking.id_booking
LEFT JOIN room ON room.id_room = room_in_booking.id_room
LEFT JOIN room_category ON room_category.id_room_category = room.id_room_category
LEFT JOIN hotel ON hotel.id_hotel = room.id_hotel
WHERE checkin_date <= DateFromParts(2019, 04, 1)
	AND checkout_date >= DateFromParts(2019, 04, 1)
	AND hotel.NAME = 'Космос'
	AND room_category.NAME = 'Люкс'


-- 3. Дать список свободных номеров всех гостиниц на 22 апреля.
SELECT room.*
FROM room
WHERE room.id_room NOT IN (
		SELECT room.id_room
		FROM room
		RIGHT JOIN room_in_booking ON room_in_booking.id_room = room.id_room
		WHERE room_in_booking.checkin_date >= DATEFROMPARTS(2019, 04, 22)
			AND DATEFROMPARTS(2019, 04, 22) < room_in_booking.checkout_date
		GROUP BY room.id_room
		)
		
-- 4. Дать количество проживающих в гостинице “Космос” на 23 марта по каждой категории номеров.
SELECT room_category.NAME
	,count(id_client) AS "count"
FROM booking
LEFT JOIN room_in_booking ON room_in_booking.id_booking = booking.id_booking
LEFT JOIN room ON room.id_room = room_in_booking.id_room
LEFT JOIN room_category ON room_category.id_room_category = room.id_room_category
LEFT JOIN hotel ON hotel.id_hotel = room.id_hotel
WHERE checkin_date <= DATEFROMPARTS(2019, 03, 23)
	AND checkout_date >= DATEFROMPARTS(2019, 03, 23)
	AND hotel.NAME = 'Космос'
GROUP BY room_category.NAME

-- 5. Дать список последних проживавших клиентов по всем комнатам гостиницы “Космос”, выехавшиx в апреле с указанием даты выезда.
SELECT client.*
FROM booking
LEFT JOIN client ON client.id_client = booking.id_client
LEFT JOIN room_in_booking ON room_in_booking.id_booking = booking.id_booking
LEFT JOIN room ON room.id_room = room_in_booking.id_room
LEFT JOIN (
	SELECT MAX(room_in_booking.checkout_date) AS "max"
		,room_in_booking.id_room
	FROM room_in_booking
	RIGHT JOIN room ON room.id_room = room_in_booking.id_room
	RIGHT JOIN hotel ON room.id_hotel = hotel.id_hotel
	LEFT JOIN booking ON booking.id_booking = room_in_booking.id_booking
	LEFT JOIN client ON client.id_client = booking.id_client
	WHERE DATEFROMPARTS(2019, 04, 1) <= checkout_date
		AND checkout_date < DATEFROMPARTS(2019, 05, 1)
		AND hotel.NAME = 'Космос'
	GROUP BY room_in_booking.id_room
	) AS dates ON dates.id_room = room.id_room
WHERE dates.max = checkout_date


-- 6. Продлить на 2 дня дату проживания в гостинице “Космос” всем клиентам комнат категории “Бизнес”, которые заселились 10 мая.

-- BEGIN TRANSACTION;

UPDATE room_in_booking
SET checkout_date = DATEADD(day, 2, checkout_date)
FROM room
LEFT JOIN room_in_booking ON room.id_room = room_in_booking.id_room
LEFT JOIN hotel ON room.id_hotel = hotel.id_hotel
LEFT JOIN room_category ON room.id_room_category = room_category.id_room_category
WHERE hotel.[name] = 'Космос'
	AND room_category.[name] = 'Бизнес'
	AND room_in_booking.checkin_date = DATEFROMPARTS(2019, 05, 10)

-- ROLLBACK;


-- 7. Найти все "пересекающиеся" варианты проживания. Правильное состояние: не
-- может быть забронирован один номер на одну дату несколько раз, т.к. нельзя
-- заселиться нескольким клиентам в один номер. Записи в таблице
-- room_in_booking с id_room_in_booking = 5 и 2154 являются примером
-- неправильного состояния, которые необходимо найти. Результирующий кортеж
-- выборки должен содержать информацию о двух конфликтующих номерах.

SELECT *
FROM room_in_booking b1
INNER JOIN room_in_booking AS b2 ON b1.id_room = b2.id_room
WHERE 
	b1.id_room_in_booking != b2.id_room_in_booking
	AND b1.checkin_date <= b2.checkin_date AND b2.checkin_date < b1.checkout_date
ORDER BY b1.id_room_in_booking


-- 8. Создать бронирование в транзакции.

BEGIN TRANSACTION;

INSERT INTO booking
VALUES (2,'2022-05-1');

INSERT INTO room_in_booking 
VALUES (10, 10, '2022-05-1', '2022-05-29');

COMMIT;


-- 9. Добавить необходимые индексы для всех таблиц.

-- booking
CREATE NONCLUSTERED INDEX [IX_booking_id] ON booking (id_booking)

-- client
CREATE NONCLUSTERED INDEX [IX_client_id] ON client (id_client)

-- hotel
CREATE NONCLUSTERED INDEX [IX_hotel_id] ON hotel (id_hotel)
CREATE NONCLUSTERED INDEX [IX_hotel_name] ON hotel ([name])

-- room
CREATE NONCLUSTERED INDEX [IX_room_id] ON room (id_room)

-- room_category
CREATE NONCLUSTERED INDEX [IX_room_category_id] ON room_category (id_room_category)
CREATE NONCLUSTERED INDEX [IX_room_category_name] ON room_category (name)

-- room_in_booking
CREATE NONCLUSTERED INDEX [IX_room_in_booking_id] ON room_in_booking (id_booking)
CREATE NONCLUSTERED INDEX [IX_room_in_booking_dates] ON room_in_booking (checkin_date, checkout_date)
