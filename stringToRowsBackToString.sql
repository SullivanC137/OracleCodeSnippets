-- string to rows APEX installed
select column_value
from   table(apex_string.split(:USR_RLE,':')
;

-- pure SQL, no APEX. String to rows
with temp as
(
    select 108 Name, 'test' Project, 'Err1, Err2, Err3' Error  from dual
    union all
    select 109, 'test2', 'Err1' from dual
)
select distinct
  t.name, t.project,
  trim(regexp_substr(t.error, '[^,]+', 1, levels.column_value))  as error
from 
  temp t,
  table(cast(multiset(select level from dual connect by  level <= length (regexp_replace(t.error, '[^,]+'))  + 1) as sys.OdciNumberList)) levels
order by name
;

-- shorter way, again string to rows
with
    q_str as (select 'YOUR:COMMA:SEPARATED:STRING' str from dual)
select
    regexp_substr(str, '[^:]+', 1, level) cee_id 
from q_str
connect by level <= regexp_count(str, ':') + 1
;

-- rows to string
select listagg(rle_id, ':') within group (order by rle_id) 
from aut_usr_rle
where usr_id = :USR_ID
;
