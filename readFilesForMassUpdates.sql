drop table imp_file;

create table imp_file
(
id           number        not null,
name         varchar2(200) not null, --> filename
upl_date     date          default sysdate not null ,
file_content blob,
dml_script   clob --> store dml script used
);  

comment on table imp_file is q'#
--example code
--upload test.xlsx then run:
select c.*
from   imp_file ix,
       table(apex_data_parser.parse
               (p_content      => ix.file_content,
                p_file_name    => 'test.xlsx'
               )
             ) c
where  ix.name = 'test.xlsx'
;
#';
