-- rows to string
select listagg(rle_id, ':') within group (order by rle_id) 
from aut_usr_rle
where usr_id = :USR_ID
;
