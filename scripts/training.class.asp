<!--#include virtual="/includes/classes/Authentication.asp"--><%
' ASP Class for RS&I LMS
' Written by Brian Heath for RS&I, Inc.
' February 3, 2025

Class RSI_Training
    Private isRSI, RSI_GUID, UserFirstName, CourseList


    Public Property Get FirstName()
        FirstName = UserFirstName
    End Property



  '*' INITIAL SUBROUTINE
	Private Sub Class_Initialize
        isRSI = False                                           ' DEFAULTING TO DEALER VIEW
        If (RSIZone <> "" And RSIZone <> "D") Then
            isRSI = True
        ElseIf (RSIZone = "" And UserRSIZone <> "" And UserRSIZone <> "D") Then
            isRSI = True
        End If

        ' Get the user's first name because addressing them by their full name every time is a bit weird
        If UserDesc <> "" Then UserFirstName = Split(UserDesc, " ")(0)
        iF GUID <> "" Then RSI_GUID = guid
    End Sub



  '*' PUBLIC PROCEDURES

    Public Sub showCourses
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

        ' If Err.Number <> 0 Then
        '     Response.Write "Error in showCourses: " & Err.Description
        ' End If
        On Error GoTo 0
    End Sub



  '*' PRIVATE PROCEDURES
    ' Private Function getCourseList()
    '     ' Get the list of available courses somewhere...
    '     ' How do we want to identify them?
    '     getCourseList = Array("", "", "", "", "")
    ' End Function

    ' Get an array (dictionary) of valid course directories & titles
    Private Function getCourseData()
        On Error Resume Next

        Dim objFSO, objFolder, objSubFolder
        Dim strPath, courseDictionary, counter, courseInfo, thumbnail

        counter = 1
        thumbnail = "img/default_thumb.jpg"

        strPath = Server.MapPath("./courses")
        ' Response.Write "Debug: Course path: " & strPath & "<br>"

        Set objFSO = Server.CreateObject("Scripting.FileSystemObject")
        ' If Err.Number <> 0 Then
        '     Response.Write "Error creating FSO: " & Err.Description & "<br>"
        '     Exit Function
        ' End If

        Set courseDictionary = CreateObject("Scripting.Dictionary")
        ' If Err.Number <> 0 Then
        '     Response.Write "Error creating Dictionary: " & Err.Description & "<br>"
        '     Exit Function
        ' End If

        If objFSO.FolderExists(strPath) Then
            Set objFolder = objFSO.GetFolder(strPath)
            ' Response.Write "Debug: Found courses folder<br>"

            For Each objSubFolder In objFolder.SubFolders
                ' Response.Write "<br>Debug: Processing subfolder: " & objSubFolder.Name & "<br>"

                If objFSO.FileExists(objSubFolder.Path & "\imsmanifest.xml") Then
                    ' Explicitly redimension the array for each iteration; Dim courseInfo throws a Type Mismatch error
                    ReDim courseInfo(6)
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

                    ' Response.Write "Debug: Adding to dictionary - Counter: " & counter & "<br>"
                    ' Response.Write "Debug: Course Title: " & courseInfo(0) & "<br>"

                    courseDictionary.Add counter, courseInfo
                    counter = counter + 1

                    ' If Err.Number <> 0 Then
                    '     Response.Write "<strong>Error Details for folder /" & objSubFolder.Name & ":<br>" & _
                    '                  "Source: " & Err.Source & "<br>" & _
                    '                  "Description: " & Err.Description & "</strong><br>"
                    '     Err.Clear
                    ' End If
                End If
            Next

            Set objFolder = Nothing
        Else
            Response.Write "Debug: Courses folder not found at: " & strPath & "<br>"
        End If

        Set objFSO = Nothing
        Set getCourseData = courseDictionary

        ' If Err.Number <> 0 Then
        '     Response.Write "Error in getCourseData: " & Err.Description
        ' End If
        On Error GoTo 0
    End Function

    Private Function getCourseTitle(path)
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

End Class
%>