-- 1. INSERT
-- 	1. Без указания списка полей
-- 	INSERT INTO table_name VALUES (value1, value2, value3, ...);
INSERT INTO reader VALUES (5, 'Manilov', 'Bob', 0, '2000-10-10');
INSERT INTO reader VALUES (6, 'Manilov', 'Bob', 0, '2001-10-12');
INSERT INTO book VALUES (1, '123-23..', 'Bible', 10, 2000);
INSERT INTO copy VALUES (1, 1, 2, '2001-10-12');
INSERT INTO issuance VALUES (1, 1, 5, '2001-10-12', null, '2002-10-12');
INSERT INTO issuance VALUES (2, 1, 6, '2001-10-12', null, '2002-10-12');
-- 	2. С указанием списка полей
-- 	INSERT INTO table_name (column1, column2, column3, ...) VALUES (value1, value2, value3, ...);
INSERT INTO book (isbn, name, page_num, publication_year) VALUES ('978-3-..', 'Библия', 100, 10);
-- 	3. С чтением значения из другой таблицы
-- 	INSERT INTO table2 (column_name(s)) SELECT column_name(s) FROM table1;
INSERT INTO author (firstname, lastname, book_num, birthday)
    SELECT firstname, lastname, read_num, birthday FROM reader;

-- 2. DELETE
-- 	1. Всех записей
DELETE FROM reader WHERE true;
-- 	2. По условию
-- 		DELETE FROM table_name WHERE condition;
DELETE FROM reader WHERE reader_id = 5;
-- 	3. Очистить таблицу
-- 		TRUNCATE
TRUNCATE reader CASCADE;

-- 3. UPDATE
-- 	1. Всех записей
UPDATE reader SET read_num = 0 WHERE true;
-- 	2. По условию обновляя один атрибут
-- 		UPDATE table_name SET column1 = value1, column2 = value2, ... WHERE condition;
UPDATE reader SET read_num = 0 WHERE reader_id > 1;
-- 	3. По условию обновляя несколько атрибутов
-- 		UPDATE table_name SET column1 = value1, column2 = value2, ... WHERE condition;
UPDATE reader SET read_num = 0, firstname = null WHERE reader_id > 1;

-- 4. SELECT
-- 	1. С определенным набором извлекаемых атрибутов (SELECT atr1, atr2 FROM...)
SELECT firstname, lastname FROM reader;
-- 	2. Со всеми атрибутами (SELECT * FROM...)
SELECT * FROM reader;
-- 	3. С условием по атрибуту (SELECT * FROM ... WHERE atr1 = "")
SELECT * FROM reader WHERE reader_id = 5;

-- 5. SELECT ORDER BY + TOP (LIMIT)
--     1. С сортировкой по возрастанию ASC + ограничение вывода количества записей
SELECT * FROM reader ORDER BY reader_id ASC LIMIT 1;
--     2. С сортировкой по убыванию DESC
SELECT * FROM reader ORDER BY reader_id DESC;
--     3. С сортировкой по двум атрибутам + ограничение вывода количества записей
SELECT * FROM reader ORDER BY reader_id DESC, firstname DESC LIMIT 1;
--     4. С сортировкой по первому атрибуту, из списка извлекаемых
SELECT * FROM reader ORDER BY 1 DESC;

-- 6. Работа с датами. Необходимо, чтобы одна из таблиц содержала атрибут с типом DATETIME.
--     Например, таблица авторов может содержать дату рождения автора.
--     1. WHERE по дате
SELECT * FROM reader WHERE birthday = '2000-10-12';
--     2. Извлечь из таблицы не всю дату, а только год. Например, год рождения автора.
--        Для этого используется функция YEAR
--        https://docs.microsoft.com/en-us/sql/t-sql/functions/year-transact-sql?view=sql-server-2017
SELECT reader.reader_id, date_part('year', birthday) FROM reader;

-- 7. SELECT GROUP BY с функциями агрегации
--     1. MIN
SELECT MIN(birthday) FROM reader;
--     2. MAX
SELECT MAX(birthday) FROM reader;
--     3. AVG
SELECT AVG(reader_id) FROM reader;
--     4. SUM
SELECT SUM(reader_id) FROM reader;
--     5. COUNT
SELECT COUNT(reader_id) FROM reader;

-- 8. SELECT GROUP BY + HAVING
--     1. Написать 3 разных запроса с использованием GROUP BY + HAVING
SELECT COUNT(reader_id) FROM reader GROUP BY reader_id HAVING reader_id > 5;
SELECT reader_id, MIN(birthday) FROM reader GROUP BY reader_id HAVING reader_id > 1;
SELECT reader_id, AVG(reader_id) FROM reader GROUP BY reader_id HAVING reader_id > 1;

-- 9. SELECT JOIN
--     1. LEFT JOIN двух таблиц и WHERE по одному из атрибутов
SELECT * FROM reader
LEFT JOIN issuance ON reader.reader_id = issuance.reader_id;
--     2. RIGHT JOIN. Получить такую же выборку, как и в 5.1
SELECT * FROM reader
RIGHT JOIN issuance ON reader.reader_id = issuance.reader_id
ORDER BY reader.reader_id ASC LIMIT 1;
--     3. LEFT JOIN трех таблиц + WHERE по атрибуту из каждой таблицы
SELECT r.reader_id, i.issue_date, c.copy_id FROM reader r
LEFT JOIN issuance i ON r.reader_id = i.reader_id
LEFT JOIN copy c on i.copy_id = c.copy_id;
--     4. FULL OUTER JOIN двух таблиц
SELECT * FROM reader
FULL OUTER JOIN issuance ON reader.reader_id = issuance.reader_id;

-- 10. Подзапросы
--     1. Написать запрос с WHERE IN (подзапрос)
SELECT * FROM reader WHERE reader_id IN (5, 6);
--     2. Написать запрос SELECT atr1, atr2, (подзапрос) FROM ...
SELECT reader_id, firstname, lastname,
       (SELECT COUNT(issuance_id) FROM issuance WHERE reader.reader_id = reader_id) AS issued
FROM reader;