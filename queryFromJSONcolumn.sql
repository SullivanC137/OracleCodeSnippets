drop table apex_page_settings
/

drop sequence aps_seq
/

create table apex_page_settings 
(aps_id             number
,aps_app_alias      varchar2(255)
,aps_page_id        number
,aps_page_settings  clob
,aps_created_on     date
,aps_created_by     varchar2(50)
,aps_changed_on     date
,aps_changed_by     varchar2(50)
)
/

CREATE UNIQUE INDEX APS_PK ON apex_page_settings(aps_id);
/

alter table apex_page_settings
add (constraint aps_pk primary key(aps_id) using index APS_PK);
/

alter table apex_page_settings
add constraint aps_chk_is_json check (aps_page_settings is json)
/

alter table apex_page_settings
add constraint aps_un_1 unique (aps_page_id, aps_app_alias)
/

comment on table apex_page_settings is 'This table contains specific GUI settings'
/

comment on column apex_page_settings.aps_page_settings is 'Page component settings in JSON format.'
/

create sequence aps_seq
/

create or replace trigger aps_biur
  before insert or update on apex_page_settings 
  for each row
begin
  if INSERTING
  then
      :new.aps_id         := aps_seq.nextval;
      :new.aps_created_on := sysdate;
      :new.aps_created_by := coalesce(sys_context('APEX$SESSION','APP_USER')
                                     ,sys_context('USERENV'     ,'SESSION_USER')
                                     );
      :new.aps_changed_on := sysdate;
      :new.aps_changed_by := coalesce(sys_context('APEX$SESSION','APP_USER')
                                     ,sys_context('USERENV'     ,'SESSION_USER')
                                     );
  elsif UPDATING
  then
      :new.aps_changed_on := sysdate;
      :new.aps_changed_by := coalesce(sys_context('APEX$SESSION','APP_USER')
                                     ,sys_context('USERENV'     ,'SESSION_USER')
                                     );
  end if;
end aps_biur;
/


insert into bgb_apex_page_settings
(aps_page_id,
 aps_app_alias,
 aps_page_settings
) 
select    7010              as aps_page_id
       , 'DEMO_JSON_APP' as aps_app_alias
       , '['
       ||  '{'
       ||     '"id": "recom_price_report",'
       ||     '"type": "region",'
       ||     '"hidden": "true"'
       ||   '},'
       ||  '{'     
       ||     '"id": "vkp_prices_report-column-recom_price",' 
       ||     '"type": "report_column",'
       ||     '"hidden": "true",'
       ||   '}'
       ||  ']' as aps_page_settings
    from dual
where not exists (select 'X'
                  from   bgb_apex_page_settings
                  where  aps_app_alias = 'DEMO_JSON_APP'
                  and    aps_page_id   = 7010
                  )
;

CREATE OR REPLACE package apex_page_settings_pck
as
   /********************************************************************************
   Item configurations are saved in table apex_page_settings. Administrators can
   configure for page component rendering (hidden or not), mandatory (or not), 
   default value etc.
   These functions should be called from Apex pages.
   ********************************************************************************/
   ---------------------------------------------------------------------------------
   function is_hidden(p_app_alias      in apex_page_settings.aps_app_alias%type
                     ,p_page_id        in apex_page_settings.aps_page_id%type
                     ,p_component_type in varchar2
                     ,p_component_name in varchar2
                      )
     return boolean;
   ---------------------------------------------------------------------------------
   function is_required(p_app_alias      in apex_page_settings.aps_app_alias%type
                       ,p_page_id        in apex_page_settings.aps_page_id%type
                       ,p_component_type in varchar2
                       ,p_component_name in varchar2
                        )
     return boolean;
   ---------------------------------------------------------------------------------
   function get_default_value(p_app_alias in apex_page_settings.aps_app_alias%type
                             ,p_page_id   in apex_page_settings.aps_page_id%type
                             ,p_component_type in varchar2
                             ,p_component_name in varchar2
                             )
     return varchar2;
   ---------------------------------------------------------------------------------
   /* - uses htp.p to send settings in JSON format to a js function 
      - is called from an apex application process, on process point: Ajax Callback
      - calling JS function handles client side ui logic eg: required label, readonly etc.
   */
   procedure send_to_js(p_app_alias in apex_page_settings.aps_app_alias%type
                       ,p_page_id   in apex_page_settings.aps_page_id%type
                       );
   ---------------------------------------------------------------------------------
end apex_page_settings_pck;
/

create or replace package body apex_page_settings_pck
as
  /********************************************************************************
  This package contains Apex page specific procedures and functions and is exclusively called
  from Apex applications.
  SVN revision: $Revision: 53015 $
  SVN date    : $Date: 2019-05-24 07:06:46 +0200 (vr, 24 mei 2019) $
  SVN author  : $Author: rm $
  ********************************************************************************/
  
   -- configurable page settings
   type t_settings_record is record
   (component_name varchar2(500)
   ,component_type varchar2(100) --item/region/report_column
   ,is_required    varchar2(10)   -- true/false
   ,is_hidden      varchar2(10)   -- true/false
   ,default_value  varchar2(100)
   );
   --
   type t_settings_table is table of t_settings_record;-- index by pls_integer;
   
   /* result cached function to determine page settings and return all settings for page id*/
   function get_settings(p_app_alias in apex_page_settings.aps_app_alias%type
                        ,p_page_id   in apex_page_settings.aps_page_id%type
                         )
     return t_settings_table
     result_cache
   as
     l_page_settings  t_settings_table;
     l_aps_rec        apex_page_settings%rowtype;
     --
     cursor c_settings
     is
     with aps as
     (select *
      from   apex_page_settings
      where  aps_app_alias = p_app_alias
      and    aps_page_id   = p_page_id
      )
     select component_name
     ,      component_type
     ,      is_required
     ,      is_hidden
     ,      default_value
     from   aps
     ,      JSON_TABLE
              (aps.aps_page_settings,
                 '$[*]'
                   COLUMNS
                     (component_name VARCHAR2 (4000 CHAR) PATH '$.id',
                      component_type varchar2(30)         path '$.type',
                      is_hidden      varchar2(5)          path '$.hidden',
                      is_required    varchar2(5)          path '$.required',
                      default_value  varchar2(5)          path '$.defaultvalue'
                      )
                )
     ;
   begin
     --
     open  c_settings;
     fetch c_settings 
     bulk  collect
     into  l_page_settings;
     close c_settings;
     --
     return l_page_settings;
   exception
     when no_data_found then return null;
   end get_settings;
   ---------------------------------------------------------------------------------
   function is_hidden(p_app_alias      in apex_page_settings.aps_app_alias%type
                     ,p_page_id        in apex_page_settings.aps_page_id%type
                     ,p_component_type in varchar2
                     ,p_component_name in varchar2
                      )
     return boolean
   as
     l_page_settings  t_settings_table;
   begin
     l_page_settings := get_settings(p_app_alias
                                    ,p_page_id
                                    );
     for i in 1..l_page_settings.count loop
       if     l_page_settings(i).component_type  = p_component_type
          and l_page_settings(i).component_name  = p_component_name
         then return case l_page_settings(i).is_hidden
                     when 'true' then true
                     else false
                     end;
       end if;
     end loop;
     return false;
   end;
   ---------------------------------------------------------------------------------
   function is_required(p_app_alias      in apex_page_settings.aps_app_alias%type
                       ,p_page_id        in apex_page_settings.aps_page_id%type
                       ,p_component_type in varchar2
                       ,p_component_name in varchar2
                        )
     return boolean
   as
     l_page_settings  t_settings_table;
   begin
     l_page_settings := get_settings(p_app_alias
                                    ,p_page_id
                                    );
     for i in 1..l_page_settings.count loop
       if     l_page_settings(i).is_required     = 'true'
          and l_page_settings(i).component_type  = p_component_type
          and l_page_settings(i).component_name  = p_component_name
         then return case l_page_settings(i).is_required
                     when 'true' then true
                     else false
                     end;
       end if;
     end loop;
     return false;
   end is_required;
   ---------------------------------------------------------------------------------
   function get_default_value(p_app_alias      in apex_page_settings.aps_app_alias%type
                             ,p_page_id        in apex_page_settings.aps_page_id%type
                             ,p_component_type in varchar2
                             ,p_component_name in varchar2
                             )
     return varchar2
   as
     l_page_settings  t_settings_table;
   begin
     l_page_settings := get_settings(p_app_alias
                                    ,p_page_id
                                    );
     for i in 1..l_page_settings.count loop
       if     l_page_settings(i).component_name  = p_component_name
          and l_page_settings(i).component_type  = p_component_type
         then return substr(l_page_settings(i).default_value,100); --arbritary value of 100
       end if;
     end loop;
     return null;
   end get_default_value;
   ---------------------------------------------------------------------------------
   procedure send_to_js(p_app_alias in apex_page_settings.aps_app_alias%type
                       ,p_page_id   in apex_page_settings.aps_page_id%type
                       )
   as
     l_aps_rec  apex_page_settings%rowtype;
   begin
     select *
     into   l_aps_rec
     from   apex_page_settings
     where  aps_app_alias = p_app_alias
     and    aps_page_id   = p_page_id
     ;
     htp.p(l_aps_rec.aps_page_settings);
   end send_to_js;
   ---------------------------------------------------------------------------------
end apex_page_settings_pck;
/


/*** Examples
in serverside condition of page:
apex_page_settings_pck.is_hidden
(p_app_alias      => '&APP_ALIAS.'
,p_page_id        => '&APP_PAGE_ID.'
,p_component_type => 'region'
,p_component_name => 'example_region'
)

Example JS calling a process getPageSettings

// A function to apply BU specific settings to an item.
function mdmApplyPageSettings(pageId){
  apex.server.process(
      'getPageSettings',                // Process or AJAX Callback name
      {x01: pageId},                    // Parameter "x01"
      {
        success: function (pData) {     // Success Javascript
         for (let item of pData){
           if (   document.getElementById(item.id + "_CONTAINER") 
               && item.type === "item" 
               && item.hidden === "false"
               && item.required === "true" 
               ) { 
               // add the required class
               document.getElementById(item.id + "_CONTAINER").classList.add('is-required');
             }
         }
        }
      }
    );
}


***/
