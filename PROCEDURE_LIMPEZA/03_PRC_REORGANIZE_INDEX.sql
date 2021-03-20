IF EXISTS(SELECT 1 FROM SYS.all_objects WHERE NAME = 'PRC_REORGANIZE_INDEX')
DROP PROCEDURE [dbo].[PRC_REORGANIZE_INDEX]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--
-- **********************************************************************
--                           REORGANIZE INDEX
-- **********************************************************************
CREATE PROCEDURE PRC_REORGANIZE_INDEX(@pi_s_schema varchar(100), @pi_s_table_name varchar(100)) as
DECLARE @sql NVARCHAR(MAX);
begin
--
	BEGIN TRY
		SET @sql = N'ALTER ALL ON [' + @pi_s_schema + '].[' + @pi_s_table_name + '] REORGANIZE';
		EXECUTE sp_executesql @sql;
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();  
		DECLARE @ErrorSeverity INT = ERROR_SEVERITY();  
		DECLARE @ErrorState INT = ERROR_STATE();
		RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
	END CATCH
--
end -- PRC_REORGANIZE_INDEX