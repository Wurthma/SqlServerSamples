IF EXISTS(SELECT 1 FROM SYS.all_objects WHERE NAME = 'PRC_DELETE')
  DROP PROCEDURE [dbo].[PRC_DELETE]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--
-- **********************************************************************
-- Procedure interna para limpar os dados de uma tabela.
-- **********************************************************************

CREATE PROCEDURE PRC_DELETE(@pi_s_tabela	varchar(100),
							@pi_s_where		varchar(MAX),
							@pio_s_msg		varchar(MAX) OUTPUT) as
begin
--
DECLARE @sql NVARCHAR(MAX);
--
begin
	--
	SET @sql = N'DELETE FROM '+@pi_s_tabela+'';
	
	if @pi_s_where is not null 
	begin
		SET @sql = N'DELETE FROM ' + @pi_s_tabela + ' WHERE ' + @pi_s_where + '';
	end

	-- Execute DELETE
	begin transaction
	EXECUTE sp_executesql @sql;
	--
	end

	if @@error <> 0
	begin
		DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();  
		DECLARE @ErrorSeverity INT = ERROR_SEVERITY();  
		DECLARE @ErrorState INT = ERROR_STATE();
		
		SET @pio_s_msg = @pio_s_msg + ERROR_MESSAGE();
		rollback transaction
		RAISERROR (@ErrorMessage, -- Message text.  
               @ErrorSeverity, -- Severity.  
               @ErrorState -- State.  
	   );  
	end
	else
	begin
		commit transaction
		return(0)
	end
--
end -- END PRC DELETE