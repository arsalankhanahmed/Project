using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
//using CustomUsernamePasswordAuth.Web.ServiceReference1;
using System.ServiceModel;
using System.ServiceModel.Description;
using System.ServiceModel.Security;
using System.Xml;
//using CustomUsernamePasswordAuth.ServiceReference1;

namespace CustomUsernamePasswordAuth.Web
{
    public partial class _Default : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        protected void Button1_Click(object sender, EventArgs e)
        {
            try
            {
                Label1.Text = "Start Service";
                GetService();
            }
            catch(Exception)
            {

            }
        }

        public void GetService()
        {
            try
            {
                //string ToEmailAddress = "";
                string value = @"<ZMMSTOCKRECON_01><IDOC><EDI_DC40><TABNAM>EDI_DC40</TABNAM><MANDT>100</MANDT><DOCNUM>0000000020884979</DOCNUM><DOCREL>700</DOCREL><STATUS>51</STATUS><DIRECT>2</DIRECT><OUTMOD></OUTMOD><IDOCTYP>ZMMSTOCKRECON_01</IDOCTYP><MESTYP>ZMMSTOCKRECON</MESTYP><SNDPOR>SAPDTO</SNDPOR><SNDPRT>LI</SNDPRT><SNDPFC>LF</SNDPFC><SNDPRN>0001120019</SNDPRN><RCVPOR>SAPMYB</RCVPOR><RCVPRT>LS</RCVPRT><RCVPRN>MYB_100</RCVPRN><CREDAT>20120215</CREDAT><CRETIM>170954</CRETIM><ARCKEY>EE42246E514E8B11E1BA0CE41F13886C67</ARCKEY></EDI_DC40><Z1STOCK_RECON_01><MATNR>001419N</MATNR><CHARG>B-320101</CHARG><WERKS>MY06</WERKS><LGORT>PKE01</LGORT><XEE>YCM</XEE><LGPLA>1BIGBIN</LGPLA><GESME>1180</GESME><MEINS>PC</MEINS><VFDAT>20130630</VFDAT></Z1STOCK_RECON_01><Z1STOCK_RECON_01><MATNR>3286RD</MATNR><CHARG>111031</CHARG><WERKS>MY06</WERKS><LGORTA>MY13</LGORTA><LGTYP>YCM</LGTYP><LGPLA>1BIGBIN</LGPLA><BESTQ>S</BESTQ><GESME>3600</GESME><MEINS>PC</MEINS><VFDAT>20131030</VFDAT></Z1STOCK_RECON_01><Z1STOCK_RECON_01><MATNR>4891996B</MATNR><CHARG>W0809</CHARG><WERKS>MY06</WERKS><LGORTA>MY13</LGORTA><LGTYP>YCM</LGTYP><LGPLA>1BIGBIN</LGPLA><GESME>1</GESME><MEINS>PC</MEINS><VFDAT>20940831</VFDAT><SERNR>9370</SERNR></Z1STOCK_RECON_01><Z1STOCK_RECON_01><MATNR>4891996B</MATNR><CHARG>W3005</CHARG><WERKS>MY06</WERKS><LGORTA>MY13</LGORTA><LGTYP>YCM</LGTYP><LGPLA>1BIGBIN</LGPLA><GESME>1</GESME><MEINS>PC</MEINS><VFDAT>20940831</VFDAT><SERNR>13208</SERNR></Z1STOCK_RECON_01><Z1STOCK_RECON_01><MATNR>C0936731</MATNR><CHARG>111302V501</CHARG><WERKS>MY06</WERKS><LGORTA>MY13</LGORTA><LGTYP>YCM</LGTYP><LGPLA>1BIGBIN</LGPLA><GESME>144</GESME><MEINS>PC</MEINS><VFDAT>20160701</VFDAT></Z1STOCK_RECON_01><Z1STOCK_RECON_01><MATNR>C0936812</MATNR><CHARG>111185V501</CHARG><WERKS>MY06</WERKS><LGORTA>MY13</LGORTA><LGTYP>YCM</LGTYP><LGPLA>1BIGBIN</LGPLA><GESME>144</GESME><MEINS>PC</MEINS><VFDAT>20160501</VFDAT></Z1STOCK_RECON_01><Z1STOCK_RECON_01><MATNR>C0936812</MATNR><CHARG>111383V501</CHARG><WERKS>MY06</WERKS><LGORTA>MY13</LGORTA><LGTYP>YCM</LGTYP><LGPLA>1BIGBIN</LGPLA><GESME>72</GESME><MEINS>PC</MEINS><VFDAT>20160901</VFDAT></Z1STOCK_RECON_01></IDOC></ZMMSTOCKRECON_01>";
                XmlDocument xDoc = new XmlDocument();

                xDoc.LoadXml(value);

                // XmlNode item = xDoc.SelectSingleNode("//LGORT");// .GetElementsByTagName("LGORT");
                var STitems = xDoc.SelectNodes("//CCCSD").Cast<XmlNode>().Select(cat => cat.InnerText).Distinct();
                var items = xDoc.SelectNodes("//LGORT").Cast<XmlNode>().Select(cat => cat.InnerText).Distinct(); //.GetElementsByTagName("LGORT");

                if (items != null)
                {
                    string itemvalueq = "";
                    foreach (var sl in STitems)
                    {
                        itemvalueq += sl.ToString() + ",";
                    }

                    string itemvalue = "";
                    foreach (var sl in items)
                    {
                        itemvalue += sl.ToString() + ",";
                    }
                    //XmlElement ele1 = (XmlElement)item.Item(0);

                    //ToEmailAddress = "ccc";
                }
                //else
                //{
                //    ToEmailAddress = "ccc";
                //}

                //var ServiceendPoint = new EndpointAddress(new Uri(txtServiceAddress.Text), EndpointIdentity.CreateDnsIdentity("MyWebSite"));
                //var binding = new WSHttpBinding();
                //binding.Security.Mode = SecurityMode.Message;
                //binding.Security.Message.ClientCredentialType = MessageCredentialType.UserName;

                SAPIDOCReceiver.Service1Client result = new SAPIDOCReceiver.Service1Client();
                result.ClientCredentials.ServiceCertificate.Authentication.CertificateValidationMode = X509CertificateValidationMode.None;
                result.ClientCredentials.UserName.UserName = txtUId.Text;
                result.ClientCredentials.UserName.Password = txtPwd.Text;
                string str = result.SAPIDocReceiver(@"<ZMMSTOCKRECON_01><IDOC><EDI_DC40><TABNAM>EDI_DC40</TABNAM><MANDT>100</MANDT><DOCNUM>0000000020884979</DOCNUM><DOCREL>700</DOCREL><STATUS>51</STATUS><DIRECT>2</DIRECT><OUTMOD></OUTMOD><IDOCTYP>ZMMSTOCKRECON_01</IDOCTYP><MESTYP>ZMMSTOCKRECON</MESTYP><SNDPOR>SAPDTO</SNDPOR><SNDPRT>LI</SNDPRT><SNDPFC>LF</SNDPFC><SNDPRN>0001120019</SNDPRN><RCVPOR>SAPMYB</RCVPOR><RCVPRT>LS</RCVPRT><RCVPRN>MYB_100</RCVPRN><CREDAT>20120215</CREDAT><CRETIM>170954</CRETIM><ARCKEY>EE42246E514E8B11E1BA0CE41F13886C67</ARCKEY></EDI_DC40><Z1STOCK_RECON_01><MATNR>001419N</MATNR><CHARG>B-320101</CHARG><WERKS>MY06</WERKS><LGORT>PKE01</LGORT><LGTYP>YCM</LGTYP><LGPLA>1BIGBIN</LGPLA><GESME>1180</GESME><MEINS>PC</MEINS><VFDAT>20130630</VFDAT></Z1STOCK_RECON_01><Z1STOCK_RECON_01><MATNR>3286RD</MATNR><CHARG>111031</CHARG><WERKS>MY06</WERKS><LGORT>PKE01</LGORT><LGTYP>YCM</LGTYP><LGPLA>1BIGBIN</LGPLA><BESTQ>S</BESTQ><GESME>3600</GESME><MEINS>PC</MEINS><VFDAT>20131030</VFDAT></Z1STOCK_RECON_01><Z1STOCK_RECON_01><MATNR>4891996B</MATNR><CHARG>W0809</CHARG><WERKS>MY06</WERKS><LGORT>MY13</LGORT><LGTYP>YCM</LGTYP><LGPLA>1BIGBIN</LGPLA><GESME>1</GESME><MEINS>PC</MEINS><VFDAT>20940831</VFDAT><SERNR>9370</SERNR></Z1STOCK_RECON_01><Z1STOCK_RECON_01><MATNR>4891996B</MATNR><CHARG>W3005</CHARG><WERKS>MY06</WERKS><LGORT>MY13</LGORT><LGTYP>YCM</LGTYP><LGPLA>1BIGBIN</LGPLA><GESME>1</GESME><MEINS>PC</MEINS><VFDAT>20940831</VFDAT><SERNR>13208</SERNR></Z1STOCK_RECON_01><Z1STOCK_RECON_01><MATNR>C0936731</MATNR><CHARG>111302V501</CHARG><WERKS>MY06</WERKS><LGORT>MY13</LGORT><LGTYP>YCM</LGTYP><LGPLA>1BIGBIN</LGPLA><GESME>144</GESME><MEINS>PC</MEINS><VFDAT>20160701</VFDAT></Z1STOCK_RECON_01><Z1STOCK_RECON_01><MATNR>C0936812</MATNR><CHARG>111185V501</CHARG><WERKS>MY06</WERKS><LGORT>MY13</LGORT><LGTYP>YCM</LGTYP><LGPLA>1BIGBIN</LGPLA><GESME>144</GESME><MEINS>PC</MEINS><VFDAT>20160501</VFDAT></Z1STOCK_RECON_01><Z1STOCK_RECON_01><MATNR>C0936812</MATNR><CHARG>111383V501</CHARG><WERKS>MY06</WERKS><LGORT>MY13</LGORT><LGTYP>YCM</LGTYP><LGPLA>1BIGBIN</LGPLA><GESME>72</GESME><MEINS>PC</MEINS><VFDAT>20160901</VFDAT></Z1STOCK_RECON_01></IDOC></ZMMSTOCKRECON_01>");
                Label1.Text = str;
            }
            catch (Exception ex)
            {
                Label1.Text = ex.Message;
            }
        }
    }
}