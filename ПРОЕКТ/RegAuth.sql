GO
CREATE OR ALTER PROCEDURE Reg_user 
	@name VARCHAR(30),
    @login Varchar(30),
    @password VARCHAR(30)
AS
	BEGIN TRY
		INSERT INTO task_user (name,login,password) VALUES(@name,@login,@password)
	END TRY
	BEGIN CATCH
		PRINT 'ЛОГИН УЖЕ ЗАНЯТ';	
	END CATCH
 
 GO
 CREATE OR ALTER PROCEDURE Auth_user
    @login Varchar(30),
    @password VARCHAR(30)
AS
	BEGIN TRY
		IF NOT EXISTS ( SELECT login,password FROM task_user WHERE login = @login AND password = @password )
			THROW 50000, 'ЛОГИН ИЛИ ПАРОЛЬ НЕ ВЕРНЫ', 1;
		PRINT 'АВТОРИЗАЦИЯ ПРОШЛА УСПЕШНО' 
	END TRY
	BEGIN CATCH
		PRINT ERROR_MESSAGE();
	END CATCH