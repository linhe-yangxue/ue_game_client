using System;
using System.Collections.Generic;
using System.Text;
using System.Text.RegularExpressions;

namespace LT
{
    public class LTable : LValue
    {
        private Dictionary<LValue, LValue> data = new Dictionary<LValue, LValue>();
        public LTable(bool is_one_line)
        {
            this.is_one_line = is_one_line;
        }
        private bool is_one_line { get; set; }
        public LTable parent { get; set; }
        public int deep { get; set; }
        public LValue this[int key]
        {
            get
            {
                LNum n = new LNum(key);
                return this[n];
            }
            set
            {
                LNum n = new LNum(key);
                this[n] = value;
            }
        }
        public LValue this[float key]
        {
            get
            {
                LNum n = new LNum(key);
                return this[n];
            }
            set
            {
                LNum n = new LNum(key);
                this[n] = value;
            }
        }
        public LValue this[string key]
        {
            get
            {
                LString k = new LString(key);
                return this[k];
            }
            set
            {
                LString k = new LString(key);
                this[k] = value;
            }
        }
        public LValue this[LValue key]
        {
            get
            {
                LValue v = null;
                if (data.TryGetValue(key, out v))
                {
                    return v;
                }
                return null;
            }
            set
            {
                if (value == null)
                {
                    data.Remove(key);
                    return;
                }
                data[key] = value;
            }
        }

        public Dictionary<LValue, LValue> GetData()
        {
            return data;
        }

        public string encode()
        {
            try
            {
                if (data.Keys.Count == 0) return "{}";
                var sb = new StringBuilder();
                var tmpsb = new StringBuilder();
                for (int i = 0; i < deep; ++i)
                {
                    tmpsb.Append("\t");
                }
                var deep_token = tmpsb.ToString();
                sb.Append("{");
                if (!is_one_line)
                {
                    sb.Append("\n\t");
                    sb.Append(deep_token);
                }
                var value_token = is_one_line ? ", " : ",\n\t" + deep_token;

                foreach (KeyValuePair<LValue, LValue> p in data)
                {
                    string key = p.Key.encode();
                    LTable lt = p.Value as LTable;
                    if (lt != null) lt.deep = this.deep + 1;
                    string v = p.Value.encode();
                    if (p.Key as LNum != null)
                    {
                        key = string.Format("[{0}]", key);
                    }
                    else if (Regex.IsMatch(key, "[\\W]"))
                    {
                        key = string.Format("[\'{0}\']", key);
                    }
                    else if (p.Key as LString != null)
                    {
                        key = string.Format("[\'{0}\']", key);
                    }
                    if (p.Value as LString != null)
                    {
                        v = string.Format("\'{0}\'", v);
                    }
                    sb.Append(key); sb.Append(" = "); sb.Append(v); sb.Append(value_token);
                }
                sb.Remove(sb.Length - value_token.Length, value_token.Length);
                if (!is_one_line) sb.Append("\n");
                if (!is_one_line)
                {
                    sb.Append(deep_token);
                }
                sb.Append("}");
                return sb.ToString();
            }
            catch (Exception e)
            {
                UnityEngine.Debug.LogError(e);
                return null;
            }
        }
    }
}
