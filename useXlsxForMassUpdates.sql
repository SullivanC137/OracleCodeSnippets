drop table imp_xlsx;

create table imp_xlsx
(
id         number        not null,
name       varchar2(200) not null, --> filename
upl_date   date          default sysdate not null ,
xlsx       blob,
dml_script clob --> store dml script used
);  

comment on table imp_xlsx is q'#
--example code
--upload test.xlsx then run:
select c.*
from   imp_xlsx ix,
       table(apex_data_parser.parse
               (p_content      => ix.xlsx,
                p_file_name       => 'test.xlsx'
               )
             ) c
where  ix.name = 'test.xlsx'
;
#';
