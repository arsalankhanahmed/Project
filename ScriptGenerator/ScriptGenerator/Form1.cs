using System;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.IO;

namespace ScriptGenerator
{
    public partial class frmScriptGenerator : Form
    {
        string strText = string.Empty;
        string[] files = { };
        string strDirectory = "";
        public frmScriptGenerator()
        {
            InitializeComponent();
        }

        private void frmScriptGenerator_Load(object sender, EventArgs e)
        {
        }

        public void ReadAllTextFromFile()
        {
            DialogResult fbdDialogRes = FolderBD.ShowDialog();
            if (fbdDialogRes == DialogResult.OK)
               GetFileNames(FolderBD.SelectedPath, "*.*");
            else
                return;
        }

        public void GetFileNames(string path, string filter)
        {
            cblListBoxFileName.Items.Clear();

            DirectoryInfo objDirectoryInfo = new DirectoryInfo(path);
            var result = objDirectoryInfo.GetFiles("*.*", SearchOption.TopDirectoryOnly).OrderBy(t => t.Name).ToList();
            
            if (rdoModifiedDate.Checked)
                result = objDirectoryInfo.GetFiles("*.*", SearchOption.TopDirectoryOnly).OrderByDescending(t => t.LastAccessTime).ToList();
                        
            for (int i = 0; i < result.LongCount(); i++)
            {
                cblListBoxFileName.Items.Add(result[i]);
            }
        }

        private void btnGenerate_Click(object sender, EventArgs e)
        {
            strText = GetSelecedFileName();
            SaveFile(strText);
            OpenFile(SaveFD.FileName);
        }

        public void SaveFile(string str)
        {
            SaveFD.Filter = "Text File (*.txt)|*.txt|"+
                "SQL Script (*.sql)|*.sql";
            DialogResult saveDialogResult = SaveFD.ShowDialog();
            if (saveDialogResult == DialogResult.OK)
            {
                StreamWriter swText = new StreamWriter(SaveFD.FileName, true);
                swText.Write(str);
                swText.Close();
            }
            else
            {
                return;
            }
        }
        
        public void OpenFile(string path)
        {
            DialogResult openDialogRes = MessageBox.Show( "Saved Successfully.Want to open file?","",MessageBoxButtons.YesNo);
            if (openDialogRes == DialogResult.Yes)
                System.Diagnostics.Process.Start(Path.GetDirectoryName(path));
        }

        public string GetSelecedFileName()
        {
            StringBuilder sbText = new StringBuilder(string.Empty);
            for (int i = 0; i < cblListBoxFileName.Items.Count; i++)
            {
                if (cblListBoxFileName.GetItemChecked(i))
                {
                    string strFileName = (string)cblListBoxFileName.Items[i].ToString();
                    StreamReader srText = File.OpenText(FolderBD.SelectedPath + "\\" + strFileName);
                    sbText.Append(srText.ReadToEnd());
                    sbText.Append(Environment.NewLine);
                    sbText.Append("GO");
                    sbText.Append(Environment.NewLine);
                    sbText.Append(Environment.NewLine);
                    srText.Close();
                }
            } 
            return sbText.ToString();
        }

        private void rdoName_CheckedChanged(object sender, EventArgs e)
        {
            GetFileNames(strDirectory, "*.*");
        }

        private void btnFetch_Click(object sender, EventArgs e)
        {
            ReadAllTextFromFile();
            strDirectory = txtDirectoryName.Text = FolderBD.SelectedPath.ToString();
        }

        private void btnQuit_Click(object sender, EventArgs e)
        {
            this.Close();
        }
        public void UpDownBtn() 
        {
            int up = cblListBoxFileName.SelectedIndex;
            up--;
            cblListBoxFileName.SelectedIndex = up;
        }

        private void btnUp_Click(object sender, EventArgs e)
        {
            cblListBoxFileName.SelectedIndex--;
            //UpDownBtn();
        }
    }
}
