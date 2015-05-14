using System;
using System.ServiceModel;

namespace CustomUsernamePasswordAuth.Service
{
    class UserNamePassValidator : System.IdentityModel.Selectors.UserNamePasswordValidator
    {
        public override void Validate(string userName, string password)
        {
            if(  userName==null ||  password==null)
            {
                throw new ArgumentNullException();
            }

            if (!(userName == System.Configuration.ConfigurationSettings.AppSettings["ServiceUsername"].ToString() && password == System.Configuration.ConfigurationSettings.AppSettings["ServicePassword"].ToString()))
            {
                throw new FaultException("Incorrect Username or Password");
            }
        }
    }
}
