/*
-- Включеиние xp_cmdshell
-- Подробнее: https://docs.microsoft.com/ru-ru/sql/relational-databases/system-stored-procedures/xp-cmdshell-transact-sql?redirectedfrom=MSDN&view=sql-server-ver15
-- Разрешить изменение дополнительных параметров.
EXEC sp_configure 'show advanced options', 1
GO
-- Сохранить
RECONFIGURE
GO
-- Включить настройку конфигурации xp_cmdshell
EXEC sp_configure 'xp_cmdshell', 1
GO
-- Сохранить
RECONFIGURE
GO
*/
----
GO
CREATE OR ALTER PROCEDURE ExportTable
	@name VARCHAR(30)
AS
	BEGIN TRY
		IF OBJECT_ID(@name, 'U') IS NULL
			THROW 50000, 'ТАБЛИЦА НЕ СУЩЕСТВУЕТ', 1;
		DECLARE @path VARCHAR(30) = 'C:\BCP\'
		DECLARE @cmd VARCHAR(2000) = 'bcp "SELECT * FROM TEST_CRS_PRJ.dbo.' + @name +' FOR XML PATH(''ProductDescription''),ROOT(''Root''); " queryout "' + @path + @name + '.xml" -c -Cutf8 -T';
		--PRINT @cmd
		EXEC master..xp_cmdshell @cmd;
	END TRY
	BEGIN CATCH
		PRINT ERROR_MESSAGE();
	END CATCH

GO
CREATE OR ALTER PROCEDURE ImportTable_task_user
AS
	BEGIN TRY
		Select * FROM task_user -- показать, что сейчас

		INSERT INTO task_user (name, login, password)
		SELECT
		IMPORT_XML.XmlCol.query('name').value('.', 'VARCHAR(30)'),
		IMPORT_XML.XmlCol.query('login').value('.', 'VARCHAR(30)'),
		IMPORT_XML.XmlCol.query('password').value('.', 'VARCHAR(30)')
		FROM (SELECT CAST(IMPORT_XML AS xml)
		FROM OPENROWSET(BULK 'C:\BCP\task_user.xml', SINGLE_BLOB) AS T(IMPORT_XML)) AS T(IMPORT_XML)
		CROSS APPLY IMPORT_XML.nodes('Root/ProductDescription') AS IMPORT_XML (XmlCol);

		Select * FROM task_user -- показать, что экспортировалось
	END TRY
	BEGIN CATCH
		PRINT ERROR_MESSAGE();
	END CATCH

/* bcp НЕ ХОЧЕТ ТАК РАБОТАТЬ!
GO
CREATE OR ALTER PROCEDURE ImportTable
	@name VARCHAR(30)
AS
	BEGIN TRY
		IF OBJECT_ID(@name, 'U') IS NULL 
			THROW 50000, 'ТАБЛИЦА НЕ СУЩЕСТВУЕТ', 1;
		DECLARE @path VARCHAR(30) = 'C:\BCP\'
		DECLARE @cmd VARCHAR(2000) = 'bcp TEST_CRS_PRJ.dbo.' + @name +' in "' + @path + @name +'.xml" -T -c ';
		--PRINT @cmd
		EXEC master..xp_cmdshell @cmd;
	END TRY
	BEGIN CATCH
		PRINT ERROR_MESSAGE();
	END CATCH
*/

-- EXPORT XML
GO
EXEC ExportTable 'board'
EXEC ExportTable 'list'
EXEC ExportTable 'priority_audit'
EXEC ExportTable 'task'
EXEC ExportTable 'task_priority'
EXEC ExportTable 'task_status'
EXEC ExportTable 'task_user'
EXEC ExportTable 'users_boards'

-- IMPORT XML
GO
EXEC ImportTable_task_user
