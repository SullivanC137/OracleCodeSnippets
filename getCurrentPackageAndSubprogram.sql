-- use this to get the package and procedure name without hard coding
l_module      varchar2(60) := substr(utl_call_stack.concatenate_subprogram(utl_call_stack.subprogram(1)),1,60);
