<%
' ASP CLASS FOR UID AUTHENTICATION AND VERIFICATION
' Written by Brian Heath for RS&I, Inc.
' February 24, 2025

Class UID
    Private RSI_GUID, UserFirstName

  '*' INITIAL SUBROUTINE
	Private Sub Class_Initialize
        UserFirstName = Split(UserDesc, " ")(0)
        RSI_GUID = guid
    End Sub

  '*' Public Methods

  '*' Private Methods

End Class
%>