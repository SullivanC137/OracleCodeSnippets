with
    q_str as (select 'YOUR:COMMA:SEPARATED:STRING' str from dual)
select
    regexp_substr(str, '[^:]+', 1, level) cee_id 
from q_str
connect by level <= regexp_count(str, ':') + 1
;
