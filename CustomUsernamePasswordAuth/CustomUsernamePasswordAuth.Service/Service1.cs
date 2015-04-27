using System;
using System.ServiceModel;
using System.Text;

namespace CustomUsernamePasswordAuth.Service
{
    [ServiceContract]
    public interface IService1
    {
        [OperationContract]
        string GetServertime();
    }

    [ServiceBehavior(IncludeExceptionDetailInFaults = true)]
    public class Service1 : IService1
    {  
        public string GetServertime()
        {
            return DateTime.Now.ToString();
        }
    }
}
