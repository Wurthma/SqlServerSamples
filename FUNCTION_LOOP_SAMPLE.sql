ALTER FUNCTION Fnc_check_lista_items(@lista_items VARCHAR(2000), 
                                     @cod_cliente VARCHAR(20), 
                                     @cod_empresa NUMERIC) 
returns INTEGER 
AS 
  BEGIN 
      DECLARE @resultado INTEGER = 0, 
              @query     VARCHAR(max), 
              @item      VARCHAR(max) 
      DECLARE clistaitem CURSOR FOR 
        SELECT DISTINCT ( tbl_doc_saida.item ) 
        FROM   tbl_doc_saida 
               JOIN tbl_cliente 
                 ON tbl_cliente.cod_cliente = tbl_doc_saida.cod_cliente 
        WHERE  tbl_doc_saida.cod_cliente = @cod_cliente 
               AND tbl_doc_saida.cod_empresa = @cod_empresa; 

      OPEN clistaitem 

      FETCH next FROM clistaitem INTO @item 

      WHILE @@FETCH_STATUS = 0 
        BEGIN 
            IF Charindex(@item, @lista_items, 0) > 0 
              BEGIN 
                  RETURN 1; 
              END 

            FETCH next FROM clistaitem INTO @item 
        END 

      RETURN 0; 
  END; 