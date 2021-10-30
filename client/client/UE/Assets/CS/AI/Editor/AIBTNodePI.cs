using System.Collections.Generic;
using System.Text;
using LT;
using PI;
using UnityEngine;

namespace AI
{
    [System.Serializable]
    [LTable(gen_by_self = true)]
    public class Weights : ParamDataInterface
    {
        public List<SharedFloat> weights_ = new List<SharedFloat>();

        public LValue gen_ltable(bool is_one_line)
        {
            LTable lt = new LTable(true);
            for (int i = 0; i < weights_.Count; ++i)
            {
                lt[i + 1] = weights_[i].gen_ltable(true);
            }
            return lt;
        }

        public ParamDataInterface Copy()
        {
            Weights ret = new Weights();
            for (int i = 0; i < weights_.Count; ++i)
            {
                SharedFloat value = new SharedFloat(weights_[i].value_);
                ret.weights_.Add(value);
            }
            return ret;
        }
        public void Draw() { }

        public string DoSerialize()
        {
           
            StringBuilder ret = new StringBuilder();
            for (int i = 0; i < weights_.Count; ++i)
            {
                ret.Append(weights_[i].DoSerialize());
                if (i + 1 < weights_.Count) ret.Append(':');
            }
            return ret.ToString();
        }

        public void DoDeserialize(string content)
        {
            string[] ret = content.Split(':');
            for (int i = 0; i < ret.Length; ++i)
            {
                if (!string.IsNullOrEmpty(ret[i]))
                {
                    SharedFloat sf = new SharedFloat();
                    sf.DoDeserialize(ret[i]);
                    weights_.Add(sf);
                }
            }
        }
    }

    [System.Serializable]
    [LTable(gen_by_self = true)]
    public class Comparator : ParamDataInterface
    {
        public string value_type_ = "string";

        public ValueType value1_type_ = ValueType.VT_Value;
        public ValueType value2_type_ = ValueType.VT_Value;

        public string variable1_name_;
        public string variable2_name_;

        public object value1_;
        public object value2_;

        public CompareType compare_type_ = CompareType.CT_Equal;

        public LValue gen_ltable(bool is_one_line)
        {
            return new LTable(is_one_line);
        }
        public void Draw() { }

        public LValue GetLValue(int i)
        {
            object value;
            if (i == 1) value = value1_;
            else if (i == 2) value = value2_;
            else return null;
            switch (value_type_)
            {
                case "string":
                    return new LString((string)value);
                case "int":
                    return new LNum((int)value);
                case "float":
                    return new LNum((float)value);
                case "bool":
                    return new LBool((bool)value);
                case "Vector2":
                    return new LVector3((Vector2)value);
                case "Vector3":
                    return new LVector3((Vector3)value);
                default:
                    return null;
            }
        }

        public void GenLTable(LTable table)
        {
            if (table == null) table = new LTable(false);
            table["value1_type"] = new LNum((int)value1_type_);
            table["value2_type"] = new LNum((int)value2_type_);
            if (value1_type_ == ValueType.VT_Value)
            {
                table["value1"] = GetLValue(1);
            }
            else
            {
                table["value1"] = new LString(variable1_name_);
            }
            if (value2_type_ == ValueType.VT_Value)
            {
                table["value2"] = GetLValue(2);
            }
            else
            {
                table["value2"] = new LString(variable2_name_);
            }
            table["compare_type"] = new LNum((int)compare_type_);
        }

        public void ClearValues(int flag = 1, int indexFlag = 1)   // flag 1:全清 2:清value 3:清variable; indexFlag 1:全清 2:清1 3:清2
        {
            if (3 % flag == 0)
            {
                if (3 % indexFlag == 0)
                    variable2_name_ = "";
                if (2 % indexFlag == 0)
                    variable1_name_ = "";
            }
            if (2 % flag == 0)
            {
                switch (value_type_)
                {
                    case "string":
                        if (3 % indexFlag == 0)
                            value2_ = "";
                        if (2 % indexFlag == 0)
                            value1_ = "";
                        break;
                    case "int":
                    case "float":
                        if (3 % indexFlag == 0)
                            value2_ = 0;
                        if (2 % indexFlag == 0)
                            value1_ = 0;
                        break;
                    case "bool":
                        if (3 % indexFlag == 0)
                            value2_ = false;
                        if (2 % indexFlag == 0)
                            value1_ = false;
                        break;
                    case "Vector2":
                        if (3 % indexFlag == 0)
                            value2_ = Vector2.zero;
                        if (2 % indexFlag == 0)
                            value1_ = Vector2.zero;
                        break;
                    case "Vector3":
                        if (3 % indexFlag == 0)
                            value2_ = Vector3.zero;
                        if (2 % indexFlag == 0)
                            value1_ = Vector3.zero;
                        break;
                }
            }
        }

        public string GetSerializeValue()
        {
            switch (value_type_)
            {
                case "string":
                    return (string)value1_ + "," + (string)value2_ + ",";
                case "int":
                    return ((int)value1_).ToString() + "," + ((int)value2_).ToString() + ",";
                case "float":
                    return ((float)value1_).ToString() + "," + ((float)value2_).ToString() + ",";
                case "bool":
                    return ((bool)value1_).ToString() + "," + ((bool)value2_).ToString() + ",";
                case "Vector2":
                    Vector2 vector2 = (Vector2)value1_;
                    StringBuilder vector2Str = new StringBuilder();
                    vector2Str.Append(vector2.x + ":" + vector2.y + ",");
                    vector2 = (Vector2)value2_;
                    vector2Str.Append(vector2.x + ":" + vector2.y + ",");
                    return vector2Str.ToString();
                case "Vector3":
                    Vector3 vector3 = (Vector3)value1_;
                    StringBuilder vector3Str = new StringBuilder();
                    vector3Str.Append(vector3.x + ":" + vector3.y + ":" + vector3.z + ",");
                    vector3 = (Vector3)value2_;
                    vector3Str.Append(vector3.x + ":" + vector3.y + ":" + vector3.z + ",");
                    return vector3Str.ToString();
                default:
                    return ",,";
            }
        }

        public void GetDeserializeValue(string serializedStr1, string serializedStr2)
        {
            if (!string.IsNullOrEmpty(serializedStr1) && !string.IsNullOrEmpty(serializedStr2))
            {
                try
                {
                    switch (value_type_)
                    {
                        case "string":
                            value1_ = serializedStr1;
                            value2_ = serializedStr2;
                            break;
                        case "int":
                            value1_ = int.Parse(serializedStr1);
                            value2_ = int.Parse(serializedStr2);
                            break;
                        case "float":
                            value1_ = float.Parse(serializedStr1);
                            value2_ = float.Parse(serializedStr2);
                            break;
                        case "bool":
                            value1_ = bool.Parse(serializedStr1);
                            value2_ = bool.Parse(serializedStr2);
                            break;
                        case "Vector2":
                            string[] vector2_value = serializedStr1.Split(':');
                            value1_ = new Vector2(float.Parse(vector2_value[0]), float.Parse(vector2_value[1]));
                            vector2_value = serializedStr2.Split(':');
                            value2_ = new Vector2(float.Parse(vector2_value[0]), float.Parse(vector2_value[1]));
                            break;
                        case "Vector3":
                            string[] vector3_value = serializedStr1.Split(':');
                            value1_ = new Vector3(float.Parse(vector3_value[0]), float.Parse(vector3_value[1]), float.Parse(vector3_value[2]));
                            vector3_value = serializedStr2.Split(':');
                            value1_ = new Vector3(float.Parse(vector3_value[0]), float.Parse(vector3_value[1]), float.Parse(vector3_value[2]));
                            break;
                    }
                }
                catch (System.Exception e)
                {
                    Debug.LogError(serializedStr1 + " " + serializedStr2);
                    Debug.LogError(e.Message);
                    ClearValues(2);
                }
            }
            else
            {
                ClearValues(2);
            }
        }

        public ParamDataInterface Copy()
        {
            Comparator ret = new Comparator();
            ret.value_type_ = value_type_;
            ret.value1_type_ = value1_type_;
            ret.value2_type_ = value2_type_;
            ret.variable1_name_ = variable1_name_;
            ret.variable2_name_ = variable2_name_;
            ret.value1_ = value1_;
            ret.value2_ = value2_;
            ret.compare_type_ = compare_type_;
            return ret;
        }

        public string DoSerialize()
        {
            StringBuilder ret = new StringBuilder();
            ret.Append(value_type_ + ",");
            ret.Append((int)value1_type_ + "," + (int)value2_type_ + ",");
            ret.Append(variable1_name_ + "," + variable2_name_ + ",");
            ret.Append(GetSerializeValue());
            ret.Append((int)compare_type_);
            return ret.ToString();
        }

        public void DoDeserialize(string content)
        {
            string[] ret = content.Split(',');
            value_type_ = ret[0];
            value1_type_ = (ValueType)int.Parse(ret[1]);
            value2_type_ = (ValueType)int.Parse(ret[2]);
            variable1_name_ = ret[3];
            variable2_name_ = ret[4];
            GetDeserializeValue(ret[5], ret[6]);
            compare_type_ = (CompareType)int.Parse(ret[7]);
        }
    }

    [System.Serializable]
    [LTable(gen_by_self = true)]
    public class SharedString : ParamDataInterface
    {
        public ValueType value_type_ = ValueType.VT_Value;
        public string value_ = "";
        public string variable_name_ = "";

        public SharedString() { }

        public SharedString(string v)
        {
            value_ = v;
        }

        public ParamDataInterface Copy()
        {
            SharedString ret = new SharedString();
            ret.value_type_ = value_type_;
            ret.value_ = value_;
            ret.variable_name_ = variable_name_;
            return ret;
        }
        public void Draw() { }

        public LValue gen_ltable(bool one_line)
        {
            if (value_type_ == ValueType.VT_Value)
                return new LString(value_);
            else
                return new LString(variable_name_);
        }

        public string DoSerialize()
        {
            return (int)value_type_ + "," + value_ + "," + variable_name_;
        }

        public void DoDeserialize(string content)
        {
            string[] ret = content.Split(',');
            value_type_ = (ValueType)int.Parse(ret[0]);
            value_ = ret[1];
            variable_name_ = ret[2];
        }
    }

    [System.Serializable]
    [LTable(gen_by_self = true)]
    public class SharedInt : ParamDataInterface
    {
        public ValueType value_type = ValueType.VT_Value;
        public int value = 0;
        public string variable_name = "";

        public SharedInt() { }

        public SharedInt(int v)
        {
            value = v;
        }

        public ParamDataInterface Copy()
        {
            SharedInt ret = new SharedInt();
            ret.value_type = value_type;
            ret.value = value;
            ret.variable_name = variable_name;
            return ret;
        }

        public LValue gen_ltable(bool one_line)
        {
            if (value_type == ValueType.VT_Value)
                return new LNum(value);
            else
                return new LString(variable_name);
        }
        public void Draw() { }

        public string DoSerialize()
        {
            return (int)value_type + "," + value.ToString() + "," + variable_name;
        }

        public void DoDeserialize(string content)
        {
            string[] ret = content.Split(',');
            value_type = (ValueType)int.Parse(ret[0]);
            value = int.Parse(ret[1]);
            variable_name = ret[2];
        }
    }

    [System.Serializable]
    [LTable(gen_by_self = true)]
    public class SharedFloat : ParamDataInterface
    {
        public ValueType value_type_ = ValueType.VT_Value;
        public float value_ = 0f;
        public string variable_name_ = "";

        public SharedFloat() { }

        public SharedFloat(float v)
        {
            value_ = v;
        }

        public ParamDataInterface Copy()
        {
            SharedFloat ret = new SharedFloat();
            ret.value_type_ = value_type_;
            ret.value_ = value_;
            ret.variable_name_ = variable_name_;
            return ret;
        }

        public LValue gen_ltable(bool one_line)
        {
            if (value_type_ == ValueType.VT_Value)
                return new LNum(value_);
            else
                return new LString(variable_name_);
        }
        public void Draw() { }

        public string DoSerialize()
        {
            return (int)value_type_ + "," + value_.ToString() + "," + variable_name_;
        }

        public void DoDeserialize(string content)
        {
            string[] ret = content.Split(',');
            value_type_ = (ValueType)int.Parse(ret[0]);
            value_ = float.Parse(ret[1]);
            variable_name_ = ret[2];
        }
    }

    [System.Serializable]
    [LTable(gen_by_self = true)]
    public class SharedBool : ParamDataInterface
    {
        public ValueType value_type_ = ValueType.VT_Value;
        public bool value_ = false;
        public string variable_name_ = "";

        public SharedBool() { }

        public SharedBool(bool v)
        {
            value_ = v;
        }

        public ParamDataInterface Copy()
        {
            SharedBool ret = new SharedBool();
            ret.value_type_ = value_type_;
            ret.value_ = value_;
            ret.variable_name_ = variable_name_;
            return ret;
        }

        public LValue gen_ltable(bool one_line)
        {
            if (value_type_ == ValueType.VT_Value)
                return new LBool(value_);
            else
                return new LString(variable_name_);
        }
        public void Draw() { }

        public string DoSerialize()
        {
            return (int)value_type_ + "," + value_.ToString() + "," + variable_name_;
        }

        public void DoDeserialize(string content)
        {
            string[] ret = content.Split(',');
            value_type_ = (ValueType)int.Parse(ret[0]);
            value_ = bool.Parse(ret[1]);
            variable_name_ = ret[2];
        }
    }

    [System.Serializable]
    [LTable(gen_by_self = true)]
    public class SharedVector2 : ParamDataInterface
    {
        public ValueType value_type_ = ValueType.VT_Value;
        public Vector2 value_ = Vector2.zero;
        public string variable_name_ = "";

        public SharedVector2() { }

        public SharedVector2(Vector2 v)
        {
            value_ = v;
        }

        public ParamDataInterface Copy()
        {
            SharedVector2 ret = new SharedVector2();
            ret.value_type_ = value_type_;
            ret.value_ = value_;
            ret.variable_name_ = variable_name_;
            return ret;
        }

        public LValue gen_ltable(bool one_line)
        {
            if (value_type_ == ValueType.VT_Value)
                return new LVector3(value_);
            else
                return new LString(variable_name_);
        }
        public void Draw() { }

        public string DoSerialize()
        {
            return (int)value_type_ + "," + value_.x.ToString() + ":" + value_.y.ToString() + "," + variable_name_;
        }

        public void DoDeserialize(string content)
        {
            string[] ret = content.Split(',');
            value_type_ = (ValueType)int.Parse(ret[0]);
            string[] vector2 = ret[1].Split(':');
            value_.x = float.Parse(vector2[0]);
            value_.y = float.Parse(vector2[1]);
            variable_name_ = ret[2];
        }
    }

    [System.Serializable]
    [LTable(gen_by_self = true)]
    public class SharedVector3 : ParamDataInterface
    {
        public ValueType value_type_ = ValueType.VT_Value;
        public Vector3 value_ = Vector3.zero;
        public string variable_name_ = "";

        public SharedVector3() { }

        public SharedVector3(Vector3 v)
        {
            value_ = v;
        }

        public ParamDataInterface Copy()
        {
            SharedVector3 ret = new SharedVector3();
            ret.value_type_ = value_type_;
            ret.value_ = value_;
            ret.variable_name_ = variable_name_;
            return ret;
        }

        public LValue gen_ltable(bool one_line)
        {
            if (value_type_ == ValueType.VT_Value)
                return new LVector3(value_);
            else
                return new LString(variable_name_);
        }
        public void Draw() { }

        public string DoSerialize()
        {
            return (int)value_type_ + "," + value_.x.ToString() + ":" + value_.y.ToString() + ":" + value_.z.ToString() + "," + variable_name_;
        }

        public void DoDeserialize(string content)
        {
            string[] ret = content.Split(',');
            value_type_ = (ValueType)int.Parse(ret[0]);
            string[] vector3 = ret[1].Split(':');
            value_.x = float.Parse(vector3[0]);
            value_.y = float.Parse(vector3[1]);
            value_.z = float.Parse(vector3[2]);
            variable_name_ = ret[2];
        }
    }

    [System.Serializable]
    [LTable(gen_by_self = true)]
    public class AIBTNodePI : ParamInterface  //该节点的行为属性
    {
        public string type_;

        public List<ParamData> data_;

        public AIBTNodePI(string type)
        {
            type_ = type;
            data_ = new List<ParamData>();
        }

        public AIBTNodePI Copy()
        {
            AIBTNodePI ret = new AIBTNodePI(type_);
            ret.data_.Clear();
            foreach (ParamData p in data_)
            {
                ret.data_.Add(p.Copy());
            }
            return ret;
        }

        public ParamData Find(string key, bool get_default = true)
        {
            ParamData ret = data_.Find(
                (x => x.key == key)
            );
            if (ret == null && get_default)
            {
                if (!AIConst.kDefaultParamValue.TryGetValue(key, out ret)) ret = null;
                else if (ret.v_custom != null) data_.Add(ret.Copy());       // 当默认值为自定义类类型时，把值的拷贝加到data里，编辑器就不需要多次将类对象去Set到data里
            }
            return ret;
        }

        public string GetStringParam(string key)
        {
            ParamData pd = Find(key);
            if (pd == null)
            {
                data_.Add(new ParamData(key, ""));
                return "";
            }
            return pd.type == typeof(string).Name ? pd.v_string : null;
        }

        public int GetIntParam(string key)
        {
            ParamData pd = Find(key);
            if (pd == null)
            {
                data_.Add(new ParamData(key, 0));
                return 0;
            }
            return pd.type == typeof(int).Name ? pd.v_int : 0;
        }

        public float GetFloatParam(string key)
        {
            ParamData pd = Find(key);
            if (pd == null)
            {
                data_.Add(new ParamData(key, 0));
                return 0;
            }
            return pd.type == typeof(float).Name ? pd.v_float : 0;
        }

        public bool GetBoolParam(string key)
        {
            ParamData pd = Find(key);
            if (pd == null)
            {
                data_.Add(new ParamData(key, false));
                return false;
            }
            return pd.type == typeof(bool).Name ? pd.v_bool : false;
        }

        public Vector2 GetVector2Param(string key)
        {
            ParamData pd = Find(key);
            if (pd == null)
            {
                data_.Add(new ParamData(key, Vector2.zero));
                return Vector2.zero;
            }
            return pd.type == typeof(Vector2).Name ? pd.v_vector2 : Vector2.zero;
        }

        public Vector3 GetVector3Param(string key)
        {
            ParamData pd = Find(key);
            if (pd == null)
            {
                data_.Add(new ParamData(key, Vector3.zero));
                return Vector3.zero;
            }
            return pd.type == typeof(Vector3).Name ? pd.v_vector3 : Vector3.zero;
        }

        public ParamDataInterface GetObjectParam(string key)
        {
            ParamData pd = Find(key);
            if (pd == null)
            {
                return null;
            }
            return pd.type == typeof(ParamDataInterface).Name ? pd.v_custom : null;
        }

        public void SetParam(string key, string value)
        {
            ParamData pd = Find(key, false);
            if (pd != null)
            {
                pd.SetValue(value);
                return;
            }
            data_.Add(new ParamData(key, value));
        }

        public void SetParam(string key, int value)
        {
            ParamData pd = Find(key, false);
            if (pd != null)
            {
                pd.SetValue(value);
                return;
            }
            data_.Add(new ParamData(key, value));
        }

        public void SetParam(string key, float value)
        {
            ParamData pd = Find(key, false);
            if (pd != null)
            {
                pd.SetValue(value);
                return;
            }
            data_.Add(new ParamData(key, value));
        }

        public void SetParam(string key, bool value)
        {
            ParamData pd = Find(key, false);
            if (pd != null)
            {
                pd.SetValue(value);
                return;
            }
            data_.Add(new ParamData(key, value));
        }

        public void SetParam(string key, Vector2 value)
        {
            ParamData pd = Find(key, false);
            if (pd != null)
            {
                pd.SetValue(value);
                return;
            }
            data_.Add(new ParamData(key, value));
        }


        public void SetParam(string key, Vector3 value)
        {
            ParamData pd = Find(key, false);
            if (pd != null)
            {
                pd.SetValue(value);
                return;
            }
            data_.Add(new ParamData(key, value));
        }

        public void SetParam(string key, ParamDataInterface value)
        {
            ParamData pd = Find(key, false);
            if (pd != null)
            {
                pd.SetValue(value);
                return;
            }
            data_.Add(new ParamData(key, value));
        }

        public LValue gen_ltable(bool is_one_line, LTable table)
        {
            if (string.IsNullOrEmpty(type_)) return null;

            ParamItem[] arr_param = AIConst.kType2Param[type_];
            if (type_ == "Comparison")
            {
                Comparator comparator = Find("comparator").v_custom as Comparator;
                if (comparator == null) comparator = new Comparator();
                comparator.GenLTable(table);
            }
            else if (type_ == "Script")
            {
                table["script"] = new LString(Find("script").v_string.Replace("\n", @"\n").Replace("\r", @"\r"));
            }
            else
            {
                foreach (ParamItem pi in arr_param)
                {
                    ParamData pd = Find(pi.name);
                    if (pd != null)
                    {
                        table[pi.name] = pd.gen_ltable(true);
                    }
                }
            }
            return table;
        }
    }
}
