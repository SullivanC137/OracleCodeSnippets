-- run as skr
-- with a collection
declare
  type stmt_type is table of varchar2(4000);
  stmt_ct  stmt_type:=stmt_type();
begin
  -- add your statements to the collection
  stmt_ct := 
    stmt_type('create table test1 (id number)',
              'create table test2 (id number)',
              'create table test3 (id number)',
              'grant select on test1 to user1');
  -- execute all statements on the admin schema
  for i in stmt_ct.first .. stmt_ct.last loop
  admin.buju_pkg.do_ddl(stmt_ct(i));
  end loop;
  -- remove all statements
  stmt_ct.delete;
end;
/

-- with a file on directory: MYDIR
create directory MYDIR as 'MYDIR';

--check directory:
SELECT * FROM DBMS_CLOUD.LIST_FILES('MYDIR');

-- create file with
DECLARE
   fHandle   UTL_FILE.FILE_TYPE;
BEGIN
   fHandle := UTL_FILE.FOPEN ('MYDIR', 'test_file.sql', 'w');
   UTL_FILE.PUT (fHandle, 'create table test1 (id number);');
   UTL_FILE.PUT (fHandle, 'create table test2 (id number);');
   UTL_FILE.PUT_LINE (fHandle, 'create table test3 (id number);');
   UTL_FILE.FCLOSE (fHandle);
EXCEPTION
   WHEN OTHERS
   THEN
      DBMS_OUTPUT.PUT_LINE (
         'Exception: SQLCODE=' || SQLCODE || '  SQLERRM=' || SQLERRM);
      RAISE;
END;
/
-- create drop file with
DECLARE
   fHandle   UTL_FILE.FILE_TYPE;
BEGIN
   fHandle := UTL_FILE.FOPEN ('MYDIR', 'test_drop_file.sql', 'w');
   UTL_FILE.PUT (fHandle, 'drop table test1;');
   UTL_FILE.PUT (fHandle, 'drop table test2;');
   UTL_FILE.PUT_LINE (fHandle, 'drop table test3;');
   UTL_FILE.FCLOSE (fHandle);
EXCEPTION
   WHEN OTHERS
   THEN
      DBMS_OUTPUT.PUT_LINE (
         'Exception: SQLCODE=' || SQLCODE || '  SQLERRM=' || SQLERRM);
      RAISE;
END;
/

-- run file with
DECLARE
  f UTL_FILE.FILE_TYPE;
  s VARCHAR2(4000); --. check this. Could be larger in PLSQL
begin
  f:= UTL_FILE.FOPEN('MYDIR', 'test_drop_file.sql', 'R');
  UTL_FILE.GET_LINE(f,s);
  UTL_FILE.FCLOSE(f);
  for i in (
  select
  regexp_substr(s, '[^;]+', 1, level) stmnt 
  from dual
  connect by level <= regexp_count(s, ';') + 1
  ) loop
  dbms_output.put_line(i.stmnt);
      if i.stmnt is not null then
      admin.buju_pkg.do_ddl(i.stmnt);
      end if;
  end loop;
end;
/