--  https://stackoverflow.com/a/21703623/5522115

SET NOCOUNT ON;

DECLARE @OnlyInSchema sysname;
-- Set this to a value to only drop objects in one schema.
-- SET @OnlyInSchema = N'';

DECLARE @Commands TABLE (
    [Description]   NVARCHAR(MAX),
    [Line]          NVARCHAR(MAX)
);

DECLARE @Drops TABLE (
    [Type]          NVARCHAR(2),
    [Template]      NVARCHAR(MAX)
);

-- -- -- -- -- OBJECTS NOT ASSOCIATED WITH TABLES -- -- -- -- --
INSERT INTO @Drops
SELECT N'AF', N'DROP AGGREGATE $S.$O;' UNION
SELECT N'FN', N'DROP FUNCTION $S.$O;' UNION
SELECT N'FS', N'DROP FUNCTION $S.$O;' UNION
SELECT N'FT', N'DROP FUNCTION $S.$O;' UNION
SELECT N'IF', N'DROP FUNCTION $S.$O;' UNION
SELECT N'P', N'DROP PROCEDURE $S.$O;' UNION
SELECT N'SN', N'DROP SYNONYM $S.$O;' UNION
SELECT N'SQ', N'DROP QUEUE $S.$O;' UNION
SELECT N'TR', N'DROP TRIGGER $S.$O;' UNION
SELECT N'TT', N'DROP TYPE $S.$O;' UNION
SELECT N'V', N'DROP VIEW $S.$O;' UNION
SELECT N'TF', N'DROP FUNCTION $S.$O;';

INSERT INTO @Commands
SELECT  QUOTENAME(RTRIM([S].[name])) + '.' + QUOTENAME(RTRIM([O].[name])),
        REPLACE(REPLACE([D].[Template], '$S', QUOTENAME(RTRIM([S].[name]))), '$O', QUOTENAME(RTRIM([O].[name])))
    FROM [sys].[objects] AS [O]
        INNER JOIN [sys].[schemas] AS [S] ON [O].[schema_id] = [S].[schema_id]
        INNER JOIN @Drops AS [D] ON [O].[type] COLLATE Latin1_General_CS_AS = [D].[Type] COLLATE Latin1_General_CS_AS
        WHERE (@OnlyInSchema IS NULL OR [S].[name] COLLATE Latin1_General_CS_AS = @OnlyInSchema)
          AND [S].[name] COLLATE Latin1_General_CS_AS <> 'sys'
          AND [O].[is_ms_shipped] = 0;

-- -- -- -- -- OBJECTS ASSOCIATED WITH TABLES -- -- -- -- --
DELETE FROM @Drops;
INSERT INTO @Drops
SELECT N'C', N'ALTER TABLE $TS.$TO DROP CONSTRAINT $O;' UNION
SELECT N'D', N'ALTER TABLE $TS.$TO DROP CONSTRAINT $O;' UNION
SELECT N'F', N'ALTER TABLE $TS.$TO DROP CONSTRAINT $O;' UNION
SELECT N'PK', N'ALTER TABLE $TS.$TO DROP CONSTRAINT $O;';

INSERT INTO @Commands
SELECT  QUOTENAME(RTRIM([S].[name])) + '.' + QUOTENAME(RTRIM([PO].[name])) + '::' + QUOTENAME(RTRIM([O].[name])),
        REPLACE(REPLACE(REPLACE([D].[Template], '$TS', QUOTENAME(RTRIM([S].[name]))), '$O', QUOTENAME(RTRIM([O].[name]))), '$TO', QUOTENAME(RTRIM([PO].[name])))
    FROM [sys].[objects] AS [O]
        INNER JOIN [sys].[objects] AS [PO] ON [O].[parent_object_id] = [PO].[object_id]
        INNER JOIN [sys].[schemas] AS [S] ON [PO].[schema_id] = [S].[schema_id]
        INNER JOIN @Drops AS [D] ON [O].[type] COLLATE Latin1_General_CS_AS = [D].[Type] COLLATE Latin1_General_CS_AS
        WHERE (@OnlyInSchema IS NULL OR [S].[name] COLLATE Latin1_General_CS_AS = @OnlyInSchema)
          AND [S].[name] COLLATE Latin1_General_CS_AS <> 'sys'
          AND [O].[is_ms_shipped] = 0;

-- -- -- -- -- ACTUAL DROP -- -- -- -- --
DELETE FROM @Drops;
INSERT INTO @Drops
SELECT N'U', N'DROP TABLE $S.$O;' UNION
SELECT N'V', N'DROP TABLE $S.$O;';

INSERT INTO @Commands
SELECT  QUOTENAME(RTRIM([S].[name])) + '.' + QUOTENAME(RTRIM([O].[name])),
        REPLACE(REPLACE([D].[Template], '$S', QUOTENAME(RTRIM([S].[name]))), '$O', QUOTENAME(RTRIM([O].[name])))
    FROM [sys].[objects] AS [O]
        INNER JOIN [sys].[schemas] AS [S] ON [O].[schema_id] = [S].[schema_id]
        INNER JOIN @Drops AS [D] ON [O].[type] COLLATE Latin1_General_CS_AS = [D].[Type] COLLATE Latin1_General_CS_AS
        WHERE (@OnlyInSchema IS NULL OR [S].[name] COLLATE Latin1_General_CS_AS = @OnlyInSchema)
          AND [S].[name] COLLATE Latin1_General_CS_AS <> 'sys'
          AND [O].[is_ms_shipped] = 0;

-- -- -- -- -- TABLES -- -- -- -- --
DECLARE @Description NVARCHAR(MAX);
DECLARE @Message NVARCHAR(MAX);
DECLARE @Command NVARCHAR(MAX);
DECLARE CommandCursor CURSOR FOR 
    SELECT [Description], [Line] FROM @Commands;

OPEN CommandCursor;
FETCH NEXT FROM CommandCursor INTO @Description, @Command;

WHILE @@FETCH_STATUS = 0
BEGIN

    SET @Message = N'Dropping ' + @Description + '...';
    PRINT @Message;

    BEGIN TRY
        EXEC sp_executesql @Command;
    END TRY
    BEGIN CATCH
        SET @Message = N'Failed to drop ' + @Description + ':';
        PRINT @Message;
        PRINT ERROR_MESSAGE()
    END CATCH

    FETCH NEXT FROM CommandCursor INTO @Description, @Command;
END

CLOSE CommandCursor;
DEALLOCATE CommandCursor;
