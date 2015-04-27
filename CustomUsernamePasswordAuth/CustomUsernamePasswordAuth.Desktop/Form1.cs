using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using CustomUsernamePasswordAuth.Desktop.ServiceReference1;
using System.ServiceModel;
using System.ServiceModel.Description;
using System.ServiceModel.Security;

namespace CustomUsernamePasswordAuth.Desktop
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
        }

        private void button1_Click(object sender, EventArgs e)
        {
            try
            {
                string time = "";
                // Method 1: Create the client using the configuration file

                Service1Client c = new Service1Client();
                c.ClientCredentials.UserName.UserName = "fayaz";
                c.ClientCredentials.UserName.Password = "fayaz1";
                c.ClientCredentials.ServiceCertificate.Authentication.CertificateValidationMode = X509CertificateValidationMode.None;
                time = c.GetServertime();
                MessageBox.Show(time);

                // Method 2: Creating the client by creating endpoint and binding through coding
                var ServiceendPoint = new EndpointAddress(new Uri(txtServiceAddress.Text), EndpointIdentity.CreateDnsIdentity("MyWebSite"));
                var binding = new WSHttpBinding();
                binding.Security.Mode = SecurityMode.Message;
                binding.Security.Message.ClientCredentialType = MessageCredentialType.UserName;

                var result = new Service1Client(binding, ServiceendPoint);
                result.ClientCredentials.ServiceCertificate.Authentication.CertificateValidationMode = X509CertificateValidationMode.None;
                result.ClientCredentials.UserName.UserName = txtUId.Text;
                result.ClientCredentials.UserName.Password = txtPwd.Text;
                time = result.GetServertime();
                MessageBox.Show(time);
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }
    }
}
