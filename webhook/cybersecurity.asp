<%
' cybersecurity.asp - Classic ASP webhook to receive, append, and dump POST data as proper JSON

Option Explicit

Dim allowedOrigin, requestOrigin
    allowedOrigin = "https://www.rsiinc.com"
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

Dim FILEPATH
    FILEPATH = Server.MapPath("cybersecurity_data.json")

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

' Helper to escape characters for JSON strings
Function JsonEscape(str)
    str = Replace(str, "\", "\\")
    str = Replace(str, """", "\""")
    str = Replace(str, "/", "\/")
    str = Replace(str, vbFormFeed, "\f")
    str = Replace(str, vbNewLine, "\n")
    str = Replace(str, vbCr, "\r")
    str = Replace(str, vbTab, "\t")
    JsonEscape = str
End Function

' Helper to append a JSON object to a JSON array file
Sub AppendJsonObjectToFile(jsonObj, filePath)
    Dim fso, fileObj, fileContents, arr
    Set fso = Server.CreateObject("Scripting.FileSystemObject")
    If fso.FileExists(filePath) Then
        Set fileObj = fso.OpenTextFile(filePath, 1)
        fileContents = fileObj.ReadAll
        fileObj.Close
        fileContents = Trim(fileContents)
        ' Remove the closing bracket ]
        If Right(fileContents, 1) = "]" Then
            fileContents = Left(fileContents, Len(fileContents) - 1)
            ' If array already has entries, add a comma
            If InStrRev(fileContents, "[") < Len(fileContents) - 1 Then
                fileContents = fileContents & "," & vbCrLf
            End If
        End If
        ' Append the new object and close the array
        Set fileObj = fso.OpenTextFile(filePath, 2)
        fileObj.Write fileContents & jsonObj & vbCrLf & "]"
        fileObj.Close
    Else
        Set fileObj = fso.CreateTextFile(filePath, True)
        fileObj.WriteLine "[" & vbCrLf & jsonObj & vbCrLf & "]"
        fileObj.Close
    End If
    Set fileObj = Nothing
    Set fso = Nothing
End Sub


If Request.ServerVariables("REQUEST_METHOD") = "POST" Then
    Dim postData, fso, timeStamp, jsonObj

    ' Get the POST body as a string
    postData = GetRequestBody()

    ' Add timestamp for tracking (ISO 8601 format)
    timeStamp = Year(Now()) & "-" & Right("0" & Month(Now()), 2) & "-" & Right("0" & Day(Now()), 2) & "T" & _
        Right("0" & Hour(Now()), 2) & ":" & Right("0" & Minute(Now()), 2) & ":" & Right("0" & Second(Now()), 2)

    ' Save as a JSON object (raw POST data as string)
    jsonObj = "{" & _
        """timestamp"":""" & JsonEscape(timeStamp) & """," & _
        """data"":""" & JsonEscape(postData) & """" & _
        "}"

    ' Append to JSON array file
    Call AppendJsonObjectToFile(jsonObj, FILEPATH)

    Response.ContentType = "application/json"
    Response.Write "{""status"":""OK""}"
    Response.End

ElseIf Request.QueryString("dump") = "1" Then
    ' Dump all received data back to the browser for review/parsing
    Dim fso2, fileIn, allData
    Set fso2 = Server.CreateObject("Scripting.FileSystemObject")
    If fso2.FileExists(FILEPATH) Then
        Set fileIn = fso2.OpenTextFile(FILEPATH, 1)
        allData = fileIn.ReadAll
        fileIn.Close
        Response.ContentType = "application/json"
        Response.Write allData
    Else
        Response.ContentType = "application/json"
        Response.Write "[]"
    End If
    Set fso2 = Nothing
    Response.End

Else
    Response.Status = "405 Method Not Allowed"
    Response.End
End If
%>