IF EXISTS(SELECT 1 FROM SYS.all_objects WHERE NAME = 'PRC_UPDATE_STATS')
  DROP PROCEDURE [dbo].[PRC_UPDATE_STATS]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--
-- **********************************************************************
--                       UPDATE TABLE STATISTICS
-- **********************************************************************
CREATE PROCEDURE PRC_UPDATE_STATS(@pi_s_schema varchar(100), @pi_s_table_name varchar(100)) as
DECLARE @sql NVARCHAR(MAX);
begin
--
	BEGIN TRY
		SET @sql = N'UPDATE STATISTICS [' + @pi_s_schema + '].[' + @pi_s_table_name + ']'; 
		EXECUTE sp_executesql @sql;
	END TRY
	BEGIN CATCH
		DEALLOCATE C_INDEXES_CURSOR
		DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();  
		DECLARE @ErrorSeverity INT = ERROR_SEVERITY();  
		DECLARE @ErrorState INT = ERROR_STATE();
		RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
	END CATCH
--
end -- PRC_UPDATE_STATS