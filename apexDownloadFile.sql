/* code snippet to download a file.
This code should ideally be used on an Apex page which is specifically made as a target for file downloads.
Place this code in a process before header. This example gets data from a package.
*/

declare  
  l_extension       varchar2(10);
  l_file_clob    clob;
  l_file_blob    blob;
  l_dest_offset  integer := 1;
  l_src_offset   integer := 1;
  l_lang_context integer := 0;
  l_warning      integer := 0;
begin  
  --create file content
  l_file_clob := some_kind_of_package.get_file_contents; 
  l_extension := '.sql';
  -- convert to blob
  DBMS_LOB.CreateTemporary(l_file_blob, true);
  dbms_lob.converttoblob(dest_lob     => l_file_blob
                      ,src_clob     => l_file_clob
                      ,amount       => length(l_file_clob)
                      ,dest_offset  => l_dest_offset
                      ,src_offset   => l_src_offset
                      ,blob_csid    => 0
                      ,lang_context => l_lang_context
                      ,warning      => l_warning);
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
