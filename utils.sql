-- rows to string
select listagg(rle_id, ':') within group (order by rle_id) 
from aut_usr_rle
where usr_id = :USR_ID
;

-- string to rows
select column_value
from   table(apex_string.split(:USR_RLE,':')
