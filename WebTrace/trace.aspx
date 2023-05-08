﻿<%@ Page Language="C#" CodeFile="trace.aspx.cs" Inherits="trace"%>


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
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePageMethods="true"></asp:ScriptManager>
        <div style="font-family: Tahoma;">
           <asp:UpdatePanel ID="UpdatePanel1" runat="server" UpdateMode="Conditional">
                <ContentTemplate>
                    <asp:TextBox ID="txtSort" runat="server" Visible="false"></asp:TextBox>
                    <table>
                        <tr>
                            <td>
                                <div style="margin-left: 10px; vertical-align: middle; height: 25px;">
                                    <span>Applications</span></div> 
                             <div>
                                 <asp:ListBox ID="lstApps" runat="server" Rows="20" Width="200" SelectionMode="Multiple" Style="float: left; margin: 10px;"></asp:ListBox>
                             </div>
                            </td>
                            <td>
                                <div style="margin-left: 10px; vertical-align: middle; width: 535px; height: 25px;">

                                    <span style="float: left;">Sessions &nbsp&nbsp&nbsp that start with: &nbsp<asp:TextBox ID="txtStartsWith" runat="server" Width="40" /></span>
                                    <span style="float: right;">
                                        <asp:Button ID="btnRefresh" runat="server" Text="Refresh" OnClick="btnRefresh_Click" />
                                        &nbsp;
                                        <asp:Button ID="btnRefreshAll" runat="server" Text="Refresh All" OnClick="btnRefreshAll_Click" />
                                        &nbsp;<asp:Button ID="btnView" runat="server" Enabled="False" OnClientClick="viewSession(document.getElementById('<%=lstSessions.ClientID%>').value);" Text="View" />
                                        &nbsp;<asp:Button ID="btnFields" runat="server" Enabled="False" OnClientClick="viewSession (document.getElementById('<%=lstSessions.ClientID%>').value);" Text="Fields" />
                                    </span>
                                </div>
                                <div>
                                    <asp:ListBox ID="lstSessions" runat="server" Rows="20" Width="535" Style="float: left; margin: 10px;" AutoPostBack="True" OnSelectedIndexChanged="lstSessions_SelectedIndexChanged"></asp:ListBox>
                                    <asp:HiddenField ID="hdnSessionID" runat="server" />
                                </div>
                            </td>
                            <td></td>
                        </tr>
                        <tr>
                            <td style="vertical-align: top;" colspan="3">
                                <div style="margin: 10px; color: #f00; display: block; width: 600px;">
                                    <asp:Label ID="lblStatus" runat="server" Text="" />
                                </div>
                                <div style="margin: 10px;">
                                    <asp:Button ID="btnStartTrace" runat="server" Text="Start Trace" OnClick="btnStartTrace_Click" OnClientClick="javascript: return CheckSessionSelection();" />
                                    &nbsp;<asp:Button ID="btnStopTrace" runat="server" Text="Stop Trace" OnClick="btnStopTrace_Click" />
                                    &nbsp;<asp:Button ID="btnGetDownloadLink" runat="server" OnClick="btnGetDownloadLink_Click" Text="Generate File" />
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
                            </td>

                        </tr>
                        <tr>
                            <td colspan="3" style="vertical-align: top;">

                                <div style="margin-left: 10px; vertical-align: bottom; height: 25px;">
                                    <span style="float: left;">Trace CBO Files:
                                       
                                        <asp:Label ID="lblCBOTraceFile" runat="server" Text="" /></span>
                                    <span style="float: right; margin-right: 10px;">
                                        <asp:Button ID="btnRefreshFiles" runat="server" Text="Refresh" OnClick="btnRefreshFiles_Click" Visible="false" />
                                        &nbsp;<asp:Button ID="btnRefreshAllFiles" runat="server" Text="Refresh All" OnClick="btnRefreshAllFiles_Click" Visible="false" />
                                        &nbsp;<asp:Button ID="btnSortFiles" runat="server" Text="Sort Old" OnClick="btnSortFiles_Click" Visible="false" />
                                        &nbsp;
                                        <asp:Button ID="btnZipFiles" runat="server" Enabled="False" Text="Zip" OnClick="btnZipFiles_Click" Visible="false" />
                                        &nbsp;
                                        <asp:Button ID="btnDownloadFile" runat="server" Enabled="False" Text="Download" OnClick="btnDownloadFile_Click" Visible="false" />
                                        &nbsp;
                                        <asp:Button ID="btnDeleteFile" runat="server" Enabled="False" Text="Delete" OnClick="btnDeleteFile_Click"
                                            OnClientClick="return confirm('Are you sure you want to delete the selected files?
                                        Click OK to delete or Cancel to stop.');"
                                            Visible="false" />
                                        &nbsp;
                                        <asp:Button ID="btnDeleteAll" runat="server" Enabled="False" Text="Delete All" OnClick="btnDeleteFile_Click" OnClientClick="return confirm('Are you sure you want to delete ALL the trace CBO files? Click OK to delete or Cancel to stop.');" Visible="false" />
                                    </span>
                                </div>
                                <div>
                                    <asp:ListBox ID="lstFiles" runat="server" Rows="20" Width="800" Style="float: left; margin: 10px;" AutoPostBack="True"
                                        OnSelectedIndexChanged="lstFiles_SelectedIndexChanged" SelectionMode="Multiple"></asp:ListBox>
                            </td>

                        </tr>
                        <tr>
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
