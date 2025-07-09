<%
On Error Resume Next

userId = Request.QueryString("userId")
courseId = Request.QueryString("courseId")

Set conn = Server.CreateObject("ADODB.Connection")
conn.Open "Provider=SQLOLEDB; Data Source=YOUR_SERVER; Initial Catalog=YOUR_DB; User Id=YOUR_USER; Password=YOUR_PASSWORD;"

sql = "SELECT * FROM CourseProgress WHERE userId = '" & userId & "' AND courseId = '" & courseId & "'"
Set rs = conn.Execute(sql)

If Not rs.EOF Then
    Response.ContentType = "application/json"
    Response.Write "{""userId"":""" & rs("userId") & """," & _
                   """courseId"":""" & rs("courseId") & """," & _
                   """status"":""" & rs("status") & """," & _
                   """lastPage"":" & rs("lastPage") & "," & _
                   """score"":" & rs("score") & "," & _
                   """completed"":" & rs("completed") & "}"
Else
    Response.ContentType = "application/json"
    Response.Write "{""error"": ""No progress found""}"
End If

rs.Close
conn.Close
Set rs = Nothing
Set conn = Nothing
%> 