<!--#include file = "../../includes/serverinit.asp"-->
<%
Dim varName

Response.Write "<h3>Session Variables</h3>"
Response.Write "ActiveProgList = " & ActiveProgList & "<br>"
Response.Write "OrigRSIZone = " & OrigRSIZone & "<br>"
Response.Write "RSIZone = " & RSIZone & "<br>"
Response.Write "UserRSIZone = " & UserRSIZone & "<br>"
Response.Write "UserName = " & UserName & "<br>"
Response.Write "UserEmail = " & UserEmail & "<br>"
Response.Write "UserDesc = " & UserDesc & "<br>"
Response.Write "-------------------------------------------------------------<br>"
For Each varName In Session.Contents
    Response.Write varName & " = " & Session.Contents(varName) & "<br>"
    ' Response.Write varName & " = " & Session(varName) & "<br>"
Next

Response.Write "<h3>Application Variables</h3>"
For Each varName In Application.Contents
    Response.Write varName & " = " & Application.Contents(varName) & "<br>"
    ' Response.Write varName & " = " & Application(varName) & "<br>"
Next

Response.Write "<h3>Server Variables</h3>"
For Each varName In Request.ServerVariables
    ' Response.Write varName & " = " & Request.ServerVariables.Contents(varName) & "<br>"
    Response.Write varName & " = " & Request.ServerVariables(varName) & "<br>"
Next
%>