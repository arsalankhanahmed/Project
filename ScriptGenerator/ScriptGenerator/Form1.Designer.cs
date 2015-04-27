namespace ScriptGenerator
{
    partial class frmScriptGenerator
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
            this.btnGenerate = new System.Windows.Forms.Button();
            this.SaveFD = new System.Windows.Forms.SaveFileDialog();
            this.cblListBoxFileName = new System.Windows.Forms.CheckedListBox();
            this.FolderBD = new System.Windows.Forms.FolderBrowserDialog();
            this.groupBox1 = new System.Windows.Forms.GroupBox();
            this.rdoName = new System.Windows.Forms.RadioButton();
            this.rdoModifiedDate = new System.Windows.Forms.RadioButton();
            this.gbSortBy = new System.Windows.Forms.GroupBox();
            this.btnFetch = new System.Windows.Forms.Button();
            this.btnQuit = new System.Windows.Forms.Button();
            this.txtDirectoryName = new System.Windows.Forms.TextBox();
            this.btnUp = new System.Windows.Forms.Button();
            this.groupBox1.SuspendLayout();
            this.gbSortBy.SuspendLayout();
            this.SuspendLayout();
            // 
            // btnGenerate
            // 
            this.btnGenerate.Location = new System.Drawing.Point(211, 358);
            this.btnGenerate.Name = "btnGenerate";
            this.btnGenerate.Size = new System.Drawing.Size(71, 23);
            this.btnGenerate.TabIndex = 0;
            this.btnGenerate.Text = "Generate";
            this.btnGenerate.UseVisualStyleBackColor = true;
            this.btnGenerate.Click += new System.EventHandler(this.btnGenerate_Click);
            // 
            // cblListBoxFileName
            // 
            this.cblListBoxFileName.CheckOnClick = true;
            this.cblListBoxFileName.Dock = System.Windows.Forms.DockStyle.Fill;
            this.cblListBoxFileName.FormattingEnabled = true;
            this.cblListBoxFileName.Location = new System.Drawing.Point(3, 16);
            this.cblListBoxFileName.Name = "cblListBoxFileName";
            this.cblListBoxFileName.Size = new System.Drawing.Size(373, 262);
            this.cblListBoxFileName.TabIndex = 3;
            // 
            // groupBox1
            // 
            this.groupBox1.Controls.Add(this.cblListBoxFileName);
            this.groupBox1.Location = new System.Drawing.Point(4, 71);
            this.groupBox1.Name = "groupBox1";
            this.groupBox1.Size = new System.Drawing.Size(379, 281);
            this.groupBox1.TabIndex = 4;
            this.groupBox1.TabStop = false;
            this.groupBox1.Text = "File Names";
            // 
            // rdoName
            // 
            this.rdoName.AutoSize = true;
            this.rdoName.Checked = true;
            this.rdoName.Location = new System.Drawing.Point(59, 9);
            this.rdoName.Name = "rdoName";
            this.rdoName.Size = new System.Drawing.Size(53, 17);
            this.rdoName.TabIndex = 5;
            this.rdoName.TabStop = true;
            this.rdoName.Text = "Name";
            this.rdoName.UseVisualStyleBackColor = true;
            this.rdoName.CheckedChanged += new System.EventHandler(this.rdoName_CheckedChanged);
            // 
            // rdoModifiedDate
            // 
            this.rdoModifiedDate.AutoSize = true;
            this.rdoModifiedDate.Location = new System.Drawing.Point(114, 9);
            this.rdoModifiedDate.Name = "rdoModifiedDate";
            this.rdoModifiedDate.Size = new System.Drawing.Size(91, 17);
            this.rdoModifiedDate.TabIndex = 6;
            this.rdoModifiedDate.Text = "Modified Date";
            this.rdoModifiedDate.UseVisualStyleBackColor = true;
            // 
            // gbSortBy
            // 
            this.gbSortBy.Controls.Add(this.rdoModifiedDate);
            this.gbSortBy.Controls.Add(this.rdoName);
            this.gbSortBy.Location = new System.Drawing.Point(7, 35);
            this.gbSortBy.Name = "gbSortBy";
            this.gbSortBy.Size = new System.Drawing.Size(221, 30);
            this.gbSortBy.TabIndex = 8;
            this.gbSortBy.TabStop = false;
            this.gbSortBy.Text = "Sort By:";
            // 
            // btnFetch
            // 
            this.btnFetch.Location = new System.Drawing.Point(324, 12);
            this.btnFetch.Name = "btnFetch";
            this.btnFetch.Size = new System.Drawing.Size(59, 23);
            this.btnFetch.TabIndex = 9;
            this.btnFetch.Text = "Fetch";
            this.btnFetch.UseVisualStyleBackColor = true;
            this.btnFetch.Click += new System.EventHandler(this.btnFetch_Click);
            // 
            // btnQuit
            // 
            this.btnQuit.Location = new System.Drawing.Point(309, 358);
            this.btnQuit.Name = "btnQuit";
            this.btnQuit.Size = new System.Drawing.Size(71, 23);
            this.btnQuit.TabIndex = 10;
            this.btnQuit.Text = "Quit";
            this.btnQuit.UseVisualStyleBackColor = true;
            this.btnQuit.Click += new System.EventHandler(this.btnQuit_Click);
            // 
            // txtDirectoryName
            // 
            this.txtDirectoryName.Location = new System.Drawing.Point(7, 15);
            this.txtDirectoryName.Name = "txtDirectoryName";
            this.txtDirectoryName.ReadOnly = true;
            this.txtDirectoryName.Size = new System.Drawing.Size(311, 20);
            this.txtDirectoryName.TabIndex = 11;
            // 
            // btnUp
            // 
            this.btnUp.Location = new System.Drawing.Point(324, 152);
            this.btnUp.Name = "btnUp";
            this.btnUp.Size = new System.Drawing.Size(59, 23);
            this.btnUp.TabIndex = 12;
            this.btnUp.Text = "UP";
            this.btnUp.UseVisualStyleBackColor = true;
            this.btnUp.Visible = false;
            this.btnUp.Click += new System.EventHandler(this.btnUp_Click);
            // 
            // frmScriptGenerator
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(388, 401);
            this.Controls.Add(this.btnUp);
            this.Controls.Add(this.txtDirectoryName);
            this.Controls.Add(this.btnQuit);
            this.Controls.Add(this.btnFetch);
            this.Controls.Add(this.gbSortBy);
            this.Controls.Add(this.groupBox1);
            this.Controls.Add(this.btnGenerate);
            this.Name = "frmScriptGenerator";
            this.Text = "ScriptGenerator";
            this.Load += new System.EventHandler(this.frmScriptGenerator_Load);
            this.groupBox1.ResumeLayout(false);
            this.gbSortBy.ResumeLayout(false);
            this.gbSortBy.PerformLayout();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Button btnGenerate;
        private System.Windows.Forms.SaveFileDialog SaveFD;
        private System.Windows.Forms.CheckedListBox cblListBoxFileName;
        private System.Windows.Forms.FolderBrowserDialog FolderBD;
        private System.Windows.Forms.GroupBox groupBox1;
        private System.Windows.Forms.RadioButton rdoName;
        private System.Windows.Forms.RadioButton rdoModifiedDate;
        private System.Windows.Forms.GroupBox gbSortBy;
        private System.Windows.Forms.Button btnFetch;
        private System.Windows.Forms.Button btnQuit;
        private System.Windows.Forms.TextBox txtDirectoryName;
        private System.Windows.Forms.Button btnUp;
    }
}

