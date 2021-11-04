declare
  l_cursor   number := dbms_sql.open_cursor;
  l_code     varchar2(32000);
  l_gen_code cl_generator_pck.code_type;
begin
  l_code := null;
  l_gen_code := cl_generator_pck.gen_pck_body
                  ( p_schema          => lower(:P301_OWNER)
                  , p_master_pck_name => lower(:P301_PACKAGE_NAME) 
                  , p_pck_name        => lower(:P301_PACKAGE_NAME)
                  , p_validate_only   => true
                  , p_process_name    => upper(:P301_PROCESS_NAME)
                  );
  for i in l_gen_code.first .. l_gen_code.last
  loop
     l_code := l_code || l_gen_code(i) || ' ' || chr(10);
  end loop;

  execute immediate 'alter session set cursor_sharing=force';
  dbms_sql.parse(
    l_cursor
  , l_code
  , dbms_sql.native
  );
  execute immediate 'alter session set cursor_sharing=exact';

exception
  when others then
    execute immediate 'alter session set cursor_sharing=exact';
    dbms_sql.close_cursor(l_cursor);
    apex_error.add_error (
    p_message          => '<font color=''white''>'||dbms_utility.format_error_stack||'</font>'||
                          '</br><b>CHECK Anonymous PL/SQL block: </b></br>'||
                          '<code>'||l_code||'</code>'
   ,p_display_location => apex_error.c_inline_in_notification );
   -- raise;
end;