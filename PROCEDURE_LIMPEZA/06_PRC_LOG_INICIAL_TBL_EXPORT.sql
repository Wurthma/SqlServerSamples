IF EXISTS(SELECT 1 FROM SYS.all_objects WHERE NAME = 'PRC_LOG_INICIAL_TBL_EXPORT')
  DROP PROCEDURE [dbo].[PRC_LOG_INICIAL_TBL_EXPORT]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--
-- **********************************************************************
--                  POPULA LOG INICIAL LIMPEZA TBL
-- **********************************************************************
CREATE PROCEDURE PRC_LOG_INICIAL_TBL_EXPORT(@pi_n_cod_empresa_fw numeric(10) = null, @pi_s_cod_cenario_ecd varchar(100) = null, @po_n_id_log numeric(10) output) as
--
DECLARE @id NUMERIC(10)
DECLARE @table table (id  NUMERIC(10))
--
begin
--
	INSERT INTO BLR_LOG_LIMPA_TBL (
		DATA_INICIO,
		DATA_CONCLUSAO,
		SUCESSO
	)
	OUTPUT Inserted.ID_LOG_LIMPA_TBL INTO @table
	VALUES(
		GETDATE(),
		NULL,
		0
	);
	--
	SELECT @id = id from @table;
	SET @po_n_id_log = @id;
	print 'Log Id: ' + convert(varchar(50), @id)
	--
	INSERT INTO BLR_LOG_LIMPA_TBL_RESULT (
		COD_EMPRESA_FW,
		COD_CENARIO_TBL,
		SEQ_OCORRENCIA,
		COD_FORMA_ESC,
		ULTIMA_GERACAO_MANTIDA,
		ID_LOG_LIMPA_TBL,
		DATA_INICIO,
		DATA_CONCLUSAO,
		QTDE_REG_INICIAL,
		QTDE_REG_EXCLUIDO,
		INICIADO,
		CONCLUIDO,
		SEQ_ORDEM_EXP,
		LOG_RETIFICADORA
	)
	SELECT
		EXPORT.COD_EMPRESA_FW,
		EXPORT.COD_CENARIO_TBL,
		EXPORT.SEQ_OCORRENCIA,
		EXPORT.COD_FORMA_ESC,
		EXPORT.SEQ_ORDEM_ULTIMA_GERACAO,
		@id,
		NULL,
		NULL,
		0,
		0,
		0,
		0,
		SEQ_ORDEM_EXP,
		LOG_RETIFICADORA
	FROM BLR_TBL_CONTROLE_EXPORTACAO EXPORT
	WHERE (COD_EMPRESA_FW=@PI_N_COD_EMPRESA_FW OR @PI_N_COD_EMPRESA_FW IS NULL)
	AND (COD_CENARIO_TBL=@PI_S_COD_CENARIO_TBL OR @PI_S_COD_CENARIO_TBL IS NULL);
	--
	if @@error <> 0
	begin
		DEALLOCATE C_INDEXES_CURSOR
		DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();  
		DECLARE @ErrorSeverity INT = ERROR_SEVERITY();  
		DECLARE @ErrorState INT = ERROR_STATE();
		RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
	end
	else
	begin
		print 'Log inicial de limpeza gerado...';
		print ' ';
		return(0)
	end
--
end --PRC_LOG_INICIAL_TBL_EXPORT