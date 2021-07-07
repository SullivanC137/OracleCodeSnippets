/*
This is an example of how to find records with a string column value with errors in TOAD.
For example MINI HIGHLIGHTER LİKİT AYDINLATICI is displayed as MINI HIGHLIGHTER L�� AYDINLATICI 

--> Use the hex value of EFBFBD
*/

create table some_strings
(
    str_value varchar2(4000)
)
/
with non_ascii as
(select str_value, replace(translate(str_value, convert(str_value,'us7ascii'), 'x'), 'x') non_ascii
 from   some_strings
 where  replace(translate(str_value, convert(str_value,'us7ascii'), 'x'), 'x') is not null
)
  select na.* ,rawtohex(na.non_ascii) hex
  from   non_ascii na
  where  instr(rawtohex(na.non_ascii),'EFBFBD') >= 1
  ;