/* code snippet to download a file.
This code should ideally be used on an Apex page which is specifically made as a target for file downloads.
Place this code in a process before header. This example gets data from a package.
*/

declare  
  l_file_clob       clob;
  l_file_blob       blob;
  l_extension       varchar2(10);
  o1 integer;
  o2 integer;
  c integer;
  w integer;
begin  
  --create file content
  l_file_clob := some_kind_of_package.get_file_contents; 
  l_extension := '.sql';
  -- convert to blob
  o1 := 1;
  o2 := 1;
  c := 0;
  w := 0;
  DBMS_LOB.CreateTemporary(l_file_blob, true);
  DBMS_LOB.ConvertToBlob(l_file_blob, l_file_clob, length(l_file_clob), o1, o2, 0, c, w);
  --download file  
  htp.init;  
  owa_util.mime_header(  
    'text/plain',  
    false  
  );  
  htp.p('Content-length: ' ||sys.dbms_lob.getlength(l_file_blob) );  
  htp.p('Content-Disposition: attachment; filename="' || upper(:P999_FILENAME_NAME) ||l_extension|| '"');  
  --htp.p('Cache-Control: max-age=3600');  -- tell the browser to cache for one hour,adjust as necessary  
  owa_util.http_header_close;  
  wpg_docload.download_file(l_file_blob);
  apex_application.stop_apex_engine;  
end;  
