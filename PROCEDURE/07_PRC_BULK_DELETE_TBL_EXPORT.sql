IF EXISTS(SELECT 1 FROM SYS.all_objects WHERE NAME = 'PRC_BULK_DELETE_TBL_EXPORT')
  DROP PROCEDURE [dbo].[PRC_BULK_DELETE_TBL_EXPORT]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--
-- **********************************************************************
--                        BULK DELETE BLR_TBL_EXPORT
-- **********************************************************************
CREATE PROCEDURE PRC_BULK_DELETE_TBL_EXPORT(@pi_n_cod_empresa_fw			numeric(10),
											@pi_s_cod_cenario_ecd			varchar(100),
											@pi_n_seq_ocorrencia			numeric(5),
											@pi_s_cod_forma_esc	 			varchar,
											@pi_n_ultima_geracao_mantida 	numeric(5),
											@pi_n_seq_ordem_exp				numeric(5), 
											@pi_n_log_retificadora			numeric,
											@pi_n_id_log_limpa_ecd 			numeric(10),
											@po_s_msg_erro					varchar(MAX) output) as
	-- Cursor para identificar o rowid (endereco unico) a ser limpo na tabela
	-- Rowid seria um endereco unico que localiza o registro na instancia dados
	DECLARE @resultado					INTEGER = 0, 
			@query						VARCHAR(max), 
			@cod_bloco					VARCHAR(1),
			@cod_registro				VARCHAR(4),
			@num_linha					NUMERIC(10),
			@seq_ordem_ultima_geracao	INTEGER
	--
	DECLARE C_LIST_TBL_EXPORT CURSOR FOR 
	SELECT COD_BLOCO, COD_REGISTRO, NUM_LINHA, SEQ_ORDEM_ULTIMA_GERACAO
	FROM BLR_TBL_EXPORT EXP
	WHERE EXP.COD_EMPRESA_FW = @pi_n_cod_empresa_fw
	AND EXP.COD_CENARIO_TBL = @pi_s_cod_cenario_ecd
	AND EXP.SEQ_OCORRENCIA = @pi_n_seq_ocorrencia
	AND EXP.COD_FORMA_ESC = @pi_s_cod_forma_esc
	AND EXP.SEQ_ORDEM_EXP = @pi_n_seq_ordem_exp
	AND EXP.LOG_RETIFICADORA = @pi_n_log_retificadora
	AND EXP.SEQ_ORDEM_ULTIMA_GERACAO < @pi_n_ultima_geracao_mantida;
	--
    DECLARE @v_n_qtde_regs numeric(10) = 0;
	--
begin
	--
	print 'Iniciando bulk delete...'
	--
	SELECT @v_n_qtde_regs = ISNULL(QTDE_REG_EXCLUIDO,0) 
	FROM  BLR_LOG_LIMPA_TBL_RESULT
	WHERE ID_LOG_LIMPA_TBL = @pi_n_id_log_limpa_ecd
	AND COD_EMPRESA_FW = @pi_n_cod_empresa_fw
	AND COD_CENARIO_TBL = @pi_s_cod_cenario_ecd
	AND SEQ_OCORRENCIA = @pi_n_seq_ocorrencia
	AND COD_FORMA_ESC = @pi_s_cod_forma_esc
	AND ULTIMA_GERACAO_MANTIDA = @pi_n_ultima_geracao_mantida
	AND LOG_RETIFICADORA = @pi_n_log_retificadora
	AND SEQ_ORDEM_EXP = @pi_n_seq_ordem_exp;
	--
	BEGIN TRY
		print('pi_n_id_log_limpa_ecd: '+convert(varchar(50), @pi_n_id_log_limpa_ecd))
		print('pi_n_cod_empresa_fw: '+convert(varchar(50), @pi_n_cod_empresa_fw))
		print('pi_s_cod_cenario_ecd: '+convert(varchar(50), @pi_s_cod_cenario_ecd))
		print('pi_n_seq_ocorrencia: '+convert(varchar(50), @pi_n_seq_ocorrencia))
		print('pi_s_cod_forma_esc: '+ @pi_s_cod_forma_esc)
		print('pi_n_ultima_geracao_mantida: '+convert(varchar(50), @pi_n_ultima_geracao_mantida))
		print('pi_n_log_retificadora: '+convert(varchar(50), @pi_n_log_retificadora))
		print('pi_n_seq_ordem_exp: '+convert(varchar(50), @pi_n_seq_ordem_exp))
		--
		UPDATE BLR_LOG_LIMPA_TBL_RESULT
		SET DATA_INICIO = GETDATE(),
		INICIADO = 1
		WHERE ID_LOG_LIMPA_TBL = @pi_n_id_log_limpa_ecd
		AND COD_EMPRESA_FW = @pi_n_cod_empresa_fw
		AND COD_CENARIO_TBL = @pi_s_cod_cenario_ecd
		AND SEQ_OCORRENCIA = @pi_n_seq_ocorrencia
		AND COD_FORMA_ESC = @pi_s_cod_forma_esc
		AND ULTIMA_GERACAO_MANTIDA = @pi_n_ultima_geracao_mantida
		AND LOG_RETIFICADORA = @pi_n_log_retificadora
		AND SEQ_ORDEM_EXP = @pi_n_seq_ordem_exp;
		--
		print 'Limpeza iniciada...' + CHAR(13)+CHAR(10)
		--
	END TRY
	BEGIN CATCH
		SET @po_s_msg_erro = @po_s_msg_erro + '|' + ERROR_MESSAGE();
		print @po_s_msg_erro;
		return(1);
	END CATCH
	--
	OPEN C_LIST_TBL_EXPORT 
    FETCH next FROM C_LIST_TBL_EXPORT INTO	@cod_bloco, @cod_registro, @num_linha, @seq_ordem_ultima_geracao
    WHILE @@FETCH_STATUS = 0 
    BEGIN 
		print 'Deletando registro...'
		BEGIN TRY
			DELETE FROM BLR_TBL_EXPORT
			WHERE COD_BLOCO = @cod_bloco
			AND COD_REGISTRO = @cod_registro
			AND NUM_LINHA = @num_linha
			AND SEQ_ORDEM_ULTIMA_GERACAO = @seq_ordem_ultima_geracao
			AND COD_CENARIO_TBL = @pi_s_cod_cenario_ecd
			AND LOG_RETIFICADORA = @pi_n_log_retificadora
			AND COD_EMPRESA_FW = @pi_n_cod_empresa_fw
			AND SEQ_OCORRENCIA = @pi_n_seq_ocorrencia
			AND COD_FORMA_ESC = @pi_s_cod_forma_esc
			AND SEQ_ORDEM_EXP = @pi_n_seq_ordem_exp;
			--
			SET @v_n_qtde_regs = @v_n_qtde_regs + 1;
			--
		END TRY
		BEGIN CATCH
			SET @po_s_msg_erro = @po_s_msg_erro + '|' + ERROR_MESSAGE();
			--
			IF CURSOR_STATUS('global','C_LIST_TBL_EXPORT')>=-1
			BEGIN
			 DEALLOCATE C_LIST_TBL_EXPORT
			END
			--
			return(1)
		END CATCH
		--
		FETCH next FROM C_LIST_TBL_EXPORT INTO @cod_bloco, @cod_registro, @num_linha, @seq_ordem_ultima_geracao
    END -- Fim while
	--
	IF CURSOR_STATUS('global','C_LIST_TBL_EXPORT')>=-1
	BEGIN
	 DEALLOCATE C_LIST_TBL_EXPORT
	END
	--
	BEGIN TRY
		--
		UPDATE BLR_LOG_LIMPA_TBL_RESULT
		SET DATA_CONCLUSAO = GETDATE(),
		CONCLUIDO = 1,QTDE_REG_EXCLUIDO = @v_n_qtde_regs
		WHERE ID_LOG_LIMPA_TBL = @pi_n_id_log_limpa_ecd
		AND COD_EMPRESA_FW = @pi_n_cod_empresa_fw
		AND COD_CENARIO_TBL = @pi_s_cod_cenario_ecd
		AND SEQ_OCORRENCIA = @pi_n_seq_ocorrencia
		AND COD_FORMA_ESC = @pi_s_cod_forma_esc
		AND ULTIMA_GERACAO_MANTIDA = @pi_n_ultima_geracao_mantida
		AND LOG_RETIFICADORA = @pi_n_log_retificadora
		AND SEQ_ORDEM_EXP = @pi_n_seq_ordem_exp;
	END TRY
	BEGIN CATCH
		SET @po_s_msg_erro = @po_s_msg_erro + '|' + ERROR_MESSAGE();
		print @po_s_msg_erro;
		return(1);
	END CATCH
--
end -- PRC_BULK_DELETE_TBL_EXPORT