<!--#include virtual="/includes/Authentication/Authentication.asp"--><%
Dim Auth, requestAction, requestMethod, requestQuery

requestMethod = Request.ServerVariables("REQUEST_METHOD")
requestQuery = Request.ServerVariables("QUERY_STRING")
requestAction = Request.Form("action")
securityToken = Request.Form("token")

Set Auth = New Authentication


If requestMethod = "POST" and requestAction = "getUserData" Then                                                        ' TODO: We will use this for getting all of the logged in user's data
    Response.ContentType = "application/json"
    Response.Write Auth.getUserJSON()

ElseIf requestMethod = "POST" and requestAction = "getLogin" Then
    Response.ContentType = "application/json"
    Response.Write Auth.getLogin(securityToken)

ElseIf requestMethod = "POST" and requestAction = "processLogin" Then
    Response.ContentType = "application/json"
    Response.Write Auth.authenticate(Request.Form("userEmail"), Request.Form("userUID"), securityToken)

ElseIf requestMethod = "POST" and requestAction = "saveCourseData" Then
    On Error Resume Next
    Dim localSQL
    Set localSQL = Server.CreateObject("ADODB.Connection")
        localSQL.Open "Driver={SQL Server};Server=localhost\MSSQLSERVER01;Database=master;Trusted_Connection=True;"
        localSQL.CommandTimeout = 10

    If Err.Number <> 0 Then
        Auth.WriteLog "File function.asp -> Error connecting to the local database. " & Err.Source & ": " & Err.Description
    End If
    On Error GoTo 0

    Response.ContentType = "application/json"
    Response.Write writeCMIDataToDB(Request.Form("courseID"), Request.Form("identifier"), Request.Form("cmiData"))

ElseIf requestMethod = "POST" and requestAction = "logOut" Then
    Auth.removeSessions()
End If


Function writeCMIDataToDB(courseID, identifier, cmiData)
    Dim isValidCourseID
    isValidCourseID = False
    If IsNumeric(courseID) Then
        isValidCourseID = True
        courseID = CLng(courseID)
    End If

    If Not isValidCourseID Then
        Auth.WriteLog "writeCMIDataToDB() -> Invalid courseID: " & courseID
        writeCMIDataToDB = Auth.jsonError("Invalid courseID.", "course", courseID & ", " & identifier)
        Exit Function
    End If

    If IsObject(cmiData) Then
        Auth.WriteLog "writeCMIDataToDB() -> OOPS!! cmiData is an OBJECT!!!!  😲😬"
    End If

    On Error Resume Next
    Dim cmd
    Set cmd = Server.CreateObject("ADODB.Command")
    With cmd
        .ActiveConnection = conSQL
        .CommandText = "LMS.dbo.SaveCMIData"
        .CommandType = 4
        .CommandTimeout = 0
        .NamedParameters = True
        .Parameters.Append .CreateParameter("@JSON", 201, 1, 4000, cmiData)                                             ' varchar(MAX) field type - REQUIRED
        .Parameters.Append .CreateParameter("@courseID", 3, 1, , courseID)                                              ' int field type - REQUIRED
    End With

    cmd.Execute
    Set cmd = Nothing

    If Err.Number <> 0 Then
        Auth.WriteLog "writeCMIDataToDB() -> An error occurred while saving the CMI Data. " & Err.Source & ": " & Err.Description
        Auth.WriteLog "writeCMIDataToDB() -> courseID: " & courseID & ", identifier: " & identifier
        Auth.WriteLog "writeCMIDataToDB() -> cmiData: " & cmiData
        writeCMIDataToDB = Auth.jsonError("An error occurred while saving the CMI Data.", "course", courseID & ", " & identifier & ", " & cmiData)
        Err.Clear
        Exit Function
    End If
    On Error GoTo 0
    
    Auth.WriteLog "writeCMIDataToDB() -> " & courseID
    Auth.WriteLog "writeCMIDataToDB() -> " & identifier
    Auth.WriteLog "writeCMIDataToDB() -> " & cmiData

    writeCMIDataToDB = "{""success"":""true""}"
End Function

Sub showCourses
    If IsEmpty(Auth.firstName) Then
        Response.Redirect("/training/login.asp")
    End If

    On Error Resume Next
    Dim courses, course, key, courseLink, courseFolder, fso, folderPath, urlPath, manifestPath, thumbPath, imgSrc, matches, re

    Set courses = Auth.courses
    Set fso = Server.CreateObject("Scripting.FileSystemObject")
    Set re = New RegExp
    re.IgnoreCase = True
    re.Global = False
    ' Only match a folder name, or things like courses/folder or /training/courses/folder
    re.Pattern = "^(?:/?training/)?courses/([^/\\]+)/*$|^([^/\\]+)$"

    If courses.Count = 0 Then
        Response.Write "No courses found."
    Else
        For Each key In courses
            Set course = courses(key)
            courseLink = course("CourseLink")
            courseFolder = ""

            Set matches = re.Execute(courseLink)
            If matches.Count > 0 Then
                If matches(0).SubMatches(0) <> "" Then
                    courseFolder = matches(0).SubMatches(0)
                ElseIf matches(0).SubMatches(1) <> "" Then
                    courseFolder = matches(0).SubMatches(1)
                End If
            End If

            If courseFolder = "" Then
                Auth.WriteLog "showCourses -> Skipping invalid CourseLink: " & courseLink
            Else
                urlPath = "/training/courses/" & courseFolder & "/"
                folderPath = Server.MapPath("courses\" & courseFolder & "\")
                manifestPath = fso.BuildPath(folderPath, "imsmanifest.xml")
                thumbPath = fso.BuildPath(folderPath, "thumb.jpg")
                imgSrc = "img/default_thumb.jpg"

                If Not fso.FolderExists(folderPath) Then
                    Auth.WriteLog "showCourses -> Directory does not exist: " & folderPath
                ElseIf Not fso.FileExists(manifestPath) Then
                    Auth.WriteLog "showCourses -> imsmanifest.xml does not exist: " & folderPath
                Else
                    If fso.FileExists(thumbPath) Then imgSrc = urlPath & "thumb.jpg"

                    Response.Write _
                        "<div class=""course-container"" data-target-course=""" & Server.HTMLEncode(courseFolder) & """" & _
                        " data-course-id=""" & Server.HTMLEncode(course("CourseID")) & """>" & _
                        "<img src=""" & Server.HTMLEncode(imgSrc) & """>" & _
                        "<div class=""course-title"">" & Server.HTMLEncode(course("CourseName")) & "</div>" & _
                        "<div class=""course-description""></div>" & _
                        "</div>"
                End If
            End If
        Next
    End If

    If Err.Number <> 0 Then
        Auth.WriteLog "Sub showCourses -> " & Err.Source & " -> " & Err.Description
        Response.Write "No courses found."
    End If
    On Error GoTo 0
End Sub

' Sub showCourses
    ' If IsEmpty(Auth.firstName) Then
    '     Response.Redirect("/training/login.asp")
    ' End If

    ' On Error Resume Next
    ' Dim courses, course, key, courseFolder, fso, folderPath, urlPath, manifestPath, thumbPath, imgSrc

    ' Set courses = Auth.courses
    ' Set fso = Server.CreateObject("Scripting.FileSystemObject")

    ' If courses.Count = 0 Then
    '     Response.Write "No courses found."
    ' Else
    '     For Each key in courses
    '         Set course = courses(key)
    '         courseFolder = course("CourseLink")
    '         urlPath = "/training/courses/" & courseFolder & "/"
    '         folderPath = Server.MapPath("courses\" & courseFolder & "\")
    '         manifestPath = fso.BuildPath(folderPath, "imsmanifest.xml")
    '         thumbPath = fso.BuildPath(folderPath, "thumb.jpg")
    '         imgSrc = "img/default_thumb.jpg"

    '         If Not fso.FolderExists(folderPath) Then
    '             Auth.WriteLog "showCourses -> Directory does not exist: " & folderPath
    '         ElseIf Not fso.FileExists(manifestPath) Then
    '             Auth.WriteLog "showCourses -> imsmanifest.xml does not exist: " & folderPath
    '         Else
    '             If fso.FileExists(thumbPath) Then imgSrc = urlPath & "thumb.jpg"

    '             Response.Write _
    '                 "<div class='course-container' data-target-course='" & Server.HTMLEncode(courseFolder) & "'>" & _
    '                 "<img src='" & Server.HTMLEncode(imgSrc) & "'>" & _
    '                 "<div class='course-title'>" & Server.HTMLEncode(course("CourseName")) & "</div>" & _
    '                 "<div class='course-description'></div>" & _
    '                 "</div>"
    '         End If
    '     Next
    ' End If

    ' If Err.Number <> 0 Then
    '     Auth.WriteLog "Sub showCourses -> " & Err.Source & " -> " & Err.Description
    '     Response.Write "No courses found."
    ' End If
    ' On Error GoTo 0
' End Sub

' Sub showCourses
    ' If IsEmpty(Auth.firstName) Then
    '     Response.Redirect("/training/login.asp")
    ' End If

    ' On Error Resume Next
    ' Dim courses, course, key, courseKey, coursePath, fso, folderPath, urlPath, manifestPath, thumbPath, imgSrc

    ' Set courses = Auth.courses
    ' Set fso = Server.CreateObject("Scripting.FileSystemObject")

    ' If courses.Count = 0 Then
    '     Response.Write "No courses found."
    ' Else
    '     For Each key in courses
    '         Set course = courses(key)
    '         urlPath = course("CourseLink")

    '         If InStrRev(urlPath, "/") > 0 Then urlPath = Left(urlPath, InStrRev(urlPath, "/"))
    '         If Right(urlPath, 1) <> "/" Then urlPath = urlPath & "/"
    '         ' If Left(urlPath, 1) <> "/" Then urlPath = "/training/courses/" & urlPath

    '         folderPath   = Server.MapPath(Replace(urlPath, "/", "\"))
    '         manifestPath = fso.BuildPath(folderPath, "imsmanifest.xml")
    '         thumbPath    = fso.BuildPath(folderPath, "thumb.jpg")
    '         imgSrc       = "img/default_thumb.jpg"

    '         If Not fso.FolderExists(folderPath) Then
    '             Auth.WriteLog "showCourses -> Directory does not exist: " & folderPath
    '         ElseIf Not fso.FileExists(manifestPath) Then
    '             Auth.WriteLog "showCourses -> imsmanifest.xml does not exist: " & folderPath
    '         Else
    '             If fso.FileExists(thumbPath) Then imgSrc = urlPath & "thumb.jpg"

    '             Response.Write _
    '                 "<div class='course-container' data-target-course='" & Server.HTMLEncode(urlPath) & "'>" & _
    '                 "<img src='" & imgSrc & "'>" & _
    '                 "<div class='course-title'>" & course("CourseName") & "</div>" & _
    '                 "<div class='course-description'></div>" & _
    '                 "</div>"
    '         End If
    '     Next
    ' End If

    ' If Err.Number <> 0 Then
    '     Auth.WriteLog "Sub showCourses -> " & Err.Source & " -> " & Err.Description
    '     Response.Write "No courses found."
    ' End If
    ' On Error GoTo 0
' End Sub

' Sub showCourses
    '     If IsEmpty(Auth.firstName) Then
    '         Response.Redirect("/training/login.asp")
    '     End If

    '     On Error Resume Next
    '     Dim courses, course, key, courseKey, thumbnail
    '     Set courses = Auth.courses
    '     thumbnail = "img/default_thumb.jpg"

    '     If courses.Count = 0 Then
    '         Response.Write "No courses found."
    '     Else
    '         For Each key in courses
    '             Set course = courses(key)
    '             Response.Write _
    '                 "<div class='course-container' data-target-course='" & course("CourseLink") & "'>" & _
    '                 "<img src='" & course("CourseLink") & thumbnail & "'>" & _
    '                 "<div class='course-title'>" & course("CourseName") & "</div>" & _
    '                 "<div class='course-description'></div>" & _
    '                 "</div>"
    '         Next
    '     End If

    '     If Err.Number <> 0 Then
    '         Auth.WriteLog "Sub showCourses -> " & Err.Source & " -> " & Err.Description
    '         Response.Write "No courses found."
    '     End If
    '     On Error GoTo 0
' End Sub

' Sub showCourses
    '     If IsEmpty(Auth.firstName) Then
    '         Response.Redirect("/training/login.asp")
    '     End If
    '     On Error Resume Next
    '     Dim courses, key, courseInfo
    '     Set courses = getCourseData()

    '     For Each key in courses.Keys
    '         courseInfo = courses(key)

    '         If IsArray(courseInfo) Then
    '             Dim encodedCourseId
    '             encodedCourseId = Server.URLEncode(courseInfo(1))
    '             Response.Write "<div class='course-container' data-target-course='" & encodedCourseId & "'>" & _
    '                     "<img src='" & courseInfo(5) & "'>" & _
    '                     "<div class='course-title'>" & courseInfo(0) & "</div>" & _
    '                     "<div class='course-description'></div>" & _
    '                     "</div>"
    '         Else
    '             Response.Write "Error: courseInfo is not an array for key: " & key & "<br>"
    '         End If
    '     Next

    '     If Err.Number <> 0 Then
    '         Response.Write "Error in showCourses: " & Err.Description
    '     End If
    '     On Error GoTo 0
' End Sub

' Get an array (dictionary) of valid course directories & titles
' Function getCourseData()
    '     On Error Resume Next

    '     Dim objFSO, objFolder, objSubFolder
    '     Dim strPath, courseDictionary, counter, courseInfo(6), thumbnail

    '     counter = 1
    '     thumbnail = "img/default_thumb.jpg"

    '     strPath = Server.MapPath("./courses")

    '     Set objFSO = Server.CreateObject("Scripting.FileSystemObject")
    '     If Err.Number <> 0 Then
    '         Response.Write "Error creating FSO: " & Err.Description & "<br>"
    '         Exit Function
    '     End If

    '     Set courseDictionary = CreateObject("Scripting.Dictionary")
    '     If Err.Number <> 0 Then
    '         Response.Write "Error creating Dictionary: " & Err.Description & "<br>"
    '         Exit Function
    '     End If

    '     If objFSO.FolderExists(strPath) Then
    '         Set objFolder = objFSO.GetFolder(strPath)

    '         For Each objSubFolder In objFolder.SubFolders

    '             If objFSO.FileExists(objSubFolder.Path & "\imsmanifest.xml") Then
    '                 Dim thumbPath

    '                 If objFSO.FileExists(objSubFolder.Path & "\thumb.jpg") Then
    '                     thumbPath = "courses/" & objSubFolder.Name & "/thumb.jpg"
    '                 Else
    '                     thumbPath = thumbnail
    '                 End If

    '                 courseInfo(0) = getCourseTitle(objSubFolder.Path)
    '                 courseInfo(1) = objSubFolder.Name
    '                 courseInfo(2) = objSubFolder.Path
    '                 courseInfo(3) = objSubFolder.DateCreated
    '                 courseInfo(4) = objSubFolder.DateLastModified
    '                 courseInfo(5) = thumbPath

    '                 courseDictionary.Add counter, courseInfo
    '                 counter = counter + 1

    '                 If Err.Number <> 0 Then
    '                     Response.Write "<strong>Error Details for folder /" & objSubFolder.Name & ":<br>" & _
    '                                  "Source: " & Err.Source & "<br>" & _
    '                                  "Description: " & Err.Description & "</strong><br>"
    '                     Err.Clear
    '                 End If
    '             End If
    '         Next

    '         Set objFolder = Nothing
    '     Else
    '         Response.Write "Debug: Courses folder not found at: " & strPath & "<br>"
    '     End If

    '     Set objFSO = Nothing
    '     Set getCourseData = courseDictionary

    '     If Err.Number <> 0 Then
    '         Response.Write "Error in getCourseData: " & Err.Description
    '     End If
    '     On Error GoTo 0
' End Function

Function getCourseTitle(path)
    Dim xmlDoc, objXML, titleNode
    Set objXML = Server.CreateObject("MSXML2.DOMDocument")

    objXML.async = False
    objXML.load(path & "\imsmanifest.xml")

    Set titleNode = objXML.selectSingleNode("//organizations/organization/title")

    If Not titleNode Is Nothing Then
        getCourseTitle = titleNode.text
    Else
        getCourseTitle = "Training Course"
    End If

    Set titleNode = Nothing
    Set objXML = Nothing
End Function

%>