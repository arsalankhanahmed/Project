<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="CustomUsernamePasswordAuth.Web._Default" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div >
    
        User Name
        <asp:TextBox ID="txtUName" runat="server">fayaz</asp:TextBox>
        <br />
        Passwoed&nbsp;&nbsp;
        <asp:TextBox ID="txtPass" runat="server" TextMode="Password">fayaz1</asp:TextBox>
        <br /><asp:Button ID="Button1" runat="server" Text="Get ServerTime" 
            Width="110px" onclick="Button1_Click" />
    
        <asp:Label ID="Label1" runat="server" Text="Server Time :"></asp:Label>
    
    </div>
  
    </form>
</body>
</html>
