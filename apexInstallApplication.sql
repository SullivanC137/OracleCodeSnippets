set serveroutput on;

declare
    type workspace_by_dbname_t is table of varchar2(100) index by varchar2(5);
    l_workspace_tab            workspace_by_dbname_t;

    c_build_option_name        constant apex_application_build_options.build_option_name%type
                               := 'VERSION_X.Y';
    c_app_id                   constant integer := 999;

    l_build_option_id          apex_application_build_options.build_option_id%type;
    l_workspace_id             apex_workspaces.workspace_id%type;
    l_build_option_old         varchar2(10);
    l_build_option_new         varchar2(10);
    l_dbname                   varchar2(5);
begin
    -- init workspaces (per database)
    l_workspace_tab('DEV01') := 'DEV_WORKSPACE';
    l_workspace_tab('TST01') := 'TEST_WORKSPACE';
    l_workspace_tab('ACC01') := 'ACCEPT_WORKSPACE';
    l_workspace_tab('PRD01') := 'PROD_WORKSPACE';

    l_dbname := sys_context('USERENV','DB_NAME');

    dbms_output.put_line(
        'Installing APEX application in workspace ' ||
        l_workspace_tab(l_dbname) || '.'
    );

    apex_application_install.set_workspace(l_workspace_tab(l_dbname));
    apex_application_install.generate_offset;
    apex_application_install.set_schema('APP_SCHEMA');
    apex_application_install.set_application_alias('APP_ALIAS');
end;
/
 
@f999v1000.sql
