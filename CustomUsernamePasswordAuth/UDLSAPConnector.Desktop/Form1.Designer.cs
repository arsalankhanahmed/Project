namespace CustomUsernamePasswordAuth.Desktop
{
    partial class Form1
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.button1 = new System.Windows.Forms.Button();
            this.label1 = new System.Windows.Forms.Label();
            this.txtServiceAddress = new System.Windows.Forms.TextBox();
            this.gbLogIn = new System.Windows.Forms.GroupBox();
            this.label2 = new System.Windows.Forms.Label();
            this.txtUId = new System.Windows.Forms.TextBox();
            this.txtPwd = new System.Windows.Forms.TextBox();
            this.label3 = new System.Windows.Forms.Label();
            this.gbLogIn.SuspendLayout();
            this.SuspendLayout();
            // 
            // button1
            // 
            this.button1.Location = new System.Drawing.Point(373, 145);
            this.button1.Name = "button1";
            this.button1.Size = new System.Drawing.Size(94, 23);
            this.button1.TabIndex = 0;
            this.button1.Text = "Get server time";
            this.button1.UseVisualStyleBackColor = true;
            this.button1.Click += new System.EventHandler(this.button1_Click);
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(15, 120);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(113, 13);
            this.label1.TabIndex = 1;
            this.label1.Text = "WCF Service address:";
            // 
            // txtServiceAddress
            // 
            this.txtServiceAddress.Location = new System.Drawing.Point(131, 117);
            this.txtServiceAddress.Name = "txtServiceAddress";
            this.txtServiceAddress.Size = new System.Drawing.Size(336, 20);
            this.txtServiceAddress.TabIndex = 2;
            this.txtServiceAddress.Text = "http://localhost:83/UserNamePassService.svc";
            // 
            // gbLogIn
            // 
            this.gbLogIn.Controls.Add(this.txtPwd);
            this.gbLogIn.Controls.Add(this.label3);
            this.gbLogIn.Controls.Add(this.txtUId);
            this.gbLogIn.Controls.Add(this.label2);
            this.gbLogIn.Location = new System.Drawing.Point(15, 12);
            this.gbLogIn.Name = "gbLogIn";
            this.gbLogIn.Size = new System.Drawing.Size(452, 88);
            this.gbLogIn.TabIndex = 0;
            this.gbLogIn.TabStop = false;
            this.gbLogIn.Text = "Log In";
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(17, 32);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(66, 13);
            this.label2.TabIndex = 0;
            this.label2.Text = "User Name :";
            // 
            // txtUId
            // 
            this.txtUId.Location = new System.Drawing.Point(116, 25);
            this.txtUId.Name = "txtUId";
            this.txtUId.Size = new System.Drawing.Size(304, 20);
            this.txtUId.TabIndex = 1;
            // 
            // txtPwd
            // 
            this.txtPwd.Location = new System.Drawing.Point(116, 52);
            this.txtPwd.Name = "txtPwd";
            this.txtPwd.Size = new System.Drawing.Size(304, 20);
            this.txtPwd.TabIndex = 3;
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Location = new System.Drawing.Point(17, 59);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(59, 13);
            this.label3.TabIndex = 0;
            this.label3.Text = "Password :";
            // 
            // Form1
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(479, 180);
            this.Controls.Add(this.gbLogIn);
            this.Controls.Add(this.txtServiceAddress);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.button1);
            this.Name = "Form1";
            this.Text = "Form1";
            this.gbLogIn.ResumeLayout(false);
            this.gbLogIn.PerformLayout();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Button button1;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.TextBox txtServiceAddress;
        private System.Windows.Forms.GroupBox gbLogIn;
        private System.Windows.Forms.TextBox txtPwd;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.TextBox txtUId;
        private System.Windows.Forms.Label label2;
    }
}

