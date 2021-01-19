--------------------------------------------------------------
--------------------------------------------------------------
GO
CREATE OR ALTER TRIGGER Priority_SET
ON task
AFTER UPDATE
AS
	INSERT INTO priority_audit (new_priority_id, task_id);	
	SELECT priority_id,id
	FROM INSERTED
	UPDATE priority_audit set date_of_change = GETDATE() WHERE id = SCOPE_IDENTITY()
	UPDATE priority_audit set old_priority_id = (SELECT priority_id FROM DELETED) WHERE id = SCOPE_IDENTITY()
	
-----------------------Отладка--------------------------------
--------------------------------------------------------------
-- РЕГИСТРАЦИЯ ПОЛЬЗОВАТЕЛЕЙ
GO
EXEC Reg_user 'Ryan White', 'Martini', 'qwerty'
EXEC Reg_user 'Joanna Lite', 'lite_me', '8888888'
EXEC Reg_user 'Joanna Lite', 'lite_me', '8888888' -- Одинаковый логин: Должно выдать ошибку
EXEC Reg_user 'Mira Blackwood', 'MiRaBlack', '777'
EXEC Reg_user 'Jo Wi', 'JoWI333', 'CAPjf8294RRRRR'
EXEC Reg_user 'Alex R.', 'Ar15', '1eadasdq456'
EXEC Reg_user 'Alex R.', 'Ar16', '1eadasdq456'

--------------------------------------------------------------
--------------------------------------------------------------
-- АВТОРИЗАЦИЯ ПОЛЬЗОВАТЕЛЕЙ
GO
EXEC Auth_user 'MiRaBlack', '777'
EXEC Auth_user 'JoWI333', 'CAPjf8294RRRRR'
EXEC Auth_user 'JoWI333', 'CAPjf82dsdads94RRRRR'
EXEC Auth_user 'JoWfffI333', 'CAPjf8294RRRRR'

--------------------------------------------------------------
--------------------------------------------------------------
-- СОЗДАНИЕ НОВЫХ ДОСОК ДЛЯ РАБОТЫ
GO
EXEC create_board 2, 'My First Board', '2020-12-17'
EXEC create_board 2, 'My 2 Board'
EXEC create_board 2, 'My 3 - Tilda', '2022-11-11'
EXEC create_board 11, 'My 3 - Tilda', '2022-11-11' -- Пример ошибки

--------------------------------------------------------------
--------------------------------------------------------------
-- ДОБАВЛЕНИЕ ПОЛЬЗОВАТЕЛЕЙ К ДОСКАМ
---- Параметры процедуры add_user_to_board:
---- @inviter_id, @user_id, @board_id
GO
EXEC add_user_to_board 1,1
EXEC add_user_to_board 2,2
EXEC add_user_to_board 3,3
EXEC add_user_to_board 4,4
EXEC add_user_to_board 5,5
EXEC add_user_to_board 1,2
EXEC add_user_to_board 4,3
EXEC add_user_to_board 4,2
EXEC add_user_to_board 1,1
EXEC add_user_to_board 1,1
EXEC add_user_to_board 2,1
EXEC add_user_to_board 2,1
EXEC add_user_to_board 2,3

--------------------------------------------------------------
--------------------------------------------------------------
-- ПРИКРЕПЛЕНИЕ ЗАДАЧ К СПИСКАМ
-- Добавление списков
-- add_list_to_board @user_id, @board_id, @title
EXEC add_list_to_board 1, 1, 'My First List', '2020-12-04'
EXEC add_list_to_board 1, 1, 'Мой список', '2020-12-05'
EXEC add_list_to_board 1, 2, 'Список задач'
EXEC add_list_to_board 2, 3, 'Список ресурсов', '2020-12-20'
EXEC add_list_to_board 2, 2, 'TO DO list'

-- Добавление самих задач
-- add_task_to_list @user_id, @list_id, @title
EXEC add_task_to_list 1, 1, 'Сделать бекап'
EXEC add_task_to_list 1, 3, 'Купить мышь' -- Пользователь не привязан к доске
EXEC add_task_to_list 2, 3, 'Купить мышь', '2020-12-20'
EXEC add_task_to_list 4, 3, 'Купить мышь', '2020-12-21'

--------------------------------------------------------------
--------------------------------------------------------------
-- УСТАНОВЛЕНИЕ ПРИОРИТЕТА И СРОКОВ ВЫПОЛНЕНИЯ ДЛЯ ЗАДАЧ

-- Создание статусов
-- create_task_status @title, @status_type
EXEC create_task_status 'Заморожено',-20
EXEC create_task_status 'Нужно Ревью', -10
EXEC create_task_status 'Нужна помощь', 0
EXEC create_task_status 'User Interface', 0

-- Установка статусов
-- set_task_status @user_id, @task_id, @task_status_id
EXEC set_task_status 1,1,1
EXEC set_task_status 1,1,2
EXEC set_task_status 4,8,3

-- Создание Приоритетов
-- create_task_priority @title, @priority
EXEC create_task_priority 'High Priority',10
EXEC create_task_priority 'Low', -10
EXEC create_task_priority 'Default', 0

-- Установка приоритета
-- set_task_priority @user_id, @task_id, @task_priority_id
GO
EXEC set_task_priority 1,1,1
EXEC set_task_priority 1,1,3

--------------------------------------------------------------
--------------------------------------------------------------
-- Вывод таблиц (DEBUG)
GO
SELECT id, old_priority_id,new_priority_id,date_of_change FROM priority_audit
SELECT * FROM task_status
SELECT * FROM task_priority
SELECT * FROM task ORDER BY list_id
SELECT * FROM list ORDER BY board_id
SELECT * FROM task_user
SELECT * FROM board
SELECT * FROM users_boards ORDER BY board_id

