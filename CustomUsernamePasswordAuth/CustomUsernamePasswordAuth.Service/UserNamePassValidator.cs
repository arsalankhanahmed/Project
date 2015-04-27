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

            if (!(userName == "fayaz" && password == "fayaz1") )
            {
                throw new FaultException("Incorrect Username or Password");
            }
        }
    }
}
