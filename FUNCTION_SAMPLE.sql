IF OBJECT_ID('dbo.GET_CREDITO') IS NOT NULL
	DROP FUNCTION GET_CREDITO
GO

CREATE FUNCTION GET_CREDITO (
	@id_empresa NUMERIC
	,@id_cenario VARCHAR
	,@cod_ccont VARCHAR
	,@ind_tipo_conta NUMERIC
	,@ind_dc_fin_er VARCHAR
	)
RETURNS DECIMAL
AS
BEGIN
	DECLARE @credito NUMERIC(19, 2);

	IF @ind_tipo_conta = 4
		AND @ind_dc_fin_er = 'C'
		SELECT @credito = SUM(B.VAL_CREDITO + B.VAL_SALDO_FIN_ER)
		FROM TBL_BALANCETE B WITH (NOLOCK)
		WHERE B.ID_EMPRESA = @id_empresa
			AND B.ID_CENARIO = @id_cenario
			AND B.COD_CONTA_CONTABIL = @cod_ccont;

	IF @@ROWCOUNT = 0
	BEGIN
		SET @credito = 0
	END
	ELSE
	BEGIN
		SELECT @credito = SUM(B.VAL_CREDITO)
		FROM TBL_BALANCETE B WITH (NOLOCK)
		WHERE B.ID_EMPRESA = @id_empresa
			AND B.ID_CENARIO = @id_cenario
			AND B.COD_CONTA_CONTABIL = @cod_ccont;

		IF @@ROWCOUNT = 0
		BEGIN
			SET @credito = 0
		END
	END

	RETURN @credito;
END
