<%
response.Buffer = true
response.ExpiresAbsolute = Now() - 1
response.Expires = 0
response.CacheControl = "no-cache"
server.ScriptTimeout = 600

%>
<!--#include virtual="/includes/serverInit.asp" -->
<%
action = replace(lcase(request("action"))," ","")

if action <> "" then
	set cmd = Server.CreateObject("ADODB.Command")
	cmd.ActiveConnection = conSQL
	cmd.CommandText = "LMS.dbo.CMITypeEdit"
	cmd.CommandType = 4
	cmd.CommandTimeout = 0
	cmd.NamedParameters = true
	AddParm cmd, "@guid",72,0,guid
	AddAllParameters("lf, viewpage")
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

	if left(action,4) <> "view" and left(action,4) <> "edit" then
		ProcessResults action
		response.End
	end if
	showgrid=true
end if
ProcessMsg
%>
<html lang="en">
<head>
<%ShowStandardHeaderItems() %>
</head>
<body>
<%ShowPageHeader() 
TableWidth = ""

if left(action,4)="edit" then
	OutputEditForm mid(request("action"),5)
	set recset = recset.NextRecordset
	if not(recset is nothing) then
		if not recset.eof then 
			OutputGridDisplay
		end if
	end if

else
%>
<form name="formfilter" action="<%=strtrim%>" method="get" style="margin-bottom:0;">
<div style="position:relative;top:5px;width:800px; padding-top:5px; padding-bottom:5px;">
	<table class="filter">
		<tr>
			<th>CMI TypeID</th>
			<td><input type="text" name="cmitypeid" id="cmitypeid" size="5" tabindex="1" /></td>
			<td colspan=3 style="width:100%"></td>
		</tr>
		<tr>
			<th>CMI Name</th>
			<td><input type="text" name="cminame" id="cminame" size="14" tabindex="1" /></td>
			<td colspan=3 style="width:100%"></td>
		</tr>
		<tr>
			<td></td>
			<td></td>
		<td colspan="5">
			<input type="submit" value="View" id="action" name="action" tabindex="100" style="margin-right:20px;"/>
			<input type="reset" value="Clear" id="reset1" name="reset1" tabindex="999" style="margin-right:20px;" />
		</tr>
	</table>
</div>
</form>
<%
	AutoloadFromQueryString("")

	if showgrid then
		OutputGridDisplay
		set recSet = recSet.NextRecordSet
		if not recSet is nothing then
			if not recSet.EOF then
				'doctitle ="Funding Details"
				OutputGridDisplay
			end if
		end if
	end if
end if
%>
<!--#include virtual= "/includes/AutoEdit.asp" -->
</body>
</html>
