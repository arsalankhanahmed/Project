using System;
using System.IO;
using System.Xml;
using Udl.EmailService;
using System.Configuration;

namespace UDLSAPConnector
{
    // NOTE: You can use the "Rename" command on the "Refactor" menu to change the class name "Service1" in code, svc and config file together.
    public class UDLSAPIDocReceiver : IUDLSAPIDocReceiver
    {
        readonly EmailUtility _emailUtility = new EmailUtility();
        string _pathToMoveFilesAfterFileSend = "";
        public string GetData(string value)
        {
            try
            {
                //string.Format("You entered: {0}", value);
                string ToEmailAddress = "";     
                XmlDocument xDoc = new XmlDocument();
                xDoc.LoadXml(value);
                string path = System.Web.Hosting.HostingEnvironment.ApplicationPhysicalPath + "Outbound\\";

                XmlNodeList item = xDoc.GetElementsByTagName("LGORT");

                if (item != null)
                {
                    ToEmailAddress = ConfigurationManager.AppSettings[item.ToString() + "Email"].ToString();
                }
                else
                {
                    ToEmailAddress = ConfigurationManager.AppSettings["HOEmail"].ToString();
                }

                string strDirectory =path;
                string strFileName = "data";
                string strFileExtension = ".xml";
                string strFileNameCombined = strDirectory + strFileName + strFileExtension;

                XmlWriterSettings settings = new XmlWriterSettings();
                settings.Indent = true;
                if (File.Exists(strFileNameCombined))
                   strFileNameCombined = strDirectory + strFileName + "_" + DateTime.Now.Ticks + strFileExtension;
                XmlWriter xWriter = XmlWriter.Create(strFileNameCombined, settings);
                xDoc.Save(xWriter);
                xWriter.Flush();
                xWriter.Close();
                _pathToMoveFilesAfterFileSend = strFileNameCombined + "\\SentOutbound";
                //if (!_emailUtility.SendMail(strFileNameCombined, _pathToMoveFilesAfterFileSend))
                EmailUtility.CreateAndSendMail(ConfigurationManager.AppSettings["EmailUserName"].ToString(), ToEmailAddress, "SAP File", "This is SAP file email", strFileNameCombined);

                return "success";
            }
            catch (Exception ex)
            {
                return ex.Message + ex.StackTrace;
            }
        }

        //public CompositeType GetDataUsingDataContract(CompositeType composite)
        //{
        //    if (composite == null)
        //    {
        //        throw new ArgumentNullException("composite");
        //    }
        //    if (composite.BoolValue)
        //    {
        //        composite.StringValue += "Suffix";
        //    }
        //    return composite;
        //}
    }
}
