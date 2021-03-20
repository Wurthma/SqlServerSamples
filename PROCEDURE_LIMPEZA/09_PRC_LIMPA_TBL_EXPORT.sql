IF EXISTS(SELECT 1 FROM SYS.all_objects WHERE NAME = 'PRC_LIMPA_TBL_EXPORT')
  DROP PROCEDURE [dbo].[PRC_LIMPA_TBL_EXPORT]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--
-- **********************************************************************
--                           LIMPA BLR_TBL_EXPORT
-- **********************************************************************
CREATE PROCEDURE PRC_LIMPA_TBL_EXPORT(@pi_s_schema varchar(100), @pi_n_cod_empresa_fw numeric(10) = null, @pi_s_cod_cenario_ecd varchar(100) = null,  @po_s_msg_erro varchar(MAX) output) as
DECLARE @po_n_id_log numeric(10);
DECLARE @v_table_name varchar(30) = 'BLR_TBL_EXPORT';
begin
--
	print('PRC_LOG_INICIAL_TBL_EXPORT')
	EXEC PRC_LOG_INICIAL_TBL_EXPORT @pi_n_cod_empresa_fw, @pi_s_cod_cenario_ecd, @po_n_id_log output;
	--
	print('PRC_DELETE_TBL_EXPORT')
	EXEC PRC_DELETE_TBL_EXPORT @po_n_id_log, @po_s_msg_erro output;
	--
	print('PRC_REBUILD_ALL_TBL_INDEX')
	EXEC PRC_REBUILD_ALL_TBL_INDEX @pi_s_schema, @v_table_name;
	--
	print('PRC_UPDATE_STATS')
	EXEC PRC_UPDATE_STATS @pi_s_schema, @v_table_name;

	begin transaction
	BEGIN TRY
		--Atualiza log geral
		print CHAR(13)+CHAR(10)+ 'Atualizando log geral ID: ' + convert(varchar(50), @po_n_id_log);
		UPDATE BLR_LOG_LIMPA_TBL
		SET DATA_CONCLUSAO = GETDATE(),
		SUCESSO = 1
		WHERE ID_LOG_LIMPA_TBL = @po_n_id_log;
	END TRY
	BEGIN CATCH
		SET @po_s_msg_erro = @po_s_msg_erro + '|' + ERROR_MESSAGE();
		rollback transaction
		return(1)
	END CATCH
	--
	commit transaction
	--
	print(@po_s_msg_erro)
--
end -- PRC_LIMPA_TBL_EXPORT