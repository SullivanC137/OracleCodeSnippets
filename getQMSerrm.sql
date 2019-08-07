  /* How to get errors out of standard forms environment*/
  
  --set serveroutput on;
declare
   l_message_rectype_tbl hil_message.message_tabtype;
   l_message_count number := 0;
   l_raise_error   boolean := false;
   l_error         varchar2(2000);
begin

<< job naam >>

   cg$errors.get_error_messages
   ( l_message_rectype_tbl
   , l_message_count
   , l_raise_error
   );

   if l_message_count > 0
   then
      for i in 1..l_message_count loop
         l_error := cg$errors.get_display_string 
                    ( p_msg_code => l_message_rectype_tbl(i).msg_code
                    , p_msg_text => l_message_rectype_tbl(i).msg_text
                    , p_msg_type => l_message_rectype_tbl(i).severity
                    );
         while length(l_error) > 255
         loop
              dbms_output.put_line(substr(l_error,1,255));
              l_error := substr(l_error,256);
         end loop;               
         dbms_output.put_line(l_error);
      end loop;
   end if;
end;
--/
