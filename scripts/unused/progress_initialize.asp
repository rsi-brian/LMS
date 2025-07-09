<%
' Enable error handling
On Error Resume Next

' Get form data
userId = Request.Form("userId")
courseId = Request.Form("courseId")

' Create database connection
Set conn = Server.CreateObject("ADODB.Connection")
conn.Open "Provider=SQLOLEDB; Data Source=YOUR_SERVER; Initial Catalog=YOUR_DB; User Id=YOUR_USER; Password=YOUR_PASSWORD;"

' Check if progress exists
sql = "SELECT * FROM CourseProgress WHERE userId = '" & userId & "' AND courseId = '" & courseId & "'"
Set rs = conn.Execute(sql)

If rs.EOF Then
    ' Insert new progress record
    sql = "INSERT INTO CourseProgress (userId, courseId, status, lastPage, score, completed) " & _
          "VALUES ('" & userId & "', '" & courseId & "', 'incomplete', 0, 0, 0)"
    conn.Execute(sql)
End If

' Close connections
rs.Close
conn.Close
Set rs = Nothing
Set conn = Nothing

' Return JSON response
Response.ContentType = "application/json"
Response.Write "{""success"": true}"
%> 