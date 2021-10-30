using System;
using System.Collections.Generic;

namespace LT
{
    public interface LValue
    {
        string encode();
    }
    [System.Serializable]
    public class LNum : LValue
    {
        public double data;
        public LNum(int n)
        {
            data = (double)n;
        }
        public LNum(Int64 n)
        {
            data = (double)n;
        }
        public LNum(float n)
        {
            data = (double)n;
        }
        public string encode()
        {
            return data.ToString();
        }
        public override bool Equals(System.Object obj)
        {
            if (obj == null)
            {
                return false;
            }
            LNum p = obj as LNum;
            if ((System.Object)p == null)
            {
                return false;
            }
            return Math.Abs(data - p.data) <= 0.01;
        }
        public override int GetHashCode()
        {
            return data.GetHashCode();
        }
    }
    [System.Serializable]
    public class LString : LValue
    {
        public string data;
        public LString(string s)
        {
            data = s;
        }
        public string encode()
        {
            if(data == null){
                return null;
            }else
            {
                string str = data.ToString();
                str = str.Replace("\n", "\\\n");
                return str;
            }
        }
        public override bool Equals(System.Object obj)
        {
            if (obj == null)
            {
                return false;
            }
            LString p = obj as LString;
            if ((System.Object)p == null)
            {
                return false;
            }
            return p.data == data;
        }
        public override int GetHashCode()
        {
            return data.GetHashCode();
        }
    }
    [System.Serializable]
    public class LColor : LValue {
        public float r, g, b, a;
        public LColor(float r, float g, float b, float a) {
            this.r = r; this.g = g; this.b = b; this.a = a;
        }
        public LColor(UnityEngine.Color v) {
            this.r = v.r; this.g = v.g; this.b = v.b; this.a = v.a;
        }
        public string encode() {
            return string.Format("{0}{1},{2},{3},{4}{5}", "{", r, g, b, a, "}");
        }
    }
    [System.Serializable]
    public class LVector3 : LValue {
        public float x;
        public float y;
        public float z;
        public LVector3(float x, float y, float z) {
            this.x = x; this.y = y; this.z = z;
        }
        public LVector3(UnityEngine.Vector3 v) {
            this.x = v.x; this.y = v.y; this.z = v.z;
        }
        public string encode() {
            return string.Format("{0}{1:f2}, {2:f2}, {3:f2}{4}", "{", x, y, z, "}");
        }
    }

    [System.Serializable]
    public class LVector2 : LValue
    {
        public float x;
        public float y;
        public LVector2(float x, float y)
        {
            this.x = x; this.y = y; 
        }
        public LVector2(UnityEngine.Vector2 v)
        {
            this.x = v.x; this.y = v.y; 
        }
        public string encode()
        {
            return string.Format("{0}{1:f2}, {2:f2}{3}", "{", x, y, "}");
        }
    }

    [System.Serializable]
    public class LBool : LValue
    {
        public bool data;
        public LBool(bool b)
        {
            data = b;
        }
        public string encode()
        {
            return data ? "true" : "false";
        }
        public override bool Equals(System.Object obj)
        {
            if (obj == null)
            {
                return false;
            }
            LBool p = obj as LBool;
            if ((System.Object)p == null)
            {
                return false;
            }
            return p.data == data;
        }
        public override int GetHashCode()
        {
            return data.GetHashCode();
        }
    }
}
