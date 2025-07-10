<!--#include file="../classes/Authentication.asp"--><%
Dim Auth, requestAction, requestMethod, requestQuery

requestMethod = Request.ServerVariables("REQUEST_METHOD")
requestQuery = Request.ServerVariables("QUERY_STRING")
requestAction = Request.Form("action")

Set Auth = New Authentication
Auth.method = Request.Form("authType")

If requestMethod = "POST" and requestAction = "getUserData" Then
    Dim getUserData

    If Auth.isAuthenticated() = True Then
        getUserData = Auth.getUserJSON()
    Else
        getUserData = "{ ""error"": ""True"", ""error_msg"": ""Could not retrieve User Data."", ""error_type"": ""login"", ""data"":""Error while getting user data. (Sessions could not be found)"" }"
    End If

    Response.ContentType = "application/json"
    Response.Write getUserData

ElseIf requestMethod = "POST" and requestAction = "processUID" Then
    Response.ContentType = "application/json"
    Response.Write Auth.authenticate(Request.Form("userUID"), Request.Form("userEmail"))

ElseIf requestMethod = "POST" and requestAction = "UIDLogOut" Then
    Auth.removeSessions()
End If


Sub showCourses
    On Error Resume Next
    Dim courses, key, courseInfo
    Set courses = getCourseData()

    For Each key in courses.Keys
        courseInfo = courses(key)

        If IsArray(courseInfo) Then
            Dim encodedCourseId
            encodedCourseId = Server.URLEncode(courseInfo(1))
            Response.Write "<div class='course-container' data-target-course='" & encodedCourseId & "'>" & _
                    "<img src='" & courseInfo(5) & "'>" & _
                    "<div class='course-title'>" & courseInfo(0) & "</div>" & _
                    "<div class='course-description'></div>" & _
                    "</div>"
        Else
            Response.Write "Error: courseInfo is not an array for key: " & key & "<br>"
        End If
    Next

    If Err.Number <> 0 Then
        Response.Write "Error in showCourses: " & Err.Description
    End If
    On Error GoTo 0
End Sub

' Get an array (dictionary) of valid course directories & titles
Function getCourseData()
    On Error Resume Next

    Dim objFSO, objFolder, objSubFolder
    Dim strPath, courseDictionary, counter, courseInfo(6), thumbnail

    counter = 1
    thumbnail = "img/default_thumb.jpg"

    strPath = Server.MapPath("./courses")

    Set objFSO = Server.CreateObject("Scripting.FileSystemObject")
    If Err.Number <> 0 Then
        Response.Write "Error creating FSO: " & Err.Description & "<br>"
        Exit Function
    End If

    Set courseDictionary = CreateObject("Scripting.Dictionary")
    If Err.Number <> 0 Then
        Response.Write "Error creating Dictionary: " & Err.Description & "<br>"
        Exit Function
    End If

    If objFSO.FolderExists(strPath) Then
        Set objFolder = objFSO.GetFolder(strPath)

        For Each objSubFolder In objFolder.SubFolders

            If objFSO.FileExists(objSubFolder.Path & "\imsmanifest.xml") Then
                Dim thumbPath

                If objFSO.FileExists(objSubFolder.Path & "\thumb.jpg") Then
                    thumbPath = "courses/" & objSubFolder.Name & "/thumb.jpg"
                Else
                    thumbPath = thumbnail
                End If

                courseInfo(0) = getCourseTitle(objSubFolder.Path)
                courseInfo(1) = objSubFolder.Name
                courseInfo(2) = objSubFolder.Path
                courseInfo(3) = objSubFolder.DateCreated
                courseInfo(4) = objSubFolder.DateLastModified
                courseInfo(5) = thumbPath

                courseDictionary.Add counter, courseInfo
                counter = counter + 1

                If Err.Number <> 0 Then
                    Response.Write "<strong>Error Details for folder /" & objSubFolder.Name & ":<br>" & _
                                 "Source: " & Err.Source & "<br>" & _
                                 "Description: " & Err.Description & "</strong><br>"
                    Err.Clear
                End If
            End If
        Next

        Set objFolder = Nothing
    Else
        Response.Write "Debug: Courses folder not found at: " & strPath & "<br>"
    End If

    Set objFSO = Nothing
    Set getCourseData = courseDictionary

    If Err.Number <> 0 Then
        Response.Write "Error in getCourseData: " & Err.Description
    End If
    On Error GoTo 0
End Function

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