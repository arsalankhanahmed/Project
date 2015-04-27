using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.Net;
using System.Net.Mail;
using System.Net.NetworkInformation;

namespace SendingEmail
{
    public partial class Form1 : Form
    {
        string uId = "arsalan.ahmed@UDLD.BIZ";
        string pwd = "Start123987";
        int port = 587;
        string hostName = "mail.udld.biz";
        public Form1()
        {
            InitializeComponent();
        }

        private void btnSend_Click(object sender, EventArgs e)
        {

            SmtpClient objSmtpClient = new SmtpClient(hostName, port);
            //objSmtpClient.Port = 25;
            objSmtpClient.EnableSsl = true;
            objSmtpClient.Timeout = 30000;
            objSmtpClient.DeliveryMethod = SmtpDeliveryMethod.Network;
            objSmtpClient.UseDefaultCredentials = true;
            //objSmtpClient.Credentials = new System.Net.NetworkCredential(uId, pwd);
            objSmtpClient.Credentials = CredentialCache.DefaultNetworkCredentials;
            

            MailMessage msg = new MailMessage();
            //msg.To.Add(txtTo.Text);
            msg.From = new MailAddress(uId);
            msg.Subject = txtSubject.Text;
            msg.Body = txtMsg.Text;
            //Attachment objattachment = new Attachment(txtAttachFilePath);
            //msg.Attachment.Add(objAttachment);  
            //MailMessage msg = new MailMessage();
            //msg.From = new MailAddress(uId);
            //msg.To.Add(uId);
            //msg.Subject = "test";
            //msg.Body = "Test Content";
            //msg.Priority = MailPriority.High;

            //SmtpClient client = new SmtpClient(hostName);
            //client.Credentials = new NetworkCredential(uId, pwd);
            ////client.Host = hostName;
            //client.Port = port;
            //client.DeliveryMethod = SmtpDeliveryMethod.Network;
            //client.EnableSsl = true;
            //client.UseDefaultCredentials = false;

           
            try
            {
                //client.Send(msg);
                objSmtpClient.Send(uId, "arsalan.ahmed@udld.biz", "Test", "Test Body");
                MessageBox.Show("Message Sent Successfully");
            }
            catch (Exception ex) 
            {
                MessageBox.Show("Unsuccessful"+ex);
            }

        }
    }
}
