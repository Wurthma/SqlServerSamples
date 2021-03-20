IF EXISTS(SELECT 1 FROM SYS.all_objects WHERE NAME = 'PRC_REBUILD_INDEX')
DROP PROCEDURE [dbo].[PRC_REBUILD_INDEX]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--
-- **********************************************************************
--                           REBUILD INDEX
-- **********************************************************************
CREATE PROCEDURE PRC_REBUILD_INDEX(@pi_s_schema varchar(100), @pi_s_index varchar(100), @pi_s_table_name varchar(100), @pi_n_online numeric = 1) as
DECLARE @v_s_online_cmd varchar(30) = ' WITH (ONLINE=ON) ';
DECLARE @sql NVARCHAR(MAX);
begin
--
	BEGIN TRY
		if @pi_n_online = 0 
		begin
			SET @v_s_online_cmd = '';
		end
		--
		SET @sql = N'ALTER INDEX [' + @pi_s_schema + '].[' + @pi_s_index + '] ON [' + @pi_s_schema + '].[' + @pi_s_table_name + '] REBUILD ' + @v_s_online_cmd;
		EXECUTE sp_executesql @sql;
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();  
		DECLARE @ErrorSeverity INT = ERROR_SEVERITY();  
		DECLARE @ErrorState INT = ERROR_STATE();
		RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState); 
	END CATCH
--
end -- PRC_REBUILD_INDEX