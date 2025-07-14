<%
' cybersecurity.asp - Classic ASP webhook to receive, append, and dump POST data

Option Explicit

Dim allowedOrigin, requestOrigin
    allowedOrigin = "https://testweb.rsiinc.com"
    requestOrigin = Request.ServerVariables("HTTP_ORIGIN")

If requestOrigin = allowedOrigin Then
    Response.AddHeader "Access-Control-Allow-Origin", allowedOrigin
End If
Response.AddHeader "Access-Control-Allow-Methods", "POST, GET, OPTIONS"
Response.AddHeader "Access-Control-Allow-Headers", "Content-Type"

If Request.ServerVariables("REQUEST_METHOD") = "OPTIONS" Then
    Response.Status = "204 No Content"
    Response.End
End If

' Set the file path where POST data will be appended
Dim FILEPATH
FILEPATH = Server.MapPath("cybersecurity_data.txt")

' Helper to get the raw request body of a POST
Function GetRequestBody()
    Dim bytesCount, rawBody, binaryStream
    bytesCount = Request.TotalBytes
    If bytesCount > 0 Then
        Set binaryStream = Server.CreateObject("ADODB.Stream")
        binaryStream.Type = 1 'adTypeBinary
        binaryStream.Open
        binaryStream.Write Request.BinaryRead(bytesCount)
        binaryStream.Position = 0
        binaryStream.Type = 2 'adTypeText
        binaryStream.Charset = "utf-8"
        rawBody = binaryStream.ReadText
        binaryStream.Close
        Set binaryStream = Nothing
        GetRequestBody = rawBody
    Else
        GetRequestBody = ""
    End If
End Function

' Main logic
If Request.ServerVariables("REQUEST_METHOD") = "POST" Then
    Dim postData, fso, fileOut, timeStamp

    ' Get the POST body as url-encoded string
    postData = GetRequestBody()

    ' Add timestamp for tracking
    timeStamp = Now()
    
    ' Append postData to file (with timestamp and separator)
    Set fso = Server.CreateObject("Scripting.FileSystemObject")
    If Not fso.FileExists(FILEPATH) Then
        Set fileOut = fso.CreateTextFile(FILEPATH, True)
    Else
        Set fileOut = fso.OpenTextFile(FILEPATH, 8, True)
    End If
    fileOut.WriteLine "----- " & timeStamp & " -----"
    fileOut.WriteLine postData
    fileOut.WriteLine "---------------------------"
    fileOut.Close
    Set fileOut = Nothing
    Set fso = Nothing

    ' Optionally, respond with success
    Response.ContentType = "text/plain"
    Response.Write "OK"
    Response.End
ElseIf Request.QueryString("dump") = "1" Then
    ' Dump all received data back to the browser for review/parsing
    Dim fso2, fileIn, allData
    Set fso2 = Server.CreateObject("Scripting.FileSystemObject")
    If fso2.FileExists(FILEPATH) Then
        Set fileIn = fso2.OpenTextFile(FILEPATH, 1)
        allData = fileIn.ReadAll
        fileIn.Close
        Response.ContentType = "text/plain"
        Response.Write allData
    Else
        Response.ContentType = "text/plain"
        Response.Write "No data file found."
    End If
    Set fso2 = Nothing
    Response.End
' Else
'    ' Display a simple page for GET requests
'    Response.ContentType = "text/html"
' %->
' <!DOCTYPE html>
' <html>
' <head>
'     <title>Cybersecurity Webhook Endpoint</title>
' </head>
' <body>
'     <h2>Cybersecurity Webhook Endpoint</h2>
'     <p>This endpoint accepts POSTs from the server, appends them to <code>cybersecurity_data.txt</code>, and can dump contents via <code>?dump=1</code>.</p>
' </body>
' </html>
' <-%
End If
%>