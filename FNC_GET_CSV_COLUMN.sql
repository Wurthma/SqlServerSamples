IF OBJECT_ID('dbo.FNC_GET_CSV_COLUMN') IS NOT NULL
	DROP FUNCTION FNC_GET_CSV_COLUMN
GO

CREATE FUNCTION FNC_GET_CSV_COLUMN(@coluna INT, @stringcsv VARCHAR(MAX), @separador CHAR) 
returns VARCHAR(MAX)
AS 
BEGIN 
	DECLARE @contador INT = 1,
			@csvAux VARCHAR(MAX) = @stringcsv

	IF @coluna = 1
	BEGIN
		RETURN SUBSTRING(@stringcsv, 1, CHARINDEX(@separador, @stringcsv, 1) - 1);
	END
	
	WHILE @contador < @coluna
	BEGIN
		SET @csvAux = SUBSTRING(@csvAux, CHARINDEX(@separador, @csvAux, 1) + 1, LEN(@csvAux));
		--
		SET @contador = @contador + 1;
	END
	
	IF CHARINDEX(@separador, @csvAux, 1) = 0
	BEGIN
		RETURN @csvAux;
	END
	--
	RETURN SUBSTRING(@csvAux, 1, CHARINDEX(@separador, @csvAux, 1) - 1);

	RETURN 0; 
END;