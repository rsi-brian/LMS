<%
Dim conSQL
Session.Timeout = 60
Response.CacheControl = "no-cache"
Response.AddHeader "Pragma", "no-cache"
Response.AddHeader "Expires", "0"

%><!--#include virtual="/includes/dbConn.asp"--><%

Class Authentication
    Private RSILoggedIn, isRSI, nameSpace, userAttributes, ATTUID, RSIGUID, GUIDLength, UIDLength, lastError, lastErrorMsg, secretKey, authType
    Private DealerNumber, DealerName, UserName, UserDesc, UserEmail, UserType, ActiveProgList, RSIZone, ProgramEmail    ' RSI global variables

    Public Sub Class_Initialize()
        authType        = "rsi"
        GUIDLength      = 38                                                                                            ' GUIDs are 38 chars long
        UIDLength       = 6                                                                                             ' ATTUIDs are 6 chars long
        lastError       = 0
        lastErrorMsg    = ""
        nameSpace       = "_Auth_"
        secretKey       = "e7a650e18f7966d20075132164a790abc9ba1a936f44aa12573c2d2f5bf92046"
        RSILoggedIn     = getRSILogin()
        RSIZone         = processGUID()
        isRSI           = isRSICorp()
        ATTUID          = getUID()
        userAttributes  = Array("dealernumber", "email", "programemail", "firstname", "lastname", "attuid", "guid")
    End Sub


  '*' GETTERS '*'
    Public Property Get NS()
        NS = nameSpace
    End Property

    Public Property Get UID()
        UID = ATTUID
    End Property

    Public Property Get GUID()
        GUID = RSIGUID
    End Property

    Public Property Get GUIDLen()
        GUIDLen = GUIDLength
    End Property

    Public Property Get UIDLen()
        UIDLen = UIDLength
    End Property

    Public Property Get method()
        If Len(Session(nameSpace & "authtype")) > 1 Then
            method = Session(nameSpace & "authtype")
        Else
            method = authType
        End If
    End Property


  '*' SETTERS '*'
    Public Property Let method(val)
        If Not IsEmpty(val) And Len(val) > 1 Then
            authType = LCase(val)
            Session(nameSpace & "authtype") = authType
        End If
    End Property


  '*' PRIVATE METHODS '*'
    Private Function getRSILogin()                                                                                      ' Check to see if the user is logged into the actual RS&I site
        If Len(Session("guid")) <> GUIDLength And Len(Request.Cookies("UserID")) <> GUIDLength Then                     ' User is not logged in if a GUID does not exist
            RSIGUID = ""
            getRSILogin = False
        Else
            If Len(Session("guid")) = GUIDLength Then
                RSIGUID = Session("guid")
            ElseIf Len(Request.Cookies("UserID")) = GUIDLength Then 
                RSIGUID = Request.Cookies("UserID")
            End If

            getRSILogin = True
        End If
    End Function

    Private Function processGUID()                                                                                      ' Get the user's information if they are logged into the actual RS&I site
        If Len(RSIGUID) <> GUIDLength Then
            processGUID = ""
            Exit Function
        End If

        Dim cmd, recSet
        Set cmd = Server.CreateObject("ADODB.Command")
        With cmd
            .ActiveConnection = conSQL
            .CommandText = "WEB.dbo.WEB_LoginVerify"
            .CommandType = 4
            .CommandTimeout = 0
            .NamedParameters = true
            .Parameters.Append .CreateParameter("@guid", 72, 1, , RSIGUID)
            .Parameters.Append .CreateParameter("@ipaddress", 200, 1, 15, Request.ServerVariables("REMOTE_ADDR"))
            .Parameters.Append .CreateParameter("@browserver", 200, 1, 200, left(trim(Request.ServerVariables("HTTP_USER_AGENT")), 200))
            .Parameters.Append .CreateParameter("@DomainId", 17, 1, , 1)
        End With

        set recSet = Server.CreateObject("ADODB.Recordset")
            recSet.CursorLocation = 3
            recSet.Open cmd

        If not recSet.EOF Then
            If recSet(0) = "ok" Then
                DealerNumber = trim(recSet("DealerNumber"))
                DealerName = trim(recSet("DealerName"))
                UserName = trim(recSet("UserName"))
                UserDesc = trim(recSet("UserDesc"))
                UserEmail = trim(recSet("UserEmail"))
                RSIZone = trim(recSet("LoginRSIZone"))
                UserType = trim(recSet("UserType"))
                ActiveProgList = trim(recSet("ActiveProgList"))                                                         ' We may need this
            Else
                If recSet.State = 1 Then
                    recSet.Close()
                End If
                set recSet = nothing
                set cmd = nothing
            End If
        Else
            If recSet.State = 1 Then
                recSet.Close()
            End If
            set recSet = nothing
            set cmd = nothing
        End If

        If recSet.State = 1 Then
            recSet.Close()
        End If
        set recSet = nothing
        set cmd = nothing

        processGUID = RSIZone
    End Function

    Private Function isRSICorp()
        isRSICorp = (Len(RSIGUID) = GUIDLength And RSIZone <> "" And RSIZone <> "D")
    End Function

    Private Function getUID()
        Dim UID
        UID = Session(nameSpace & "attuid")
        If IsEmpty(UID) Or Len(UID) = 0 Then
            getUID = ""
        Else
            getUID = UID
        End If
    End Function

    Private Function sanitize(UID, email)
        Dim uidPattern, emailPattern, isValid, regEx

        ' Check if parameters are provided
        If Len(UID) = 0 Or Len(email) = 0 Then
            sanitize = "ATTUID and Email are required."
            Exit Function
        End If

        ' Define regex patterns
        uidPattern = "^[a-zA-Z0-9]{6}$"                                                                                 ' Not sure if I can use UIDLength here, so I will leave it as-is
        emailPattern = "^[^\s@]+@[^\s@]+\.[^\s@]+$"

        ' Create RegExp object for UID validation
        Set regEx = New RegExp
        regEx.Pattern = uidPattern
        regEx.IgnoreCase = True
        regEx.Global = False

        ' Validate UID using RegExp
        isValid = regEx.Test(UID)
        If Not isValid Then
            sanitize = "ATTUID must be exactly " & UIDLength & " characters long, numbers and letters only."
            Exit Function
        End If

        ' Create RegExp object for email validation
        Set regEx = New RegExp
        regEx.Pattern = emailPattern
        regEx.IgnoreCase = True
        regEx.Global = False

        ' Validate email using RegExp
        isValid = regEx.Test(email)
        If Not isValid Then
            sanitize = "Email must be in the format: something@example.com"
            Exit Function
        End If

        ' Return sanitized values
        sanitize = Array(UID, email)
    End Function

    Private Function createSessions(userArray)                                                                          ' Log in, effectively
        Dim i, result, userDealerNumber, userEmail, userProgramEmail, userFirstName, userLastName, userUID, userGUID
        result = "pancakes"
        userDealerNumber = 0                                                                                            ' Adding these for better readability
        userEmail = 1                                                                                                   ' TODO: Create a Dictionary for these?
        userProgramEmail = 2
        userFirstName = 3
        userLastName = 4
        userUID = 5
        userGUID = 6

        ' THIS IS JUST FOR DEBUGGING
        ' Response.Write("{ ""error"":""True"", ""error_msg"":""Reporting all userArray values. Check the Dev Console."", ""userArray(0)"":"""&userArray(0)&""", ""userArray(1)"":"""&userArray(1)&""", ""userArray(2)"":"""&userArray(2)&""", ""userArray(3)"":"""&userArray(3)&""", ""userArray(4)"":"""&userArray(4)&""", ""userArray(5)"":"""&userArray(5)&""", ""userArray(6)"":"""&userArray(6)&""", ""error_type"":""DEBUG"", ""result"":"""&result&""" }")

        On Error Resume Next
        Response.Buffer = True
        Response.Clear

        removeSessions()                                                                                                ' We want to start with a clean slate

        If (userArray(userUID) = "" And userArray(userGUID) = "") Or _
                (userArray(userEmail) = "" And userArray(userProgramEmail) = "") Or _
                (userArray(userDealerNumber) = "" Or userArray(userFirstName) = "" Or userArray(userLastName) = "") Then
            result = False
        End If

        If result <> False Then
            For i = 0 To UBound(userAttributes)
                If Not IsEmpty(userArray(i)) Then
                    Session(nameSpace & userAttributes(i)) = userArray(i)
                    result = True                                                                                       ' Yes, I know, it's going to keep setting it to True, but
                End If
            Next
        End If

        If Err.Number <> 0 Then
            result = False                                                                                              ' So IF an error occurs, we will return False. The next line will create an error so we can at least see something in the console.
            Response.Write("{ ""error"":""True"", ""error_msg"":""Error while creating sessions. " & Err.Description & """, ""error_type"":""DEBUG"", ""Err.Source"":""" & Err.Source & """, ""Err.Line"":""" & Err.Erl & """, ""Err.StackTrace"":""" & Err.StackTrace & """ }")
        End If
        On Error GoTo 0

        createSessions = result
    End Function

    Private Function createRSIUser()                                                                                    ' Automagically log in RSI Corp users because they might not have an ATTUID
        If isRSI = True Then                                                                                            ' The login form is pretty much useless at this point, but we won't tell them that 😜
            Dim RSIInfo, fname, lname
            If InStr(UserDesc, " ") > 0 Then
                fname = Split(UserDesc, " ")(0)
                lname = Split(UserDesc, " ")(1)
            Else
                fname = UserDesc
                lname = ""
            End If
            RSIInfo = Array(561099, UserEmail, ProgramEmail, fname, lname, UserName, GUID)                              ' Dealer 561099 is RS&I
            createSessions(RSIInfo)
            createRSIUser = getUserJSON()
        End If
    End Function


  '*' PUBLIC METHODS '*'
    Public Function authenticate(UID, email)
        Dim rs, sql, aUser(6), sanitized, loginUID, loginEmail

        If RSILoggedIn = True Then                                                                                      ' TODO: Adapt this to work with dealers as well
            authenticate = createRSIUser()
            Exit Function
        End If

        On Error Resume Next
        sanitized = sanitize(UID, email)

        If Err.Number <> 0 Then
            authenticate = "{""error"":""True"",""error_msg"":""Authentication Error: " & Err.Description & """,""error_type"":""login""}"
            Err.Clear
            Exit Function
        Else
            If IsArray(sanitized) Then                                                                                  ' Check if sanitized is an array (array === valid) and handle accordingly
                Dim result, i
                result = ""
                loginUID = sanitized(0)
                loginEmail = sanitized(1)

                conSQL.execute("Use ATT")

                sql = "SELECT Top (1) DealerNumber, b.Email, a.ProgramEmail, b.FirstName, b.LastName, a.SubAgent AS UID, '' AS GUID " & _
                    "FROM dealer.dbo.SalesRepDealer a " & _
                    "JOIN dealer.dbo.SalesRep b " & _
                        "ON a.SalesRepId = b.SalesRepId " & _
                    "WHERE a.ProgramId = 33 AND a.SubAgent = '" & loginUID & "' " & _
                        "AND (b.Email = '" & loginEmail & "' OR a.ProgramEmail = '" & loginEmail & "')"

                Set rs = Server.CreateObject("ADODB.Recordset")
                rs.Open sql, conSQL

                Do While Not rs.EOF
                    For i = 0 To rs.Fields.Count - 1
                        If i > 0 Then result = result & ","
                        aUser(i) = rs.Fields(i).Value
                        result = result & """" & LCase(rs.Fields(i).Name) & """:""" & rs.Fields(i).Value & """"
                    Next
                    rs.MoveNext
                Loop

                If Len(result) = 0 Then
                    result = """error"":""True"",""error_msg"":""Authentication failed: User not found."",""error_type"":""login"",""data"":""" & sql & """"
                Else
                    csr = createSessions(aUser)
                    If csr = False Then
                        result = """error"":""True"",""error_msg"":""Authentication failed: Could not create sessions.""," & _
                            """error_type"":""login"",""data"":""" & sql & """, ""result"":{"&result&"}"
                    End If
                End If

                authenticate = "{" & result & "}"

                rs.Close
                Set rs = Nothing
            Else
                authenticate = "{""error"":""True"",""error_msg"":""Verification failed. " & sanitized & """,""error_type"":""login""}"
            End If
        End If
        On Error GoTo 0
    End Function

    Public Function isAuthenticated()
        ' If Len(Session(nameSpace & "email")) <= 6 Then                                                                  '*' email address will *ALWAYS* be required
        '     isAuthenticated = False
        ' ElseIf method = "attuid" Then
        If method = "attuid" Then
            isAuthenticated = (Len(Session(nameSpace & "attuid")) = UIDLength Or Len(Session(nameSpace & "guid")) = GUIDLength)
        ElseIf method = "rsi" Then
            If isRSI = True And Len(Session(nameSpace & "guid")) <> GUIDLength And Len(UserEmail) > 15 Then
                createRSIUser()
                isAuthenticated = True
            Else
                isAuthenticated = (isRSI = True And Len(Session(nameSpace & "guid")) = GUIDLength)
            End If
        ElseIf method = "dealer" Then
            isAuthenticated = RSILoggedIn = True And isRSI = False And Len(Session(nameSpace & "dealernumber")) = 6
        ElseIf method = "email" Then
            isAuthenticated = Len(Session(nameSpace & "salesrepname")) > 6 And Len(Session(nameSpace & "dealernumber")) = 6
        Else
            isAuthenticated = False
        End If
    End Function

    Public Function getUserJSON()
        Dim userJSON, i
        userJSON = ""
        For i = 0 To UBound(userAttributes)
            If i > 0 Then userJSON = userJSON & ","
            userJSON = userJSON & """" & userAttributes(i) & """:""" & _
                Session(nameSpace & userAttributes(i)) & """"
        Next
        getUserJSON = "{" & userJSON & "}"
    End Function

    Public Sub removeSessions()                                                                                         ' Log out
        Dim userAttribute
        For Each userAttribute In userAttributes
            If Not IsEmpty(Session(nameSpace & userAttribute)) Then
                Session.Contents.Remove(nameSpace & userAttribute)
            End If
        Next
    End Sub

End Class
%>