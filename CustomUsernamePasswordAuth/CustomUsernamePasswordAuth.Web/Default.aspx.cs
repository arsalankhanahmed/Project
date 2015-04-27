using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using CustomUsernamePasswordAuth.Service;

namespace CustomUsernamePasswordAuth.Web
{
    public partial class _Default : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        protected void Button1_Click(object sender, EventArgs e)
        {
            CustomUsernamePasswordAuth.Service.Service1 s = new Service1();
            
            
            string serverTime = s.GetServertime();

            try
            {
                
               // proxy.ClientCredentials.UserName.UserName = username;
               // proxy.ClientCredentials.UserName.Password = password;
            }
            catch(Exception)
            {
            }
            Label1.Text = " Server Time :";
        }
    }
}