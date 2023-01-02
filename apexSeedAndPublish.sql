declare
  v_ws_id   number;
  -- comma seperated langs and app_id's
  v_app_ids varchar2(50) := :application_ids; --eg: '700000,701000,702000,703000,704000'
  v_langs   varchar2(20) := :languages;       --eg: 'nl,en-gb,de-at'
  cursor c_langs_apps
  is
  with langs as
  (select  regexp_substr(v_langs,'[^,]+', 1, level) lang
   from   dual 
  connect BY regexp_substr(v_langs, '[^,]+', 1, level) is not null
  )
  ,    app_ids as
  (select  regexp_substr(v_app_ids,'[^,]+', 1, level) app_id
   from   dual 
  connect BY regexp_substr(v_app_ids, '[^,]+', 1, level) is not null
  )
  select lang,app_id
  from   langs
  ,      app_ids
  ;
begin
  select workspace_id into v_ws_id from apex_workspaces;
  wwv_flow_api.set_security_group_id(v_ws_id);
    for c1 in (select workspace_id
               from apex_workspaces) loop
      apex_util.set_security_group_id( c1.workspace_id );
      exit;
    end loop;
    -- Now, seed and publish the translation repository for all apps and langs
    for rec in c_langs_apps loop            
      apex_lang.seed_translations(p_application_id => rec.app_id,
                                  p_language       => rec.lang
                                  );
      apex_lang.publish_application(p_application_id => rec.app_id,
                                    p_language       => rec.lang
                                    );    
    end loop;
    commit;
end;
/
