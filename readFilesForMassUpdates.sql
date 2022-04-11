drop table imp_file;

create table imp_file
(
id           number        not null,
name         varchar2(200) not null, --> filename
upl_date     date          default sysdate not null ,
file_content blob,         --> the actual file
dml_script   clob          --> store dml script used
);  

comment on table imp_file is q'#
-- example code
-- upload test.xlsx then run:
-- to check worksheet names
select c.*
from   imp_file ix,
table (apex_data_parser
         .get_xlsx_worksheets
           (p_content =>ix.file_content
           )
       ) c
where  ix.name = 'test.xlsx'
;

-- to fetch data on first sheet
select c.*
from   imp_file ix,
       table(apex_data_parser.parse
               (p_content         => ix.file_content,
                p_file_name       => 'test.xlsx',
                p_xlsx_sheet_name => 'sheet1.xml'
               )
             ) c
where  ix.name = 'test.xlsx'
;
#';
