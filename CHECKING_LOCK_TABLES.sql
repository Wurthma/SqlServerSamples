-- Cheking blocked process 
select cmd,* from sys.sysprocesses where blocked > 0;

-- Use cmd below to kill spid
kill {SPID_NUMBER}