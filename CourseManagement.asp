<%response.CacheControl = "no-cache"
response.AddHeader "Pragma", "no-cache"
response.Expires = -1
server.ScriptTimeout = 600
%>
<!--#include virtual = "/includes/serverInit.asp" -->
<%
	ProgramID = request("ProgramID")
	Mode = request("Mode")
	CourseID = request("CourseID")
	Active = request("Active")
	CourseName = request("CourseName")
	CourseLink = request("CourseLink")
	Checkbox = request("Checkbox")


	set cmd = Server.CreateObject("ADODB.Command")
	cmd.ActiveConnection = conSQL
	cmd.CommandText = "LMS.dbo.CourseManagement"
	cmd.CommandType = 4
	cmd.CommandTimeout = 0
	cmd.NamedParameters = true
	AddParm cmd, "@guid", 72, 0, guid
	AddParm cmd, "@ProgramID", 3, 0, ProgramID
	AddParm cmd, "@Mode", 3, 0, Mode
	AddParm cmd, "@CourseID", 3, 0, CourseID
	AddParm cmd, "@Active", 3, 0, Active
	AddParm cmd, "@AddOrRemoveProgram", 3, 0, Checkbox
	AddParm cmd, "@CourseName", 200, 100, CourseName
    AddParm cmd, "@CourseLink", 200, 200, CourseLink




	'showcommand(cmd)
	set recSet = Server.CreateObject("ADODB.Recordset")
	recSet.CursorLocation = 3
	on error resume next
	recSet.Open cmd
	if err <> 0 then
		response.Write err.Description 
		response.End
	end if
	on error goto 0

	if Request("mode") <> "" and Request("mode") <> "1" then
		response.end()
	end if
	
%>
<html lang="en" xmlns="http://www.w3.org/1999/xhtml">
<head>
<%ShowStandardHeaderItems() %>
<script>
	
	function PickProgram(ProgramID, CourseID, Checkbox){
		var checkValue = 0;
		if(Checkbox.checked){
			checkValue = 1;
		}
		var url = '<%=strtrim%>?Mode=3&ProgramID=' + String(ProgramID) + '&CourseID=' + String(CourseID) + '&Checkbox=' + checkValue;
		$.ajax({
			type: 'GET',
			url: url,
			success: function (response) {
				
			}
		});
	}

	function MakeActive(CourseID, Checkbox){
		var checkValue = 0;
		if(Checkbox.checked){
			checkValue = 1;
		}
		var url = '<%=strtrim%>?Mode=4&CourseID=' + String(CourseID) + '&Checkbox=' + checkValue;
		$.ajax({
			type: 'GET',
			url: url,
			success: function (response) {
				
			}
		});
	}

</script>
</head>
<body>
<%
	ShowPageHeader()
	doctitle = "Paperwork By Program Manager"
%>

<form name="formfilter" action="<%=strtrim%>" style="margin-top:10px;" method="get">
	<table>
		<tr>
			<th>Course Name</th>
			<td><input type="text" id="CourseName" name="CourseName"></td>
			<td><input type="hidden" id="mode" name="mode" value="1"></td>
		</tr>
		<tr>
			<th>Course Link</th>
			<td><input type="text" id="CourseLink" name="CourseLink" ></td>
			<td><button type="submit">Add</button></td>
		</tr>
	</table>
</form>

<!--#include virtual = "/includes/gridDisplay.asp" -->
<%
on error goto 0
%>
</body>
</html>
