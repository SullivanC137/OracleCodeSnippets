declare
  v_ws_id number;
  v_app_id number := :app_id;
  v_session_id number := :session_id;
begin
  select workspace_id into v_ws_id from apex_workspaces;
  wwv_flow_api.set_security_group_id(v_ws_id);
  wwv_flow.g_flow_id := v_app_id;
  wwv_flow.g_instance := v_session_id;
end;
/
