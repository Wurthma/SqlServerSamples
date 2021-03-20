IF EXISTS(SELECT 1 FROM SYS.all_objects WHERE NAME = 'PRC_REBUILD_ALL_TBL_INDEX')
  DROP PROCEDURE [dbo].[PRC_REBUILD_ALL_TBL_INDEX]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--
-- **********************************************************************
--         LOOP EM TODOS INDEX DA TABELA, REBUILD e REORGANIZE
-- **********************************************************************
CREATE PROCEDURE PRC_REBUILD_ALL_TBL_INDEX(@pi_s_schema varchar(100), @pi_s_table_name varchar(100)) as
begin
--
	DECLARE @item VARCHAR(max) 
	--
	DECLARE C_INDEXES_CURSOR CURSOR FOR 
		SELECT  IndexName = ind.name FROM sys.indexes ind 
		INNER JOIN 
				sys.tables t ON ind.object_id = t.object_id 
		WHERE  
			ind.is_primary_key = 0
			AND ind.is_unique = 0 
			AND ind.is_unique_constraint = 0 
			AND t.is_ms_shipped = 0
			AND t.name = @pi_s_table_name
		ORDER BY 
				t.name, ind.name, ind.index_id;
	
	BEGIN TRY
		OPEN C_INDEXES_CURSOR 
		FETCH next FROM C_INDEXES_CURSOR INTO @item 
		WHILE @@FETCH_STATUS = 0 
		BEGIN 
			EXEC PRC_REBUILD_INDEX @pi_s_schema, @item, @pi_s_table_name, 1;
			EXEC PRC_REORGANIZE_INDEX @pi_s_schema, @pi_s_table_name;
			FETCH next FROM clistaitem INTO @item 
		END
	END TRY
	BEGIN CATCH
		IF CURSOR_STATUS('global','C_INDEXES_CURSOR')>=-1
		BEGIN
			DEALLOCATE C_INDEXES_CURSOR
			DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();  
			DECLARE @ErrorSeverity INT = ERROR_SEVERITY();  
			DECLARE @ErrorState INT = ERROR_STATE();
			RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
		END
	END CATCH
	--
	IF CURSOR_STATUS('global','C_INDEXES_CURSOR')>=-1
	BEGIN
	 DEALLOCATE C_INDEXES_CURSOR
	END
--
end --PRC_REBUILD_ALL_TBL_INDEX