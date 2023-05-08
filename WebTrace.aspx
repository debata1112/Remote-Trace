<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="WebTrace.aspx.cs" Inherits="RemoteTrace.WebTrace" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <script type="text/javascript">
        function viewSession(url, sessionId) {
            window.open(url + sessionId, "_blank");
        }
        function CheckSessionSelection() {
            var sessionId = document.getElementById('<%=lstSessions.ClientID%>').value;
            if (sessionId == '') {
                var selectedOption = confirm('You are trying to Trace all the active sessions which may' +
                    ' impact the performance of the CL Policy Servicing application.' +
                    'If this is a business hour and is not absolutely necessary then we recommend you to perform this during off hours to avoid any impact to the server.' +
                    ' Or, select a single Session to Trace. \n\n\n' +
                    'Click OK to trace all active sessions or Cancel to return.');

                if (selectedOption == false)
                    return false;
                else {
                    document.getElementById('hdnSessionID').value = "AllSessions";
                }
            }
            else {
                document.getElementById('hdnSessionID').value = sessionId;
            }
        }
    </script>
    <link rel="stylesheet" href="Content\bootstrap.css" />
    <link rel="stylesheet" href="Content\Site.css" />
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePageMethods="true"></asp:ScriptManager>
        <div style="font-family: Tahoma; width: 60%; margin-left:10%;">
            <asp:UpdatePanel ID="UpdatePanel1" runat="server" UpdateMode="Conditional">
                <ContentTemplate>
                    <asp:TextBox ID="txtSort" runat="server" Visible="false"></asp:TextBox>
                    <div style="width: 100%">
                        <div style="float: left; width: 30%">
                            <div style="margin-left: 10px; vertical-align: middle; height: 25px;">
                               <h4>Applications</h4>
                            </div>
                            <div>
                                <asp:ListBox ID="lstApps" runat="server" Rows="20" Width="70%" SelectionMode="Multiple" Style="float: left; margin: 10px;"></asp:ListBox>
                            </div>
                        </div>
                        <div style="float: left; width: 60%">
                                <h4>Sessions</h4>
                                <span>Filter: <asp:TextBox ID="txtStartsWith" runat="server" /></span>
                                <span>
                                    <asp:Button ID="btnRefresh" runat="server" Text="Refresh" OnClick="btnRefresh_Click" CssClass="btn btn-primary" />
                                    &nbsp;
                                        <asp:Button ID="btnRefreshAll" runat="server" Text="Refresh All" OnClick="btnRefreshAll_Click" CssClass="btn btn-primary" />
                                    &nbsp;<asp:Button ID="btnView" runat="server" Visible="false" CssClass="btn btn-primary" OnClientClick="viewSession(document.getElementById('<%=lstSessions.ClientID%>').value);" Text="View" />
                                    &nbsp;<asp:Button ID="btnFields" runat="server" Visible="false" CssClass="btn btn-primary" OnClientClick="viewSession(document.getElementById('<%=lstSessions.ClientID%>').value);" Text="Fields" />
                           
                                <asp:ListBox ID="lstSessions" runat="server" Rows="20" Style="float: left; margin: 10px; width:100% !important" AutoPostBack="True" OnSelectedIndexChanged="lstSessions_SelectedIndexChanged"></asp:ListBox>
                                <asp:HiddenField ID="hdnSessionID" runat="server" />
                        </div>
                    </div>
                    <div style="clear: both"></div>
                    <center>
                        <div style="margin: 10px; color: #f00; display: block; width: 600px;">
                            <asp:Label ID="lblStatus" runat="server" Text="" />
                        </div>
                        <div style="margin: 10px;">
                            <asp:Button ID="btnStartTrace" runat="server" Text="Start Trace" CssClass="btn btn-primary" OnClick="btnStartTrace_Click" OnClientClick="javascript: return CheckSessionSelection();" />
                            &nbsp;<asp:Button ID="btnStopTrace" runat="server" Text="Stop Trace" CssClass="btn btn-primary" OnClick="btnStopTrace_Click" />
                            &nbsp;<asp:Button ID="btnGetDownloadLink" runat="server" CssClass="btn btn-primary" OnClick="btnGetDownloadLink_Click" Text="Generate File" />
                            &nbsp;<asp:Label ID="lblFileSize" runat="server" Text="" />
                            &nbsp;<asp:Label ID="lblTime" runat="server" Text="" />
                            <input id="txtListenerId" runat="server" hidden="hidden" style="visibility: hidden;" />
                            <asp:TextBox ID="txtFileName" runat="server" Width="300px" Visible="false"></asp:TextBox>
                            <asp:UpdateProgress ID="UpdateProgress1" runat="server" AssociatedUpdatePanelID="UpdatePanel1">
                                <ProgressTemplate>
                                    Processing...
                                </ProgressTemplate>
                            </asp:UpdateProgress>
                        </div>
                        <div style="margin: 10px; display: none;">
                            <br />
                            Start, Time:&nbsp;&nbsp;
                                    <asp:TextBox ID="txtStartTime" runat="server" Width="300px" Visible="true"></asp:TextBox>
                            <br />
                            Finish Time:&nbsp;
                                    <asp:TextBox ID="txtfinishTime" runat="server" Width="300px" Visible="true"></asp:TextBox>
                        </div>

                        <div style="margin: 10px; display: block;">
                            <asp:Panel ID="pnlFile" Visible="false" runat="server"></asp:Panel>
                            <asp:Button ID="btnZip" runat="server" Text="Get Zip" Visible="false" OnClick="btnZip_Click" />
                        </div>
                    </center>
                    <table>
                        <tr style="visibility: hidden">
                            <td colspan="3" style="vertical-align: top;">
                                <div style="margin-left: 10px; vertical-align: bottom; height: 25px;">
                                    <span style="float: left;">Trace CBO Files:
                                        <asp:Label ID="lblCBOTraceFile" runat="server" Text="" /></span>
                                </div>
                                <div>
                                    <asp:ListBox ID="lstFiles" runat="server" Rows="20" Width="800" Style="float: left; margin: 10px;" AutoPostBack="True"
                                        OnSelectedIndexChanged="lstFiles_SelectedIndexChanged" SelectionMode="Multiple"></asp:ListBox>
                            </td>

                        </tr>
                        <tr>
                            <td>
                                <asp:Button ID="btnRefreshFiles" runat="server" Text="Refresh" OnClick="btnRefreshFiles_Click" Visible="false" />
                                &nbsp;<asp:Button ID="btnRefreshAllFiles" runat="server" Text="Refresh All" OnClick="btnRefreshAllFiles_Click" Visible="false" />
                                &nbsp;<asp:Button ID="btnSortFiles" runat="server" Text="Sort Old" OnClick="btnSortFiles_Click" Visible="false" />
                                &nbsp;
                                        <asp:Button ID="btnZipFiles" runat="server" Enabled="False" Text="Zip" OnClick="btnZipFiles_Click" Visible="false" />
                                &nbsp;
                                        <asp:Button ID="btnDownloadFile" runat="server" Text="Download" OnClick="btnDownloadFile_Click" />
                                &nbsp;
                                        <asp:Button ID="btnDeleteFile" runat="server" Enabled="False" Text="Delete" OnClick="btnDeleteFile_Click"
                                            OnClientClick="return confirm('Are you sure you want to delete the selected files?
                                        Click OK to delete or Cancel to stop.');"
                                            Visible="false" />
                                &nbsp;
                                        <asp:Button ID="btnDeleteAll" runat="server" Enabled="False" Text="Delete All" OnClick="btnDeleteFile_Click" OnClientClick="return confirm('Are you sure you want to delete ALL the trace CBO files? Click OK to delete or Cancel to stop.');" Visible="false" />
                            </td>
                        </tr>
                        <tr style="visibility: hidden">
                            <td colspan="2" style="vertical-align: top;">
                                <div style="margin-left: 10px; vertical-align: bottom; height: 25px;">
                                    <span style="float: left;">Active Trace Listeners</span>
                                    <span style="float: right; margin-right: 405px;">
                                        <asp:Button ID="btnCloseListener" runat="server" Text="Close" OnClick="btnCloseListener_Click" />
                                        &nbsp;<asp:Button ID="btnRefreshListeners" runat="server" Text="Refresh" OnClick="btnRefreshListeners_Click" />
                                    </span>
                                </div>
                                <div>
                                    <asp:ListBox ID="lstListeners" runat="server" Rows="20" Width="400" Style="float: left; margin: 10px;" SelectionMode="Single"></asp:ListBox>
                                </div>
                            </td>
                        </tr>
                    </table>
                </ContentTemplate>
            </asp:UpdatePanel>
        </div>
        <asp:Timer ID="tmrFileSize" runat="server" Enabled="False" Interval="5000" OnTick="tmrFileSize_Tick">
        </asp:Timer>

    </form>
</body>
</html>
