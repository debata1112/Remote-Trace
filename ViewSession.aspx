<%@ Page Language="C#" %>

<%@ Import Namespace="System.Xml.XPath" %>
<%@ Import Namespace="System.Xml.Linq" %>
<%@ Import Namespace="System.Xml" %>
<%@ Import Namespace="System.IO" %>

<script runat="server">
    void getSession()
    {
        string viewSessionXmlPath = Server.MapPath("ViewSession.config");
        var tests = XDocument.Load(viewSessionXmlPath);
        string serverUrl = ConfigurationManager.AppSettings["ServerURL"];//.Replace(".aspx", "AuthRequired.aspx");
        if (string.IsNullOrWhiteSpace(Request.QueryString["sessionid"]))
        {
            Response.Write("<p style=\"color:red\">Please provide the <b>sessionid</b> parameter. Example ViewSession.aspx?sessionid=6EF5063C:DB0445D8:96342223:6BE5874B:7A35FE39:48E90C4F</p>");
            return;
        }
        string sessionId = Request.QueryString["SessionID"];
        tests.XPathSelectElement("//Session.resumeRq").SetAttributeValue("sessionID", sessionId);
        try
        {
            string path = Server.MapPath("DCTServer.aspx").Replace("DCTServer.aspx", "");
        }
        catch (Exception ex)
        {
            Response.Write(ex.Message);
            System.Diagnostics.Debug.Write(ex.Message);
        }
        string response = HTTPPost(tests.ToString(), serverUrl);
        var responseXML = XDocument.Parse(response);
        string responseXMLFormatted = EscapeText(responseXML.ToString(), true, true);
        Response.Write("<pre>" + responseXMLFormatted + "</pre>");
    }
    private string HTTPPost(string requestXml, string serverUrl)
    {
        CertificatePolicyHandler certificatePolicyHandler = null;
        try
        {
            System.Net.HttpWebRequest wr = (System.Net.HttpWebRequest)System.Net.WebRequest.Create(serverUrl);
            wr.Method = "POST";
            wr.ContentType = "text/xml";
            wr.Credentials = System.Net.CredentialCache.DefaultNetworkCredentials;
            wr.Timeout = 90000;
            string timeOut = System.Configuration.ConfigurationManager.AppSettings["Timeout"];
            if (timeOut != null)
            {
                wr.Timeout = Convert.ToInt32(timeOut);
            }
            wr.ServicePoint.ConnectionLimit = 10;
            String connectionLimit = System.Configuration.ConfigurationManager.AppSettings["ConnectionLimit"];
            if (connectionLimit != null)
            {
                wr.ServicePoint.ConnectionLimit = Convert.ToInt32(connectionLimit);
            }
            bool bypassHostAuthentication = System.Configuration.ConfigurationManager.AppSettings["BypassHostAuthentication"] == "1";
            certificatePolicyHandler = new CertificatePolicyHandler(bypassHostAuthentication);
            System.Net.ServicePointManager.ServerCertificateValidationCallback = certificatePolicyHandler.SSLHostAuthenticationCallback;
            byte[] byteArray = System.Text.Encoding.UTF8.GetBytes(requestXml);
            System.IO.Stream strm = wr.GetRequestStream();
            strm.Write(byteArray, 0, byteArray.Length);
            strm.Close();
            System.Net.WebResponse resp = wr.GetResponse();
            System.Text.Encoding enc = Encoding.GetEncoding("utf-8");
            System.IO.StreamReader reader = new System.IO.StreamReader(resp.GetResponseStream(), enc);
            string result = reader.ReadToEnd();
            reader.Close();
            resp.Close(); return result;
        }
        catch (Exception err)
        {
            if (certificatePolicyHandler != null && certificatePolicyHandler.ErrorMessage != "")
                return FormatXMLElement("HTTPError", EscapeText(certificatePolicyHandler.ErrorMessage, true, true));
            else
                return FormatXMLElement("HITPError", EscapeText(err.Message, true, true));
        }
    }
    protected string FormatXMLElement(string tagName, string text)
    {
        return String.Format("<{0}>(1)</{0}>", tagName, text);
    }

    protected string EscapeText(string sValue, bool bEscape, bool bHandleQuotes)
    {
        if (sValue == null)
            return string.Empty;
        if (bEscape)
        {
            StringBuilder sb = null;
            int nPos1 = 0;
            int nPos2 = 0;
            char[] chars = new char[] { '&', '<', '>', '\n', '\r' };
            if (bHandleQuotes)
                chars = new char[] { '&', '<', '>', '\"' };
            while (nPos2 < sValue.Length)
            {
                nPos2 = sValue.IndexOfAny(chars, nPos2);
                if (nPos2 == -1)
                    break;
                switch (sValue[nPos2])
                {
                    case '&':
                        AppendReplacedText(sValue, ref sb, ref nPos1, nPos2, "&amp;");
                        break;
                    case '<':
                        AppendReplacedText(sValue, ref sb, ref nPos1, nPos2, "&lt;");
                        break;
                    case '>':
                        AppendReplacedText(sValue, ref sb, ref nPos1, nPos2,  "&gt;");
                        break;
                    case '\"':
                        AppendReplacedText(sValue, ref sb, ref nPos1, nPos2, "&quot;");
                        break;
                    case '\n':
                        AppendReplacedText(sValue, ref sb, ref nPos1, nPos2, "<br/>");
                        break;
                    case '\r':
                        if ((nPos2 + 1 < sValue.Length) && sValue[nPos2 + 1] == '\n')
                        {
                            AppendReplacedText(sValue, ref sb, ref nPos1, nPos2, "<br/>");
                            nPos1++;
                            nPos2++;
                        }
                        break;
                }
                nPos2++;
            }
            if (sb == null)
                return sValue;
            AppendReplacedText(sValue, ref sb, ref nPos1, sValue.Length, string.Empty);
            return sb.ToString();
        }
        else
        {
            StringBuilder sb = null;
            int nPos1 = 0;
            int nPos2 = 0;
            char[] chars = new char[] { '&', '<' };
            if (bHandleQuotes)
                chars = new char[] { '&' };
            while (nPos2 < sValue.Length)
            {
                nPos2 = sValue.IndexOfAny(chars, nPos2);
                if (nPos2 == -1)
                    break;
                if (string.Compare(sValue, nPos2, "&lt;", 0, 4) == 0)
                {
                    AppendReplacedText(sValue, ref sb, ref nPos1, nPos2, "<");
                    nPos2 += 4;
                    nPos1 = nPos2;
                }
                else if (string.Compare(sValue, nPos2, "&gt;", 0, 4) == 0)
                {
                    AppendReplacedText(sValue, ref sb, ref nPos1, nPos2, ">");
                    nPos2 += 4;
                    nPos1 = nPos2;
                }
                else if (string.Compare(sValue, nPos2, "&amp;", 0, 4) == 0)
                {
                    AppendReplacedText(sValue, ref sb, ref nPos1, nPos2, "&");
                    nPos2 += 5;
                    nPos1 = nPos2;
                }
                else if (bHandleQuotes && string.Compare(sValue, nPos2, "&quot;", 0, 4) == 0)
                {
                    AppendReplacedText(sValue, ref sb, ref nPos1, nPos2, "\"");
                    nPos2 += 6;
                    nPos1 = nPos2;
                }
                else if (!bHandleQuotes && string.Compare(sValue, nPos2, "<br/>", 0, 4) == 0)
                {
                    AppendReplacedText(sValue, ref sb, ref nPos1, nPos2, "\r\n");
                    nPos2 += 5;
                    nPos1 = nPos2;
                }
                else
                    nPos2++;
            }
            if (sb == null)
                return sValue;
            AppendReplacedText(sValue, ref sb, ref nPos1, sValue.Length, string.Empty);
            return sb.ToString();
        }
    }
    private static void AppendReplacedText(string sValue, ref StringBuilder sb, ref int nPos1, int nPos2, string str)
    {
        if (nPos2 > nPos1)
        {
            if (sb == null)
                sb = new StringBuilder();
            sb.Append(sValue, nPos1, nPos2 - nPos1);
        }
        if (str.Length > 0)
        {
            if (sb == null)
                sb = new StringBuilder();
            sb.Append(str);
        }
        nPos1 = nPos2 + 1;
    }
    internal class CertificatePolicyHandler
    {
        private bool m_ignoreValidation = false;
        private string m_errorMessages = "";
        public CertificatePolicyHandler(bool ignoreValidation)
        {
            m_ignoreValidation = ignoreValidation;
        }
        public string ErrorMessage
        {
            get
            {
                return m_errorMessages;
            }
        }
        internal bool SSLHostAuthenticationCallback(object sender, System.Security.Cryptography.X509Certificates.X509Certificate cert, System.Security.Cryptography.X509Certificates.X509Chain chain, System.Net.Security.SslPolicyErrors sslError)
        {
            bool result = true;
            if (!m_ignoreValidation && sslError != System.Net.Security.SslPolicyErrors.None)
            {
                m_errorMessages += sslError.ToString();
                result = false;
            }
            return result;
        }
    }
    protected void btnLoad_Click(object sender, EventArgs e)
    {
        string s = HttpContext.Current.Request.Url.AbsoluteUri + '?';
        s = s.Remove(s.IndexOf('?'));
        Response.Redirect(s + "?sessionid=" + txtSessionId.Text);
    }
</script>
<form id="form1" runat="server">
    <h1>view Session</h1>
    <br />
    <p>This page runs the Session.getAllDocumentsRq request with the provided session id.Refresh the page to get the latest session data.</p>
    <br />
    please enter the Session Id to Load: &nbsp;
    <asp:TextBox ID="txtSessionId" runat="server" Width="529px"></asp:TextBox>
    &nbsp;
    <asp:Button ID="btnLoad" runat="server" Text="Load Session" OnClick="btnLoad_Click" />

</form>
<% getSession(); %>