<%
On Error Resume Next

userId = Request.Form("userId")
courseId = Request.Form("courseId")

Set conn = Server.CreateObject("ADODB.Connection")
conn.Open "Provider=SQLOLEDB; Data Source=YOUR_SERVER; Initial Catalog=YOUR_DB; User Id=YOUR_USER; Password=YOUR_PASSWORD;"

sql = "UPDATE CourseProgress SET " & _
      "status = 'completed', " & _
      "completed = 1 " & _
      "WHERE userId = '" & userId & "' AND courseId = '" & courseId & "'"
conn.Execute(sql)

conn.Close
Set conn = Nothing

Response.ContentType = "application/json"
Response.Write "{""success"": true}"
%> 