declare
  json_string varchar2(32000);
begin
  with tmp as 
  ( select 'today' mykey, to_char(sysdate, :APP_NLS_DATE_FORMAT) as myvalue
    from dual
    union
    select 'tomorrow' mykey, to_char(sysdate+1, :APP_NLS_DATE_FORMAT) as myvalue
    from dual
    union
    select 'yesterday' mykey, to_char(sysdate-1,: APP_NLS_DATE_FORMAT) as myvalue
    from dual
    union
    select 'thisweek' mykey, to_char(sysdate,'YYYYIW') as myvalue
    from dual
    union
    select 'nextweek' mykey, to_char(sysdate+7,'YYYYIW') as myvalue
    from dual
    union
    select 'def_fme' mykey, mod_pck.get_par('DEF FME') as myvalue
    from dual
    union
    select 'def_lnd' mykey, mod_pck.get_par('DEF LND') as myvalue
    from dual
  )
  select json_objectagg( mykey VALUE myvalue) 
  into   :P900_CYPRESS_SETTINGS
  from   tmp
  ;
exception when others then
  null;
end;
/

--

declare
  json_string varchar2(32000);
begin
  with tmp as 
  ( select id       hee_id
    ,      'hee_id' mykey
    from   trade_units
    where  creadat between (sysdate - 100) and (sysdate - 2)
    and    status = 'A'
    order  by creadat desc
    fetch first 3 rows only
  )
  select lower(json_arrayagg(json_object(hee_id)))
  into   :P900_SET_HEE_INACTIVE
  from   tmp
  ;
exception when others then
  null;
end;
/
