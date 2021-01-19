/*
 * Список процедур:
 * - Создать новую доску
 * - Добавить пользователя на доску
 * - Создать список на доске
 * - Создать новую задачу в списке
 * - Установить приоритет задаче
 * - Установить срок выполнения задачи
 */

--------------------------------------------------------------
-- Создание новой доски
GO
CREATE OR ALTER PROCEDURE create_board
	@user_id INT,
	@title VARCHAR(30),
    @deadline DATE = NULL
AS
	BEGIN TRY
		IF NOT EXISTS (SELECT id FROM task_user WHERE id = @user_id)
			THROW 50000, 'ПОЛЬЗОВАТЕЛЬ НЕ СУЩЕСТВУЕТ', 1;
		INSERT INTO board (title, deadline) VALUES (@title, @deadline)
		INSERT INTO users_boards (board_id, task_user_id) VALUES (SCOPE_IDENTITY(), @user_id)
	END TRY
	BEGIN CATCH
		PRINT ERROR_MESSAGE();
	END CATCH

--------------------------------------------------------------
-- Удалить доску
/*
GO
CREATE OR ALTER PROCEDURE delete_board
	@user_id INT,
	@board_id INT
AS
	BEGIN TRY
		IF NOT EXISTS (SELECT id FROM task_user WHERE id = @user_id)
			THROW 50000, 'ПОЛЬЗОВАТЕЛЬ НЕ СУЩЕСТВУЕТ', 1;
		IF NOT EXISTS (SELECT id FROM board WHERE id = @board_id)
			THROW 50000, 'ДОСКА НЕ СУЩЕСТВУЕТ', 1;
		IF NOT EXISTS ( SELECT task_user_id, board_id FROM users_boards WHERE task_user_id = @user_id AND board_id = @board_id)
			THROW 50000, 'ПОЛЬЗОВАТЕЛЬ НЕ ЯВЛЯЕТСЯ СОЗДАТЕЛЕМ ДОСКИ', 1;
		DELETE FROM users_boards VALUES (@user_id, @board_id);
		DELETE FROM users_boards VALUES (@user_id, @board_id);
		DELETE FROM users_boards VALUES (@user_id, @board_id);
		DELETE FROM users_boards VALUES (@user_id, @board_id);
		DELETE FROM users_boards VALUES (@user_id, @board_id);
	END TRY
	BEGIN CATCH
		PRINT ERROR_MESSAGE();
	END CATCH
*/
--------------------------------------------------------------
-- Добавление пользователя на доску
---- Добавить на доску может только тот, кто уже привязан к доске
---- Пользователи должны существовать в базе данных
---- Доска должна существовать в базе данных
---- Нельзя добавить того, кто уже добавлен
GO
CREATE OR ALTER PROCEDURE add_user_to_board
	@user_id INT,
	@board_id INT 
AS
	BEGIN TRY
		IF NOT EXISTS (SELECT id FROM task_user WHERE id = @user_id)
			THROW 50000, 'ДОБАВЛЯЕМЫЙ ПОЛЬЗОВАТЕЛЬ НЕ СУЩЕСТВУЕТ', 1;
		IF NOT EXISTS (SELECT id FROM board WHERE id = @board_id)
			THROW 50000, 'ДОСКА НЕ СУЩЕСТВУЕТ', 1;
		IF EXISTS ( SELECT task_user_id, board_id FROM users_boards WHERE task_user_id = @user_id AND board_id = @board_id)
			THROW 50000, 'ДОБАВЛЯЕМЫЙ ПОЛЬЗОВАТЕЛЬ УЖЕ ПРИВЯЗАН К ДОСКЕ', 1;
		INSERT INTO users_boards (board_id, task_user_id) VALUES (@board_id, @user_id);
	END TRY
	BEGIN CATCH
		PRINT ERROR_MESSAGE();
	END CATCH
	

--------------------------------------------------------------
-- Добавление списка к доске
GO
CREATE OR ALTER PROCEDURE add_list_to_board
	@user_id INT,
	@board_id INT,
	@title VARCHAR(30),
	@deadline DATE = NULL
AS
	BEGIN TRY
		IF NOT EXISTS (SELECT id FROM task_user WHERE id = @user_id)
			THROW 50000, 'ПОЛЬЗОВАТЕЛЬ НЕ СУЩЕСТВУЕТ', 1;
		IF NOT EXISTS (SELECT id FROM board WHERE id = @board_id)
			THROW 50000, 'УКАЗАННАЯ ДОСКА НЕ СУЩЕСТВУЕТ', 1;
		IF NOT EXISTS ( SELECT task_user_id, board_id FROM users_boards WHERE task_user_id = @user_id AND board_id = @board_id)
			THROW 50000, 'ПОЛЬЗОВАТЕЛЬ НЕ ПРИВЯЗАН К ДОСКЕ', 1;
		INSERT INTO list (board_id, title, deadline) VALUES (@board_id, @title, @deadline);
	END TRY
	BEGIN CATCH
		PRINT ERROR_MESSAGE();
	END CATCH

--------------------------------------------------------------
-- Прикрепление задачи к доске
GO
CREATE OR ALTER PROCEDURE add_task_to_list
	@user_id INT,
	@list_id INT,
	@title VARCHAR(30),
	@deadline DATE = NULL
AS
	BEGIN TRY
		IF NOT EXISTS (SELECT id FROM task_user WHERE id = @user_id)
			THROW 50000, 'ПОЛЬЗОВАТЕЛЬ НЕ СУЩЕСТВУЕТ', 1;
		IF NOT EXISTS (SELECT id FROM list WHERE id = @list_id)
			THROW 50000, 'СПИСОК НЕ СУЩЕСТВУЕТ', 1;
		IF NOT EXISTS ( SELECT id FROM users_boards WHERE task_user_id = @user_id AND board_id = (SELECT id FROM list WHERE id = @list_id))
			THROW 50000, 'ПОЛЬЗОВАТЕЛЬ НЕ ПРИВЯЗАН К ДОСКЕ', 1;
		INSERT INTO task (author_id, title, list_id, date_of_appointment, deadline) VALUES (@user_id, @title, @list_id, GETDATE(), @deadline);
	END TRY
	BEGIN CATCH
		PRINT ERROR_MESSAGE();
	END CATCH

--------------------------------------------------------------
-- ДОБАВЛЕНИЕ НОВЫХ СТАТУСОВ
GO
CREATE OR ALTER PROCEDURE create_task_status
	@title VARCHAR(30),
	@status_type INT
AS
	BEGIN TRY
		IF EXISTS ( SELECT title, status_type FROM task_status WHERE title = @title AND status_type = @status_type)
			THROW 50000, 'ТАКОЙ СТАТУС УЖЕ СУЩЕСТВУЕТ', 1;
		INSERT INTO task_status (title, status_type) VALUES (@title, @status_type)
	END TRY
	BEGIN CATCH
		PRINT ERROR_MESSAGE();
	END CATCH

--------------------------------------------------------------
-- УСТАНОВКА СТАТУСА ЗАДАЧЕ
GO
CREATE OR ALTER PROCEDURE set_task_status
	@user_id INT,
	@task_id INT,
	@task_status_id INT
AS
	BEGIN TRY
		IF NOT EXISTS (SELECT id FROM task_user WHERE id = @user_id)
			THROW 50000, 'ПОЛЬЗОВАТЕЛЬ НЕ СУЩЕСТВУЕТ', 1;
		IF NOT EXISTS (SELECT id FROM task WHERE id = @task_id)
			THROW 50000, 'ЗАДАЧА НЕ СУЩЕСТВУЕТ', 1;
		IF NOT EXISTS (SELECT id FROM task_status WHERE id = @task_status_id)
			THROW 50000, 'СТАТУС НЕ СУЩЕСТВУЕТ', 1;
		IF NOT EXISTS ( SELECT id FROM users_boards WHERE task_user_id = @user_id AND board_id = (SELECT id FROM list WHERE id = (SELECT list_id FROM task WHERE id = @task_id)))
			THROW 50000, 'ПОЛЬЗОВАТЕЛЬ НЕ ПРИВЯЗАН К ДОСКЕ', 1;
		UPDATE task SET status_id = @task_status_id WHERE id = @task_id
	END TRY
	BEGIN CATCH
		PRINT ERROR_MESSAGE();
	END CATCH



--------------------------------------------------------------
-- ДОБАВЛЕНИЕ НОВЫХ ПРИОРИТЕТОВ
GO
CREATE OR ALTER PROCEDURE create_task_priority
	@title VARCHAR(30),
	@priority INT
AS
	BEGIN TRY
		IF EXISTS ( SELECT priority, title FROM task_priority WHERE priority = @priority AND title = @title)
			THROW 50000, 'ТАКОЙ ПРИОРИТЕТ УЖЕ СУЩЕСТВУЕТ', 1;
		INSERT INTO task_priority(priority, title) VALUES (@priority, @title)
	END TRY
	BEGIN CATCH
		PRINT ERROR_MESSAGE();
	END CATCH

--------------------------------------------------------------
-- УСТАНОВКА ПРИОРИТЕТА ЗАДАЧЕ
GO
CREATE OR ALTER PROCEDURE set_task_priority
	@user_id INT,
	@task_id INT,
	@task_priority_id INT
AS
	BEGIN TRY
		IF NOT EXISTS (SELECT id FROM task_user WHERE id = @user_id)
			THROW 50000, 'ПОЛЬЗОВАТЕЛЬ НЕ СУЩЕСТВУЕТ', 1;
		IF NOT EXISTS (SELECT id FROM task WHERE id = @task_id)
			THROW 50000, 'ЗАДАЧА НЕ СУЩЕСТВУЕТ', 1;
		IF NOT EXISTS (SELECT id FROM task_priority WHERE id = @task_priority_id)
			THROW 50000, 'ПРИОРИТЕТ НЕ СУЩЕСТВУЕТ', 1;
		IF NOT EXISTS ( SELECT id FROM users_boards WHERE task_user_id = @user_id AND board_id = (SELECT id FROM list WHERE id = (SELECT list_id FROM task WHERE id = @task_id)))
			THROW 50000, 'ПОЛЬЗОВАТЕЛЬ НЕ ПРИВЯЗАН К ДОСКЕ', 1;
		UPDATE task SET priority_id = @task_priority_id WHERE id = @task_id
	END TRY
	BEGIN CATCH
		PRINT ERROR_MESSAGE();
	END CATCH

--------------------------------------------------------------
-- УСТАНОВКА СРОКОВ ВЫПОЛНЕНИЯ ЗАДАЧЕ
GO
CREATE OR ALTER PROCEDURE set_task_deadline
	@task_id INT,
	@deadline DATE
AS
	UPDATE task SET deadline = @deadline WHERE id = @task_id


--------------------------------------------------------------
GO
CREATE OR ALTER PROCEDURE set_date_of_complete
    @user_id INT,
    @task_id INT,
    @date_of_complete DATE
AS
    BEGIN TRY
        IF NOT EXISTS (SELECT id FROM task_user WHERE id = @user_id)
            THROW 50000, 'ПОЛЬЗОВАТЕЛЬ НЕ СУЩЕСТВУЕТ', 1;
        IF NOT EXISTS (SELECT id FROM task WHERE id = @task_id)
            THROW 50000, 'ЗАДАЧА НЕ СУЩЕСТВУЕТ', 1;
        IF NOT EXISTS ( SELECT id FROM users_boards WHERE task_user_id = @user_id AND board_id = (SELECT id FROM list WHERE id = (SELECT list_id FROM task WHERE id = @task_id)))
            THROW 50000, 'ПОЛЬЗОВАТЕЛЬ НЕ ПРИВЯЗАН К ДОСКЕ', 1;
        UPDATE task SET date_of_complete = @date_of_complete WHERE id = @task_id
    END TRY
    BEGIN CATCH
        PRINT ERROR_MESSAGE();
    END CATCH


	GO
CREATE OR ALTER PROCEDURE set_body_in_task
    @user_id INT,
    @task_id INT,
    @body varchar(30)
AS
    BEGIN TRY
        IF NOT EXISTS (SELECT id FROM task_user WHERE id = @user_id)
            THROW 50000, 'ПОЛЬЗОВАТЕЛЬ НЕ СУЩЕСТВУЕТ', 1;
        IF NOT EXISTS (SELECT id FROM task WHERE id = @task_id)
            THROW 50000, 'ЗАДАЧА НЕ СУЩЕСТВУЕТ', 1;
        IF NOT EXISTS ( SELECT id FROM users_boards WHERE task_user_id = @user_id AND board_id = (SELECT id FROM list WHERE id = (SELECT list_id FROM task WHERE id = @task_id)))
            THROW 50000, 'ПОЛЬЗОВАТЕЛЬ НЕ ПРИВЯЗАН К ДОСКЕ', 1;
        UPDATE task SET body = @body WHERE id = @task_id
    END TRY
    BEGIN CATCH
        PRINT ERROR_MESSAGE();
    END CATCH

----------------------------------------------------------------
	GO
CREATE OR ALTER PROCEDURE set_responsible
    @user_id INT,
    @task_id INT
AS
    BEGIN TRY
        IF NOT EXISTS (SELECT id FROM task_user WHERE id = @user_id)
            THROW 50000, 'ПОЛЬЗОВАТЕЛЬ НЕ СУЩЕСТВУЕТ', 1;
        IF NOT EXISTS (SELECT id FROM task WHERE id = @task_id)
            THROW 50000, 'ЗАДАЧА НЕ СУЩЕСТВУЕТ', 1;
        IF NOT EXISTS ( SELECT id FROM users_boards WHERE task_user_id = @user_id AND board_id = (SELECT id FROM list WHERE id = (SELECT list_id FROM task WHERE id = @task_id)))
            THROW 50000, 'ПОЛЬЗОВАТЕЛЬ НЕ ПРИВЯЗАН К ДОСКЕ', 1;
        UPDATE task SET responsible_id = @user_id WHERE id = @task_id
    END TRY
    BEGIN CATCH
        PRINT ERROR_MESSAGE();
    END CATCH