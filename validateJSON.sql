-- use is json to check for valid json text
with iv_json_text as
(select '{"id":1,"key":"value","validity":true}' as txt from dual
union all
 select '{"id":2,123key":"value","validity":false}' as txt from dual
)
select txt from iv_json_text
where txt is json;
