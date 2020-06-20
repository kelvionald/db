use lab6

-- 1. Добавить внешние ключи.
ALTER TABLE mark ADD FOREIGN KEY (id_lesson) REFERENCES lesson (id_lesson);
ALTER TABLE mark ADD FOREIGN KEY (id_student) REFERENCES student (id_student);

ALTER TABLE lesson ADD FOREIGN KEY (id_teacher) REFERENCES teacher (id_teacher);
ALTER TABLE lesson ADD FOREIGN KEY (id_subject) REFERENCES [subject] (id_subject);
ALTER TABLE lesson ADD FOREIGN KEY (id_group) REFERENCES [group] (id_group);

ALTER TABLE student ADD FOREIGN KEY (id_group) REFERENCES [group] (id_group);

-- 2. Выдать оценки студентов по информатике если они обучаются данному
-- предмету. Оформить выдачу данных с использованием view.
CREATE VIEW informatics_marks AS 
	SELECT m.mark, s.*
	FROM mark AS m
	JOIN student AS s ON s.id_student = m.id_student
	JOIN lesson AS l ON l.id_lesson = m.id_lesson
	JOIN [subject] AS sub ON sub.id_subject = l.id_subject
	WHERE sub.name = 'Информатика'
GO

-- 3. Дать информацию о должниках с указанием фамилии студента и названия
-- предмета. Должниками считаются студенты, не имеющие оценки по предмету,
-- который ведется в группе. Оформить в виде процедуры, на входе
-- идентификатор группы.
CREATE PROCEDURE get_debtors
	@id_group AS INT
AS
	SELECT s.name, sub.name
	FROM student AS s
	JOIN [group] AS g ON g.id_group = s.id_group
	JOIN lesson AS l ON l.id_group = g.id_group
	LEFT JOIN mark AS m ON m.id_student = s.id_student AND m.id_lesson = l.id_lesson
	JOIN [subject] AS sub ON sub.id_subject = l.id_subject
	WHERE g.id_group = @id_group
	GROUP BY s.name, sub.name
	HAVING COUNT(m.mark) = 0
GO

EXECUTE get_debtors @id_group = 4

-- 4. Дать среднюю оценку студентов по каждому предмету для тех предметов, по
-- которым занимается не менее 35 студентов.

SELECT AVG(mark.mark) AS average_mark, sub.name
FROM mark
LEFT JOIN lesson l ON mark.id_lesson = l.id_lesson
LEFT JOIN [subject] sub ON l.id_subject = sub.id_subject
LEFT JOIN student s ON mark.id_student = s.id_student
GROUP BY sub.name
HAVING COUNT(DISTINCT s.id_student) >= 35

-- 5. Дать оценки студентов специальности ВМ по всем проводимым предметам с
-- указанием группы, фамилии, предмета, даты. При отсутствии оценки заполнить
-- значениями NULL поля оценки.

SELECT
	g.name AS [group],
	s.name AS student,
	sub.name AS subject,
	mark.mark,
	l.date
FROM student s
LEFT JOIN [group] g ON s.id_group = g.id_group
LEFT JOIN lesson l ON g.id_group = l.id_group
LEFT JOIN [subject] sub ON l.id_subject = sub.id_subject
LEFT JOIN mark ON l.id_lesson = mark.id_lesson AND s.id_student = mark.id_student
WHERE g.name = 'ВМ'

-- 6. Всем студентам специальности ПС, получившим оценки меньшие 5 по предмету
-- БД до 12.05, повысить эти оценки на 1 балл.

UPDATE mark
SET mark.mark = mark + 1
FROM mark
LEFT JOIN student s ON mark.id_student = s.id_student
LEFT JOIN [group] g ON s.id_group = g.id_group
LEFT JOIN lesson l ON mark.id_lesson = l.id_lesson
LEFT JOIN [subject] sub ON l.id_subject = sub.id_subject
WHERE g.name = 'ПС' AND mark.mark < 5 AND 
	sub.name = 'БД' AND l.date < '2019-05-12'

-- 7. Добавить необходимые индексы.

CREATE NONCLUSTERED INDEX [IX_mark_id_student] ON mark (id_student)
CREATE NONCLUSTERED INDEX [IX_mark_id_lesson] ON mark (id_lesson)
CREATE NONCLUSTERED INDEX [IX_mark_mark] ON mark (mark)

CREATE NONCLUSTERED INDEX [IX_lesson_id_subject] ON lesson (id_subject)
CREATE NONCLUSTERED INDEX [IX_lesson_id_group] ON lesson (id_group)
CREATE NONCLUSTERED INDEX [IX_lesson_date] ON lesson (date)

CREATE NONCLUSTERED INDEX [IX_student_id_group] ON student (id_group)
CREATE NONCLUSTERED INDEX [IX_student_name] ON student (name)

CREATE NONCLUSTERED INDEX [IX_subject_id] ON subject (id_subject)
CREATE NONCLUSTERED INDEX [IX_subject_name] ON subject (name)

CREATE NONCLUSTERED INDEX [IX_group_id] ON [group] (id_group)
CREATE NONCLUSTERED INDEX [IX_group_name] ON [group] (name)

CREATE NONCLUSTERED INDEX [IX_teacher_id] ON teacher (id_teacher)