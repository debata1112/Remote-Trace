using System;
using System.Collections;
using System.Collections.Generic;
using System.Configuration;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Web.Caching;
using System.Web.Services;
using System.Web.UI.WebControls;
using System.Xml.Linq;
using System.Xml.XPath;
using System.IO.Compression;
using System.Net.Http;
using System.Text;
using System.Xml;


/// <summary>
/// Summary description for Class1
/// </summary>
public partial class WebTrace : System.Web.UI.Page
{
    CacheItemRemovedCallback onRemove = null;
    string traceDirectory = "D:\\data\\logs\\trace\\";
    string optimSanitizeFields = string.Empty;
    string sanitizedTracePath = string.Empty;
    //List<CHSElement> CHSElements = new List<CHSElement>();
    string currentEnv = string.Empty;
    protected void Page_Load(object sender, EventArgs e)
    {
        traceDirectory = GetFilesDirectory();
        optimSanitizeFields = System.Configuration.ConfigurationManager.AppSettings["OptimSanitizeFields"];
        sanitizedTracePath = System.Configuration.ConfigurationManager.AppSettings["SanitizedTracePath"];
        currentEnv = System.Configuration.ConfigurationManager.AppSettings["ENV"].ToUpper();
        if (!IsPostBack)
        {
            if (!Directory.Exists(traceDirectory))
            {
                Directory.CreateDirectory(traceDirectory);

                if (Request.QueryString["f"] != null)
                {
                    string traceDir = traceDirectory;
                    if (Request.QueryString["<"] == null)
                    {
                        string username = User.Identity.Name.Replace("\\", "");
                        traceDir = Path.Combine(traceDir, username);
                        bool isZipFile = true; // Request.QueryString["z"] == "¡";
                                               //sanitizedTracePath
                                               //string traceFilePath = Path. Combine(traceDir, Request QueryString["f"] + (isZipFile ? " zip" : " dettrace™));
                        string traceFilePath = Path.Combine(sanitizedTracePath, Request.QueryString["f"]);
                        FileInfo traceFileInfo = new FileInfo(traceFilePath); //using the FileInfo class in order to get the absolute path to the file
                        StreamFile(isZipFile, traceFileInfo);
                    }
                }
            }
            else
            {

                btnView.OnClientClick = "viewSession('" + Request.Url.PathAndQuery.ToLower().Replace("jump", "DuckCreek").Replace("webtrace.aspx", "viewsession.aspx?sessionid='") + ", document.getElementById('" + lstSessions.ClientID + "').value);";
                btnFields.OnClientClick = "VLewSession('" + Request.Url.PathAndQuery.ToLower().Replace("jump", "DuckCreek").Replace("webtrace.aspx", "sessionfields.aspx?sessionid='") + ", document.getElementBId('" + lstSessions.ClientID + "').value).";
                //get applications list < Diagnostics.getApplicationLista /> make the username and password come from textboxes or config
                var getApplicationListRq = new XElement("server",
                    new XElement("requests",
                        new XElement("Session.loginRq",
                            new XAttribute("userName", "admin"),
                            new XAttribute("password", "admin")
                        //new XAttribute("useDomainInUserName", "")
                        ),
                        new XElement("Diagnostics.getApplicationListRq"),
                        new XElement("Session.closeRq")
                ));
                var getApplicationLists = ExecuteRequest(getApplicationListRq);
                var DCTApps = getApplicationLists.XPathSelectElements("responses/Diagnostics.getApplicationListRs/DCTApp");
                foreach (XElement app in DCTApps)
                {
                    ListItem appItem = new ListItem(app.Value);
                    appItem.Selected = true;
                    lstApps.Items.Add(appItem);
                }
                GetSessions();
                btnStartTrace.Enabled = true;
                btnStopTrace.Enabled = false;
                tmrFileSize.Enabled = false;
                btnGetDownloadLink.Enabled = false;

                GetFiles();
                //GetListeners();
            }
        }
    }
    private void GetListeners()
    {
        var getListenersRq = new XElement("server",
                new XElement("requests",
                    new XElement("Session.loginRq",
                        new XAttribute("userName", ""),
                        new XAttribute("password", "")
                        //new XAttribute("useDomainInUserName", "1")
                        ),
                    new XElement("PGR_CommercialLines_Trace.ProcessRequestRq",
                    new XAttribute("action", "listAllListeners")),
                    new XElement("Session.closeRq")
                 ));
        var getListenersRs = ExecuteRequest(getListenersRq);
        if (!ShowError(getListenersRs, "PG_CommercialLines _Trace.ProcessRequestRs"))
        {
            lstListeners.Items.Clear();
            foreach (XElement listener in getListenersRs.XPathSelectElements("responses/PGR_ Commerciallines_Trace. ProcessRequestRs/Files/runninglisteners/runninglistener"))
            {
                string text = string.Format(" (0)} - {1)", listener.Attribute("listenerID").Value, listener.Attribute("type").Value);
                lstListeners.Items.Add(new ListItem(text, listener.Attribute("listenerID").Value));
            }
            if (lstListeners.Items.Count == 0)
            {
                btnCloseListener.Enabled = false;
            }
            else
            {
                btnCloseListener.Enabled = true;
            }
        }
    }
    private void StreamFile(bool isZipFile, FileInfo downloadFileInfo)
    {
        //stream the file to the user
        Response.Clear();
        Response.ContentType = "application/" + (isZipFile ? "zip" : "xml");
        Response.AddHeader("Content-Disposition",
        string.Format("attachment; filename=(0)", downloadFileInfo.Name));
        Response.TransmitFile(downloadFileInfo.FullName);
        Response.End();
    }
    private void GetSessions(int maxSessions = 50)
    {
        lstSessions.Items.Clear();
        var listSessionsRq = new XElement("server",
                new XElement("requests",
                    new XElement("Session.loginRq",
                        new XAttribute("userName", "admin"),
                        new XAttribute("password", "admin")
                        //new XAttribute("useDomainInUserName", "1")
                        ),
                    new XElement("Session.listSessionsRq"),
                    new XElement("Session.closeRq")
        ));
        var listSessionsRs = ExecuteRequest(listSessionsRq);
        if (!ShowError(listSessionsRs, "Session.listSessionsRs"))
        {
            IEnumerable<XElement> DCTSessions = listSessionsRs.XPathSelectElements("responses/Session.listSessionsRs/sessions/session").OrderByDescending(x => x.Attribute("time").Value);
            if (maxSessions > 0 && string.IsNullOrEmpty(txtStartsWith.Text))
            {
                DCTSessions = DCTSessions.Take(maxSessions);
            }
            foreach (XElement session in DCTSessions)
            {
                if (session.Attribute("sessionID").Value.ToLower().StartsWith(txtStartsWith.Text.ToLower()))
                    lstSessions.Items.Add(new ListItem(session.Attribute("sessionID").Value));
            }
        }
    }
    private void GetFiles(string sort = "Sort New", int maxFiles = 50)
    {
        lstFiles.Items.Clear();
        //IstFiles
        DirectoryInfo dirInfo = new DirectoryInfo(Path.Combine(sanitizedTracePath, "CBO"));
        FileInfo[] fileInfos = dirInfo.GetFiles();
        foreach (FileInfo fileInfo in fileInfos)
        {
            lstFiles.Items.Add(fileInfo.FullName);
        }
        DisableFileButtonsAfterRefreshOrSort();
    }
    private bool ShowError(XElement response, string responseName)
    {
        bool showError = false;
        if (response.Element("responses").Element(responseName).Attribute("status").Value == "failure")
        {
            lblStatus.Text = "There was an error: " + response.Element("responses").Element(responseName).Element("errors").Element("error").Value;
            showError = true;
        }
        return showError;
    }
    protected void btnStartTrace_Click(object sender, EventArgs e)
    {
        pnlFile.Visible = false;
        pnlFile.Controls.Clear();
        btnZip.Visible = false;
        lblFileSize.Text = "0 KB";
        var items = new ArrayList();
        var idxs = lstApps.GetSelectedIndices();
        foreach (var idx in idxs)
        {
            items.Add(lstApps.Items[idx].Text);
        }

        var applist = string.Join(",", items.ToArray().Cast<string>());
        //get the user's ID to create a new folder for them
        string username = User.Identity.Name.Replace("\\", "");
        string traceDir = Path.Combine(traceDirectory, username);
        if (!Directory.Exists(traceDir))
        {
            Directory.CreateDirectory(traceDir);
        }
        else
        {
            //delete all the user's old files on the server foreach, (string path in Directory. GetFiles(EraceDir
            foreach (string path in Directory.GetFiles(traceDir))
            {
                try
                {
                    File.Delete(path);
                }
                catch { }// don't let a file lock stop the trace
            }
        }

        string fileName = string.Format("{0:yyyyMMddHHmmssff}.xml", DateTime.Now);
        string filePath = System.IO.Path.Combine(traceDir, fileName);
        var connectRq = new XElement("server",
                  new XElement("requests",
                    new XElement("Session.loginRq",
                        new XAttribute("userName", "admin"),
                        new XAttribute("password", "admin")
                        //new XAttribute("useDomainInUserName", "1")
                        ),
                    new XElement("Diagnostics.connectRq",
                    new XElement("Listener",
                    new XAttribute("listenerType", "File"),
                    new XAttribute("logfilePath", filePath),
                    new XElement("AppSeverity",
                                new XAttribute("severity", "Debug"),
                                new XAttribute("appList", applist)
                                )
                            )
                        ),
                        new XElement("Session.closeRq")
                      ));
        if (!string.IsNullOrEmpty(lstSessions.SelectedValue))
        {
            connectRq.Element("requests").Element("Diagnostics.connectRq").Element("Listener").Add(new XAttribute("sessionList", lstSessions.SelectedValue));
        }
        var connectRs = ExecuteRequest(connectRq);

        if (!ShowError(connectRs, "Diagnostics.connectRs"))
        {
            var listenerId = connectRs.XPathSelectElement("responses/Diagnostics.connectRs/Listener");
            txtListenerId.Value = listenerId.Attribute("listenerId").Value.ToString();
            txtFileName.Text = fileName.Replace(".xml", "");
            lblStatus.Text = string.Format("Listener {0} Started", txtListenerId.Value);
            pnlFile.Controls.Clear();
            pnlFile.Visible = false;
            btnStartTrace.Enabled = false;
            btnStopTrace.Enabled = true;
            tmrFileSize.Enabled = true;
            lblFileSize.Text = "0 KB";
            //onRemove = new CacheItemRemovedCallback(TraceStop.StopListenerOnCallBack);// using this to stop the trace if the user just closes the browser

            if (Cache[filePath] == null)
            {
                Cache.Add(filePath, txtListenerId.Value, null, DateTime.Now.AddSeconds(Convert.ToDouble(ConfigurationManager.AppSettings["maxTraceTimeSeconds"]) + 4), Cache.NoSlidingExpiration, CacheItemPriority.High, onRemove);
            }
        }
    }
    protected void btnGetDownloadLink_Click(object sender, EventArgs e)
    {
        btnGetDownloadLink.Enabled = false;
        //string tracefolderUr1 = System. Configuration, ConfigurationManager.AppSettings["traceLogDir"];
        string username = User.Identity.Name.Replace("\\", "");
        string traceDir = traceDirectory;
        string traceFilePath = Path.Combine(traceDir, txtFileName.Text + ".xml");
        int fileCounter = 0;
        int lineCounter = 0;
        int maxLinesInFile = Convert.ToInt32(System.Configuration.ConfigurationManager.AppSettings["maxTraceLinesSplit"]); // get from config setting
        bool havelWrittenPastMaxLines = false;
        List<string> securefiles = new List<string>();
        string remoteFileName = string.Empty;
        string remoteFileNameTmp = string.Empty;

        //if (Session["CHSElements"] != null)
        //    CHSElements = (List<CHSElement>)Session["CHSElements"];
        if (File.Exists(traceFilePath))
        {
            //clean up the value attribute if running manuscript application
            using (StreamReader read = File.OpenText(traceFilePath))
            {
                while (!read.EndOfStream)
                {
                    fileCounter++;
                    lineCounter = 0;
                    havelWrittenPastMaxLines = false;

                    using (StreamWriter write = File.CreateText(traceFilePath.Replace(".xml", "") + "-" + fileCounter.ToString() + ".temp"))
                    {
                        while (read.Peek() > -1)
                        {
                            remoteFileNameTmp = Path.GetFileName(traceFilePath).Replace(".xml", "") + "-" + fileCounter.ToString() + ".dcttrace";
                            string line = read.ReadLine().Replace("&#x1A", ""); //sometimes has this wierd character
                            line = line.Replace("pwd='*****/>", @"pwd='*****'"" />");
                            line = line.Replace("password='*****'||", @"password=""||");
                            if (line.StartsWith("<mdebug"))
                            {
                                line = CleanupMDebug(line);
                            }
                            //Remediate Trace Line if (currentEnv

                            write.WriteLine(line);
                            lineCounter++;
                            if (lineCounter % maxLinesInFile == 0)
                            {

                                havelWrittenPastMaxLines = true;
                            }
                            if (havelWrittenPastMaxLines && line.StartsWith("<message") && line.EndsWith("/>"))
                            {
                                break; //start next file
                            }
                            if (remoteFileName == "" || remoteFileName != remoteFileNameTmp)
                            {
                                remoteFileName = remoteFileNameTmp;
                                securefiles.Add(remoteFileName);
                            }
                        }
                    }
                }
            }
            //Secure Trace File
            //Need to check
            //SanitizeTrace.SecureTrace(traceDir, username, sanitizedTracePath);
            SaveFile(traceDir, username, sanitizedTracePath);
            foreach (string secureFile in securefiles)
            {
                HyperLink hlFile = new HyperLink
                {
                    //Text = string.Format("{0}{1}{2}{3}{4}", sanitizedTracePath, username, "\\", secureFile, "<br>")
                    Text = Path.Combine(sanitizedTracePath, secureFile)
                };
                pnlFile.Controls.Add(hlFile);
            }
            pnlFile.Visible = true;
            //btnZip.Visible = true;
        }
    }
    private void SaveFile(string TraceDir, string UserName, String NASLocation)
    {
        NASLocation = Path.Combine(NASLocation, UserName);
        Directory.CreateDirectory(NASLocation);

        DirectoryInfo dirInfo = new DirectoryInfo(TraceDir);
        FileInfo[] fileInfos = dirInfo.GetFiles("*.temp", SearchOption.TopDirectoryOnly);
        foreach (FileInfo fileInfo in fileInfos)
        {
            fileInfo.MoveTo(Path.Combine(NASLocation, fileInfo.Name.Replace("temp", "dcttrace")));
        }
    }
    //Need to check
    /*private void IdentifvCHSData()
    {
        List<string> sessionIDs = new List<string>();
        string username = User.Identity.Name.Replace("\\", "");
        string traceDir = Path.Combine(traceDirectory, username);
        string traceFilePath = Path.Combine(traceDir, txtFileName.Text + " xml");
        string serverUrl = System.Configuration.ConfigurationManager.AppSettings["ExampleServerURLAuthorized"];
        DateTime startTime = new DateTime();
        DateTime finishTime = new DateTime();
        if (hdnSessionID.Value == "AlISessions" || hdnSessionID.Value == "")
        {
            SanitizeTrace.IdentifyCHSData(optimSanitizeFields, serverUrl, refCHSElements, refstartTime, reffinishTime);
        }
        else
        {
            SanitizeTrace.IdentifyCHSData(optimSanitizeFields, serverUrl, ref CHSElements, ref startTime, ref finishTime, hdnSessionID.Value);
        }
        Session["CHSElements"] = CHSElements;
        txtStartTime.Text = startTime.Tostring();
        txtFinishTime.Text = finishTime.ToString();
    }*/
    protected void btnStopTrace_Click(object sender, EventArgs e)
    {
        XElement disconnects = RunStopTraceRequest(txtListenerId.Value);
        if (!ShowError(disconnects, "Diagnostics.disconnectRs"))
        {
            tmrFileSize.Enabled = false;
            btnStopTrace.Enabled = false;
            btnStartTrace.Enabled = true;
            lblStatus.Text = string.Format("Listener {0} Stopped", txtListenerId.Value);
            string username = User.Identity.Name.Replace("\\", "");
            string traceDir = Path.Combine(traceDirectory, username);
            string traceFilePath = Path.Combine(traceDir, txtFileName.Text + ".xml");
            if (File.Exists(traceFilePath))
            {
                var info = new System.IO.FileInfo(traceFilePath);
                lblFileSize.Text = string.Format("{0:#,###} KB", info.Length / 1024);
                lblFileSize.Visible = true;
                btnGetDownloadLink.Enabled = true;
            }
            if (sender is System.Web.UI.Timer)
            {
                lblStatus.Text += " because the size of the trace file has exceeded the maximum limit of " + ConfigurationManager.AppSettings["maxTraceLogSizeMB"] + " MB or the trace has been running longer than the maxinum number of " + ConfigurationManager.AppSettings["maxTraceTimeSeconds"] + " seconds.";
                lblTime.Visible = false;
            }
        }
    }
    private string CleanupMDebug(string line)
    {
        if (line.Contains(" value=\""))
        {
            var parts = line.Split(new string[] { " value=\"" }, StringSplitOptions.None);
            string start = parts[0];
            parts = parts[1].Split(new string[] { "\"/>" }, StringSplitOptions.None);
            string mid = parts[0];
            string end = parts[1];
            line = start + " value=\"" + System.Web.HttpUtility.HtmlEncode(mid) + "\"/>" + end;
        }
        return line;
    }
    private static XElement RunStopTraceRequest(string listenerId)
    {
        var disconnectRq = new XElement("server",
                new XElement("requests",
                    new XElement("Session.loginRq",
                        new XAttribute("userName", "admin"),
                        new XAttribute("password", "admin")
                //new XAttribute("useDomainInUserName", "1")
                ),
                new XElement("Diagnostics.disconnectRq",
                    new XElement("listener",
                        new XAttribute("listenerId", listenerId)
                        )
                ),
                new XElement("Session.closeRq")
                ));
        var disconnects = ExecuteRequest(disconnectRq);
        return disconnects;
    }
    protected void tmrFileSize_Tick(object sender, EventArgs e)
    {
        string username = User.Identity.Name.Replace("\\", "");
        string traceDir = Path.Combine(traceDirectory, username);
        string traceFilePath = Path.Combine(traceDir, txtFileName.Text + ".xml");
        Debug.WriteLine("traceFilePath:" + traceFilePath);

        long maxFileSize = Convert.ToInt64(ConfigurationManager.AppSettings["maxTraceLogSizeMB"]) * 1024 * 1024; //ME
        int maxTraceTimeSeconds = Convert.ToInt32(ConfigurationManager.AppSettings["maxTraceTimeSeconds"]);

        if (File.Exists(traceFilePath))
        {
            var info = new System.IO.FileInfo(traceFilePath);
            lblFileSize.Text = string.Format(" {0:#,###} KB", info.Length / 1024);
            lblTime.Text = string.Format("Trace time remaining in seconds: {0}", (maxTraceTimeSeconds - Convert.ToInt32((DateTime.Now - info.CreationTime).TotalSeconds)).ToString());



            if (info.Length > maxFileSize || info.CreationTime.AddSeconds(maxTraceTimeSeconds) < DateTime.Now)
            {
                btnStopTrace_Click(sender, e);
            }
            //UpdatePanell.Update();
        }
    }

    private static XElement ExecuteRequest(XElement request)
    {

        //IHttpPost httpPost = new HttpPost();
        var serverUrl = System.Configuration.ConfigurationManager.AppSettings["ExampleServerURLAuthorized"];
        //return XElement.Parse(httpPost.Post(serverUrl, request.ToString()));
        //get the URL from web. config
        var httpClient = new HttpClient();
        var content = new StringContent(request.ToString(), Encoding.UTF8, "application/xml");

        var response = httpClient.PostAsync(serverUrl, content).Result;

        if (response.IsSuccessStatusCode)
        {
            var responseContent = response.Content.ReadAsStringAsync().Result;

            return XElement.Parse(responseContent);

            //Use this if the previous retun is not working
            /*using (var stringReader = new StringReader(responseContent))
            {
                using (var xmlReader = XmlReader.Create(stringReader))
                {
                    return XElement.Load(xmlReader);
                }
            }*/
        }
        else
        {
            throw new Exception("Failed to post XML to {serverUrl}. Response status code: " + response.StatusCode );
        }
    }

    protected void btnRefresh_Click(object sender, EventArgs e)
    {
        GetSessions();
        btnView.Enabled = false;
    }
    protected void btnRefreshAll_Click(object sender, EventArgs e)
    {
        GetSessions(0); // get all the sessions
        btnView.Enabled = false;
    }
    protected void lstSessions_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (((ListBox)sender).SelectedIndex >= 0)
        {
            btnView.Enabled = true;
            btnFields.Enabled = true;
        }
    }
    [WebMethod]
    public static string StopTrace(string listenerId)
    {
        string result = "No Trace is running";
        if (listenerId != "")
        {
            XElement stopTraceRs = RunStopTraceRequest(listenerId).XPathSelectElement("responses/Diagnostics.disconnects");
            if (stopTraceRs != null && stopTraceRs.Attribute("status") != null && stopTraceRs.Attribute("status").Value == "success")
            {
                result = "Trace stopped";
            }
            else
            {
                result = "Trace not stopped";
                if (stopTraceRs != null && stopTraceRs.Element("'errors") != null && stopTraceRs.Element("errors").Element("error") != null)
                {
                    result += ": " + stopTraceRs.Element("errors").Element("error").Value;
                }
            }
        }
        return result;
    }
    protected void btnZip_Click(object sender, EventArgs e)
    {
        string username = User.Identity.Name.Replace("\\", "");
        string traceDir = Path.Combine(traceDirectory, username);
        string tracefilePath = Path.Combine(traceDir, txtFileName.Text + ".xml");
        string ZipFilePath = Path.Combine(traceDir, txtFileName.Text + ".zip");
        string tempZipDirPath = tracefilePath.Replace(" xmI", "");

        pnlFile.Controls.Clear();
        //Move the files for this trace to a temp folder
        DirectoryInfo dirInfo = new DirectoryInfo(traceDir);
        Directory.CreateDirectory(tempZipDirPath);
        FileInfo[] fileInfos = dirInfo.GetFiles("* dcttrace", SearchOption.TopDirectoryOnly);
        foreach (FileInfo fileInfo in fileInfos)
        {
            File.Move(fileInfo.FullName, fileInfo.FullName.Replace(username, username + "\\" + txtFileName.Text));
        }
        //zip the temp folder 
        //Need to check
        //ZipFile.CreateFromDirectory(tempZipDirPath, ZipFilePath);
        //Create a link to the compressed file
        HyperLink hlFile = new HyperLink();
        hlFile.Text = "Download Trace " + txtFileName.Text + ".zip";
        hlFile.NavigateUrl = "trace.aspx?f=" + txtFileName.Text + "&z=1";
        pnlFile.Controls.Add(hlFile);
        //Delete the uncompressed files
        Directory.Delete(tempZipDirPath, true);
        btnZip.Visible = false;
    }
    protected void btnRefreshFiles_Click(object sender, EventArgs e)
    {
        GetFiles(txtSort.Text == "" ? "Sort New" : txtSort.Text);
    }
    protected void btnRefreshAllFiles_Click(object sender, EventArgs e)
    {
        GetFiles(txtSort.Text == "" ? "Sort New" : txtSort.Text, 0);   //get all files
    }
    private void DisableFileButtonsAfterRefreshOrSort()
    {
        btnZipFiles.Enabled = false;
        btnDownloadFile.Enabled = false;
        btnDeleteFile.Enabled = false;
        btnDeleteAll.Enabled = lstFiles.Items.Count > 0;
    }
    protected void btnSortFiles_Click(object sender, EventArgs e)
    {
        GetFiles(btnSortFiles.Text);

        if (btnSortFiles.Text == "Sort New")
        {
            btnSortFiles.Text = "Sort Old";
            txtSort.Text = "Sort New";
        }
        else
        {
            btnSortFiles.Text = "Sort New";
            txtSort.Text = "Sort Old";
        }
    }
    protected void btnZipFiles_Click(object sender, EventArgs e)
    {
        string filesDir = GetFilesDirectory();
        Random random = new Random(Convert.ToInt32(DateTime.Now.ToString("fff")));
        string randomValue = random.Next().ToString();
        string tempZipDir = Path.Combine(filesDir, "tempZip", randomValue);

        //Move the selected files to the temp folder
        Directory.CreateDirectory(tempZipDir);

        foreach (ListItem listItem in lstFiles.Items)
        {
            if (listItem.Selected)
            {
                File.Move(Path.Combine(filesDir, listItem.Value), Path.Combine(tempZipDir, listItem.Value));
            }
        }
        //zip the temp folder
        string zipName = DateTime.Now.ToString("yyyy-MM-ddTHH-mm-ss. fiff.\\zip");
        //System.I0.Compression.ZipFile.CreateFromDirectory(tempZipDir, Path.Combine(filesDir, zipName)); Need to check
        //Delete the uncompressed files
        Directory.Delete(tempZipDir, true);
        GetFiles("Sort New");

        foreach (ListItem listItem in lstFiles.Items)
        {
            if (listItem.Value == zipName)
            {
                listItem.Selected = true;
                break;
            }
        }

        btnZipFiles.Enabled = true;
        btnDeleteFile.Enabled = true;
        btnDeleteAll.Enabled = true;
        btnDownloadFile.Enabled = true;
    }
    private static string GetFilesDirectory()
    {
        var getPropertyRq = new XElement("server",
                new XElement("requests",
                   new XElement("Session.loginRq",
                        new XAttribute("userName", "admin"),
                        new XAttribute("password", "admin")
                    //new XAttribute("useDomainInUserName", "1")
                    ),
                    new XElement("Settings.getPropertyRq",
                            new XAttribute("name", "Debug.DebugFilePath")),
                        new XElement("Session.closeRq")
                ));
        var getPropertyRs = ExecuteRequest(getPropertyRq);
        //string filesDir = getPropertyRs.XPathSelectElement("responses/Settings.getPropertyRs").Attribute("value").Value.Replace("\\TSV", "");
        string filesDir = getPropertyRs.XPathSelectElement("responses/Settings.getPropertyRs").Attribute("value").Value;
        return filesDir;
    }
    protected void btnDownloadFile_Click(object sender, EventArgs e)
    {
        string selectedFileName = lstFiles.SelectedValue;
        Response.Redirect("trace.asp?c=1&f=" + selectedFileName.Replace(".zip", "").Replace(".xmI", "").Replace(".dcttrace", "") + (selectedFileName.EndsWith("Zip") ? "&Z=1" : ""), false);
    }
    protected void btnDeleteFile_Click(object sender, EventArgs e)
    {
        bool isDeleteAll = ((Button)sender).Text == "Delete All";
        var traceRq = new XElement("server",
            new XElement("requests",
                new XElement("Session.loginRq",
                    new XAttribute("userName", ""),
                    new XAttribute("password", ""),
                new XAttribute("useDomainInUserName", "1")
        )));
        if (isDeleteAll)
        {
            traceRq.Element("requests").Add(new XElement("PGR_Commerciallines_Trace.ProcessRequestRq",
                        new XAttribute("action", "deleteAll")));
        }
        else
        {
            foreach (ListItem item in lstFiles.Items)
            {
                if (item.Selected)
                {
                    traceRq.Element("requests").Add(new XElement("PG_CommercialLines_Trace .ProcessRequestRq",
                            new XAttribute("action", "delete"),
                            new XAttribute("fileName", item.Value)));
                }
            }
        }
        traceRq.Element("requests").Add(new XElement("Session.closeRq"));
        ExecuteRequest(traceRq);
        GetFiles(txtSort.Text);
    }
    protected void lstFiles_SelectedIndexChanged(object sender, EventArgs e)
    {
        btnZipFiles.Enabled = true;
        btnDeleteFile.Enabled = true;
        btnDeleteAll.Enabled = true;
        int countSelected = 0;
        foreach (ListItem item in ((ListBox)sender).Items)
        {
            if (item.Selected)
                countSelected++;
            if (countSelected == 1)
                btnDownloadFile.Enabled = true;
            if (countSelected == 2)
            {
                btnDownloadFile.Enabled = false;
                break;
            }
            lblCBOTraceFile.Text = lstFiles.SelectedValue;
        }
    }
    protected void btnRefreshListeners_Click(object sender, EventArgs e)
    {
        lstListeners.Items.Clear();
        GetListeners();
    }
    protected void btnCloseListener_Click(object sender, EventArgs e)
    {
        lblStatus.Text = "";
        if (lstListeners.SelectedItem == null)
        {
            lblStatus.Text = "please select a Listener to Close";
        }
        else
            RunStopTraceRequest(lstListeners.SelectedValue);
        GetListeners();
    }

}

