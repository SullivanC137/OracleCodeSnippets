declare    
    l_test     clob;
    l_test_arr dbmsoutput_linesarray := dbmsoutput_linesarray();
    function get_dbms_output
        return dbmsoutput_linesarray
    as
        l_output dbmsoutput_linesarray;
        l_linecount number;
    begin
        dbms_output.get_lines(l_output, l_linecount);
        if l_output.count > l_linecount then
             -- Remove the final empty line above l_linecount
           l_output.trim;
        end if;
        return l_output;
    end get_dbms_output;
begin
    dbms_output.enable;
    DBMS_OUTPUT.PUT_LINE('line 1');
    DBMS_OUTPUT.PUT_LINE('line 2');
    DBMS_OUTPUT.PUT_LINE('line 3');
    DBMS_OUTPUT.PUT_LINE('line 4');
    l_test_arr := get_dbms_output();
    for i in l_test_arr.first .. l_test_arr.last loop
    l_test := l_test||' - '||l_test_arr(i);
    end loop;
    DBMS_OUTPUT.PUT_LINE(l_test);
end;
/
