/*
In this environment SQLcl was NOT added to windows PATH to avoid compatibility issues with SQLplus
First start Powershell, then start sqlcl with:
  & "D:\Program Files\sqlcl\bin\sql.exe" /nolog
In sqlcl connect with:
  connect <username>@"jdbc:oracle:thin:@//<hostname>:<portnumber>/<servicename>"
We explicitly add thin client, because sqlcl automatically tries OCI. Reason unknown
*/

--export with:
apex export -applicationid 100
-- or with
apex export -applicationid 100 -dir D:\apex\exports
-- or to add comments:
apex export -applicationid 100 -expcomments
