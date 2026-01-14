/*********************************************************************
Doel     Script om een build option aan of uit te zetten, afhankelijk
         van de huidige status
Gebruik  Pas c_build_option_name en c_app_id aan en run in
         hetzelfde schema als waarin de applicatie is geïnstalleerd
Historie 2026-01-07, <AUTHOR>
         Script aangepast: workspace hoeft niet meer handmatig per
         omgeving te worden opgegeven
         2025-12-12, <AUTHOR>
         Creatie
To do    Exceptions zoals no_data_found netjes opvangen
*********************************************************************/
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
        'Toggle build option ' || c_build_option_name ||
        ' on ' || l_workspace_tab(l_dbname) ||
        ' for app ' || c_app_id
    );

    select build_option_id
    into   l_build_option_id
    from   apex_application_build_options
    where  build_option_name = c_build_option_name
    and    application_id    = c_app_id;

    select workspace_id
    into   l_workspace_id
    from   apex_workspaces
    where  workspace = l_workspace_tab(l_dbname);

    apex_util.set_security_group_id(l_workspace_id);

    l_build_option_old :=
        apex_application_admin.get_build_option_status(
            p_application_id => c_app_id,
            p_id             => l_build_option_id
        );

    dbms_output.put_line('Current build option status: ' || l_build_option_old);

    l_build_option_new :=
        case l_build_option_old
            when apex_application_admin.c_build_option_status_include
            then apex_application_admin.c_build_option_status_exclude
            when apex_application_admin.c_build_option_status_exclude
            then apex_application_admin.c_build_option_status_include
            else null
        end;

    apex_application_admin.set_build_option_status(
        p_application_id => c_app_id,
        p_id             => l_build_option_id,
        p_build_status   => l_build_option_new
    );

    dbms_output.put_line(
        'New build option status: ' ||
        apex_application_admin.get_build_option_status(
            p_application_id => c_app_id,
            p_id             => l_build_option_id
        )
    );

    commit;
end;
/
