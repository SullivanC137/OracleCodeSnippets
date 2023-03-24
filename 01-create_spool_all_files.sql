set termout off
set serveroutput on
set echo off
set feedback off
variable v_rowCount number;
spool spool_all_files.sql
declare
     i number := 0;
     v_fileNum number := 1;
     v_range_start number := 1;
     v_range_end number := 1;
     k_max_rows constant number := 65536;
begin
    for i in (
    select lower(object_name) object_name
    from   all_objects
    where  1 = 1
    -- tweak this query
    and    (   (object_name like '%VPL_IF_STO%MELDING_DTLS_API'
                and    object_type = 'PACKAGE')
            or (object_name like 'VPL_IF_STO%MELDING_DTLS'
                and    object_type = 'TABLE')
            )
    order by object_type, object_name
    ) loop
dbms_output.put_line('set colsep
set pagesize 0
set trimspool on 
set headsep off
set feedback off
set echo off
set termout off
set linesize 4000
spool '||i.object_name||'.syn
prompt create or replace synonym '||i.object_name||' for vpl_data.'||i.object_name||'
prompt /'
);
      end loop;
end;
/
spool off
prompt     executing intermediate file
@spool_all_files.sql;
set serveroutput off

