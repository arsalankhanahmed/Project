using System;
using System.ServiceModel;
using System.ServiceModel.Channels;
using System.Data;
using System.Xml;
using Udl.EmailService;
using System.IO;
using UDL.Common.DataAccessLayer.DataObjects;
using System.Configuration;
using System.Linq;


namespace CustomUsernamePasswordAuth.Service
{
    [ServiceContract]
    public interface IService1
    {
        [OperationContract]
        string SAPIDocReceiver(string parameter);
        DataTable GetAllSAPBBRNStorageLocationMapping();
        DataTable GetAllSAPIPAdressPool(int rPBLId, string rIPAdress);
        string GetIPAddress();
    }

    [ServiceBehavior(IncludeExceptionDetailInFaults = true)]
    public class Service1 : IService1
    {
        DataTable dt;
        string StorageTypeCodes = "";
        string StorageLocationCodes = "";
        string IPAdress = "";
        string IDOCTYPENUM = "";
        public string SAPIDocReceiver(string XMLStringValue)
        {
            try
            {
                int PBLId = Convert.ToInt32(System.Configuration.ConfigurationManager.AppSettings["BBRNId"].ToString());
                IPAdress = GetIPAddress();
                dt = GetAllSAPIPAdressPool(PBLId, IPAdress);
                if (dt.Rows.Count == 0)
                    return IPAdress + Environment.NewLine + "Unregistered IP Address.";

                string ToEmailAddress = "";
                string LocationName = "";

                XmlDocument xDoc = new XmlDocument();
                xDoc.LoadXml(XMLStringValue);

                string path = System.Web.Hosting.HostingEnvironment.ApplicationPhysicalPath + "Outbound\\";
                var StorageTypeItems = xDoc.SelectNodes("//LGTYP").Cast<XmlNode>().Select(cat => cat.InnerText).Distinct();
                var StorageLocItems = xDoc.SelectNodes("//LGORT").Cast<XmlNode>().Select(cat => cat.InnerText).Distinct(); /*.GetElementsByTagName("LGORT");*/
                var IDOCType = xDoc.SelectNodes("//IDOCTYP").Cast<XmlNode>().Select(cat => cat.InnerText).Distinct();
                var DOCNUM = xDoc.SelectNodes("//DOCNUM").Cast<XmlNode>().Select(cat => cat.InnerText).Distinct();

                foreach (var doctyp in IDOCType)
                {
                   IDOCTYPENUM = doctyp.ToString();
                }

                foreach (var docnum in DOCNUM)
                {
                    IDOCTYPENUM += "_"+ docnum.ToString();
                }

                foreach (var st in StorageTypeItems)
                {
                    StorageTypeCodes += st.ToString() + ",";

                    dt = this.GetAllSAPBBRNStorageLocationMapping();
                    ToEmailAddress = dt.Rows[0]["LocationEmail"].ToString();
                    LocationName = dt.Rows[0]["LocationShortName"].ToString();
                }

                if (StorageTypeCodes.Length <= 0)
                {
                    foreach (var sl in StorageLocItems)
                    {
                        StorageLocationCodes += sl.ToString() + ",";
                    }
                    dt = this.GetAllSAPBBRNStorageLocationMapping();
                    ToEmailAddress = dt.Rows[0]["LocationEmail"].ToString(); 
                    LocationName = dt.Rows[0]["LocationShortName"].ToString();
                }

                if (dt.Rows.Count <= 0)
                    return "No Storage Location mapping data exists";

                string strDirectory = path;
                string strFileName = "SAPIDOC";
                string strFileExtension = ".xml";
                string strFileNameCombined = strDirectory + strFileName + strFileExtension;

                XmlWriterSettings settings = new XmlWriterSettings();
                settings.Indent = true;
                if (File.Exists(strFileNameCombined))
                    strFileNameCombined = strDirectory + strFileName + "_" + IDOCTYPENUM + strFileExtension;

                XmlWriter xWriter = XmlWriter.Create(strFileNameCombined, settings);
                xDoc.Save(xWriter);
                xWriter.Flush();
                xWriter.Close();
                /*_pathToMoveFilesAfterFileSend = strFileNameCombined + "\\SentOutbound";
                if (!_emailUtility.SendMail(strFileNameCombined, _pathToMoveFilesAfterFileSend))*/
                EmailUtility.CreateAndSendMail(ConfigurationManager.AppSettings["EmailUserName"].ToString(), ToEmailAddress, "SAP IDOC File For " + LocationName, "", strFileNameCombined);

                return "IDOC Sent Successfully.";
            }
            catch (Exception ex)
            {
                return "Error in sending IDOC.";
               /*"IDOC TYPE & NUM " + IDOCTYPENUM + "IPAdress : " + IPAdress + Environment.NewLine + "Message : " + ex.Message + "InnerException : " + ex.InnerException + "StackTrace : " + ex.StackTrace;*/
               /*EmailUtility.CreateAndSendMail(ConfigurationManager.AppSettings["EmailUserName"].ToString(), ToEmailAddress, "SAP IDOC File For " + LocationName, "", strFileNameCombined);*/
            }
        }

        public DataTable GetAllSAPBBRNStorageLocationMapping()
        {
            return CommonDataFunctions.GetDataBySP("usp_SAPBBRNStorageLocationMapping_GetData", new[] { StorageLocationCodes, StorageTypeCodes });
        }

        public DataTable GetAllSAPIPAdressPool(int rPBLId, string rIPAdress)
        {
            return CommonDataFunctions.GetDataBySP("usp_SAPIPAdressPool_GetAll", new[] { rPBLId.ToString(), rIPAdress });
        }

        public string GetIPAddress()
        {
            try
            {
                // Get message properties from current OperationContext
                MessageProperties props = OperationContext.Current.IncomingMessageProperties;
                // Find the RemoteEndpointMessageProperty
                RemoteEndpointMessageProperty prop = (RemoteEndpointMessageProperty)props[RemoteEndpointMessageProperty.Name];
                // Retrieve the IP address
                string addr = prop.Address;
                int iPort = prop.Port;

                return addr;
            }
            catch (Exception ex)
            {
                return "Invalid IP Address.";/*"IPAdress : " + IPAdress + Environment.NewLine + "Message : " + ex.Message + "InnerException : " + ex.InnerException + "StackTrace : " + ex.StackTrace;*/
            }
        }
    }
}
