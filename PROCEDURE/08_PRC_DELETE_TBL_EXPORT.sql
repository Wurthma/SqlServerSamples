IF EXISTS(SELECT 1 FROM SYS.all_objects WHERE NAME = 'PRC_DELETE_TBL_EXPORT')
  DROP PROCEDURE [dbo].[PRC_DELETE_TBL_EXPORT]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--
-- **********************************************************************
--                          DELETE BLR_TBL_EXPORT
-- **********************************************************************
CREATE PROCEDURE PRC_DELETE_TBL_EXPORT(@pi_n_id_log numeric(10), @po_s_msg_erro varchar(MAX) output) as
DECLARE	@cod_empresa_fw numeric(10),
		@cod_cenario_ecd varchar(100),
		@seq_ocorrencia numeric(10),
		@cod_forma_esc varchar(100),
		@ultima_geracao_mantida numeric(10),
		@seq_ordem_exp numeric(10),
		@log_retificadora numeric(5)
--
DECLARE C_LIMPA_TBL_CURSOR CURSOR FOR 
	SELECT
		COD_EMPRESA_FW,
		COD_CENARIO_TBL,
		SEQ_OCORRENCIA,
		COD_FORMA_ESC,
		SEQ_ORDEM_EXP,
		ULTIMA_GERACAO_MANTIDA,
		LOG_RETIFICADORA
	FROM BLR_LOG_LIMPA_TBL_RESULT
	WHERE ID_LOG_LIMPA_TBL = @pi_n_id_log
	AND CONCLUIDO = 0;
begin
--
	BEGIN TRY
		--
		print 'Iniciando limpeza do log (BLR_LOG_LIMPA_TBL_RESULT): ' + convert(varchar(50), @pi_n_id_log)
		--
		OPEN C_LIMPA_TBL_CURSOR 
		FETCH next FROM C_LIMPA_TBL_CURSOR INTO	@cod_empresa_fw,
										@cod_cenario_ecd,
										@seq_ocorrencia,
										@cod_forma_esc,
										@seq_ordem_exp,
										@ultima_geracao_mantida,
										@log_retificadora
		WHILE @@FETCH_STATUS = 0 
		BEGIN
			--
			print 'cod_empresa_fw: ' + convert(varchar(50), @cod_empresa_fw)
			print 'cod_cenario_ecd: ' + @cod_cenario_ecd
			print 'seq_ocorrencia: ' + convert(varchar(50), @seq_ocorrencia)
			print 'cod_forma_esc: ' + @cod_forma_esc
			print 'seq_ordem_exp: ' + convert(varchar(50), @seq_ordem_exp)
			print 'ultima_geracao_mantida: ' + convert(varchar(50), @ultima_geracao_mantida)
			print 'log_retificadora: ' + convert(varchar(50), @log_retificadora)
			print ' '
			--
			EXEC PRC_BULK_DELETE_TBL_EXPORT @cod_empresa_fw,
											@cod_cenario_ecd,
											@seq_ocorrencia,
											@cod_forma_esc,
											@ultima_geracao_mantida,
											@seq_ordem_exp,
											@log_retificadora,
											@pi_n_id_log,
											@po_s_msg_erro;
			-- próximos itens
			FETCH next FROM C_LIMPA_TBL_CURSOR INTO	@cod_empresa_fw,
											@cod_cenario_ecd,
											@seq_ocorrencia,
											@cod_forma_esc,
											@seq_ordem_exp,
											@ultima_geracao_mantida,
											@log_retificadora
		END -- Fim while
	END TRY
	BEGIN CATCH
		SET @po_s_msg_erro = @po_s_msg_erro + '|' + ERROR_MESSAGE();
		print @po_s_msg_erro
		IF CURSOR_STATUS('global','C_LIMPA_TBL_CURSOR')>=-1
		BEGIN
		 DEALLOCATE C_LIMPA_TBL_CURSOR
		END
	END CATCH
	IF CURSOR_STATUS('global','C_LIMPA_TBL_CURSOR')>=-1
	BEGIN
	 DEALLOCATE C_LIMPA_TBL_CURSOR
	END
end -- PRC_DELETE_TBL_EXPORT