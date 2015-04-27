using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace CodeHuntLevel_3._7
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
        }

        public string Puzzle(string s)
        {
            int m = 5;
            Math.Pow(m, 2);
            
            char[] c = new char[s.Length];
            for (int i = 0; i < s.Length; i++)
                c[i] = (char)((s[i] + m - (int)'a') % 26 + (int)'a');
            return new String(c);
        }

        private void Form1_Load(object sender, EventArgs e)
        {
           
        }

        private void txtEnter_TextChanged(object sender, EventArgs e)
        {
            //txtResult.Text = Puzzle(txtEnter.Text);
            //bool x = false;
            //bool y = true;
            //bool res = x || y ? true : false;
            //txtResult.Text = (x || y ? true : false).ToString();//.ToString();
        }

        private void txtEnter_Leave(object sender, EventArgs e)
        {
            string s = txtEnter.Text;
            //string str = "";
            //for(int i = 0 ; i < s.Length; i++)
            //{
            //   if (i==s.Length-1 || s[i+1].Equals(' '))
            //        str += Char.ToUpper(s[i]);
            //   else
            //       str += s[i];
            //}
            //txtResult.Text = str;
            //int x = 0;
            //string str = "";
            //string vowels = "aeiou";
            //str = s.Replace("a", "").Replace("e", "").Replace("i", "").Replace("o", "").Replace("u", "");
            //str = new string(s.Where(c => !vowels.Contains(c)).ToArray());
            //bool bol = s.Contains('r');
            //txtResult.Text = str;
            //str = s.Substring((s.Length / 2)+1).ToUpper();
            //str += s.Substring(s.Length/2);
            //char[] charArray = s.ToCharArray();
            //Array.Reverse(charArray);
            //return s + new string(charArray);
            //Array.Reverse(charArray);
            //return s + new string(charArray);
            //txtResult.Text = s + new string(charArray); // s.Substring(s.Length - 3, 3);
            //txtResult.Text = s[x].ToString();
            string a, b, c = "";
            a = "a";
            b = "r";
            c = "l";
            bool IF = s.Contains(a);// + b + c);
            //repeated String 
            b = string.Join(" ", Enumerable.Repeat('a', 2));
            string output = "";
            int space = 1;
            for (char start = '`'; start < 'z'; start++) 
            {
                //start = (char)96;
                //output += start;
                output += (char)(start + space);
                output += new String(' ',1);
            }
            txtResult.Text = output.TrimEnd();

            //factorile
            //int res = 0;
            //int lowerLimit = 2;
            //int upperLimit = 3;
            //for (int o = upperLimit; o >= lowerLimit; o--)
            //{
            //    res += Factorial(o, lowerLimit);
            //}
            int n = 2;
            string str = "";
            for (int i = 0; i <= n; i++)
            {
                str += string.Join(" ",Enumerable.Repeat('#', i));
            }
            txtResult.Text =  str;  
        }

        int Factorial(int u, int l) 
        {
            int res = 1;
            for (int it = l; it <= u; it++)
                res = res * it;
            return res;
        }
    }
}

