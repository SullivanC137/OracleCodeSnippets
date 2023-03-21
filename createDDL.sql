-- -----------------------------------------------------------------------------------
-- File Name    : https://oracle-base.com/dba/script_creation/table_ddl.sql
-- Author       : Tim Hall
-- Description  : Creates the DDL for specified table, or all tables.
-- Call Syntax  : @table_ddl (schema) (table-name or all)
-- Last Modified: 16/03/2013 - Rewritten to use DBMS_METADATA
-- -----------------------------------------------------------------------------------
SET LONG 20000 LONGCHUNKSIZE 20000 PAGESIZE 0 LINESIZE 1000 FEEDBACK OFF VERIFY OFF TRIMSPOOL ON

BEGIN
   DBMS_METADATA.set_transform_param (DBMS_METADATA.session_transform, 'SQLTERMINATOR', true);
   DBMS_METADATA.set_transform_param (DBMS_METADATA.session_transform, 'PRETTY', true);
   -- Uncomment the following lines if you need them.
   DBMS_METADATA.set_transform_param (DBMS_METADATA.session_transform, 'SEGMENT_ATTRIBUTES', true);
   DBMS_METADATA.set_transform_param (DBMS_METADATA.session_transform, 'STORAGE', false);
END;
/
spool vpl_if_dm_vld_visreis.tab;

SELECT replace(lower(DBMS_METADATA.get_ddl ('TABLE', table_name, owner)),'"')
FROM   all_tables
WHERE  table_name in ('VPL_IF_DM_VLD_VISREIS')
;

SET PAGESIZE 14 LINESIZE 100 FEEDBACK ON VERIFY ON
