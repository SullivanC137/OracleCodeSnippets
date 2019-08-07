/* Example date format check */
-- codesnippet
declare
-- date checks
  lc_dateformat  constant varchar2(20) := 'dd-mm-yyyy';
  --  ORA-01858: a non-numeric character found where a digit was expected
  e_date_error01 exception;
  pragma         exception_init (e_date_error01, -1858);
  --  ORA-01861: literal does not match format string
  e_date_error02 exception;
  pragma         exception_init (e_date_error02, -1861);
  --  ORA-01841: (full) year must be between -4713 and +9999, and not be 0
  e_date_error03 exception;
  pragma         exception_init (e_date_error03, -1841);
  l_dummy        date;
  --  ORA-01843: not a valid month
  e_date_error04 exception;
  pragma         exception_init (e_date_error04, -1843);
begin
  l_dummy := to_date('FooBar',lc_dateformat);
exception
  when e_date_error01
    or e_date_error02
    or e_date_error03
    or e_date_error04
  then raise_application_error('Incorrect dateformat. Expected: '||lc_dateformat);
end;
/
