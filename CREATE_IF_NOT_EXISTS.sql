--Table
IF NOT EXISTS(SELECT 1 FROM sysobjects WHERE name = 'TABLE_TESTE' AND xtype = 'U')
BEGIN  
	
	SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
	BEGIN TRANSACTION
	PRINT '--------------------------------------------------'
	PRINT 'ACTION:  CREATE TABLE TABLE_TESTE' 
	PRINT '--------------------------------------------------'
    CREATE TABLE dbo.TABLE_TESTE (
        MAJOR NUMERIC(12,0) NOT NULL,
		MINOR NUMERIC(12,0) NOT NULL,
		REVISION NUMERIC(12,0) NOT NULL,
		BLOCK NUMERIC(12,0) NOT NULL,
        DT_UPDATE DATETIME NOT NULL,
        USUARIO NVARCHAR(256) NULL,
        DATA_BASE NVARCHAR(256) NOT NULL,
		CONSTRAINT PK_TBFR_RELEASE PRIMARY KEY  CLUSTERED 
		(MAJOR,MINOR,REVISION,BLOCK,DATA_BASE)
	);

	IF (@@ERROR<>0) AND (@@TRANCOUNT>0) 
		ROLLBACK TRANSACTION 
	ELSE BEGIN
		--Do something else...
		COMMIT TRANSACTION
	END
END
ELSE BEGIN 
	--Do something if exists...
END

GO

--Primary Key
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE type = 'PK' AND  object_id = OBJECT_ID ('PK_TABLE_TESTE'))
BEGIN
	ALTER TABLE BLR_CALCULO_DIF_ALT ADD CONSTRAINT PK_BLR_CALCULO_DIF_ALT PRIMARY KEY CLUSTERED 
	(
		[COD_EMPRESA_FW] ASC,
		[COD_CENARIO] ASC,
		[SEQ_PERIODO] ASC,
		[IND_TIPO] ASC
	) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
END

GO

--Constraint
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE type = 'F' AND  object_id = OBJECT_ID ('FK_SAMPLE_01'))
BEGIN
	ALTER TABLE TABLE_NAME 
	ADD CONSTRAINT FK_SAMPLE_01 
	FOREIGN KEY(COD_EMPRESA, COD_TIPO, NUM_ORDEM)
	REFERENCES BLR_ECF_OPER_EXPORTACAO (COD_EMPRESA_FW, COD_TIPO, NUM_ORDEM)
END

GO

--Drop column if exists
IF EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = N'TABLE_EXAMPLE AND COLUMN_NAME = N'COLUMN_EXAMPLE')
BEGIN  
	SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
	BEGIN TRANSACTION
    
	ALTER TABLE TABLE_EXAMPLE DROP COLUMN COLUMN_EXAMPLE;

	IF (@@ERROR<>0) AND (@@TRANCOUNT>0) 
		ROLLBACK TRANSACTION 
	ELSE BEGIN
		COMMIT TRANSACTION
	END
END

GO
