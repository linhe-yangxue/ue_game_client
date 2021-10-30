using System;
using UnityEngine;
using System.Reflection;

using LT;
using System.Collections.Generic;
using UnityEditor;
namespace PI {
    public interface ParamInterface {
        string GetStringParam(string key);
        float GetFloatParam(string key);
        int GetIntParam(string key);
        bool GetBoolParam(string key);
        ParamDataInterface GetObjectParam(string key);
        void SetParam(string key, string value);
        void SetParam(string key, int value);
        void SetParam(string key, float value);
        void SetParam(string key, bool value);
        void SetParam(string key, ParamDataInterface value);
        ParamData Find(string key, bool get_default);
    }
    public class ParamItem {
        public ParamItem(string name, string type, string tips = "", object default_value = null) {
            this.name = name;
            this.type = type;
            this.tips = tips;
            this.default_value = default_value;
        }
        public string name;
        public string type;
        public string tips;
        public object default_value;
    }

    public interface ParamDataInterface {
        ParamDataInterface Copy();
        LValue gen_ltable(bool one_line);
        void Draw();
        string DoSerialize();
        void DoDeserialize(string content);
    }

    [System.Serializable]
    [LTable(gen_by_self = true)]
    public class ParamData : ISerializationCallbackReceiver
    {
        public string type;
        public string tips;
        public string key;
        public string v_string;
        public int v_int;
        public Int64 v_int64;
        public float v_float;
        public bool v_bool;
        public Vector2 v_vector2;
        public Vector3 v_vector3;
        public Color v_color;
        public AnimationCurve v_curve;
        public EnumData v_enum;
        public string real_custom_type_name;
        public string custom_serialize_str;
        public ParamDataInterface v_custom;

        public bool is_varible;
        public string variable_name;

        public void OnBeforeSerialize()
        {
            custom_serialize_str = null;
            if (type == typeof(ParamDataInterface).Name && v_custom != null)
            {
                custom_serialize_str = v_custom.DoSerialize();
            }
        }

        public void OnAfterDeserialize()
        {
            if (type == typeof(ParamDataInterface).Name)
            {
                v_custom = Activator.CreateInstance(FindType(real_custom_type_name)) as ParamDataInterface;
                if (v_custom != null)
                {
                    v_custom.DoDeserialize(custom_serialize_str);
                }
            }
        }

        public static Type FindType(string qualifiedTypeName)
        {
            Type t = Type.GetType(qualifiedTypeName);
            if (t != null)
            {
                return t;
            }
            else
            {
                Assembly[] Assemblies = AppDomain.CurrentDomain.GetAssemblies();
                for (int n = 0; n < Assemblies.Length; n++)
                {
                    Assembly asm = Assemblies[n];
                    t = asm.GetType(qualifiedTypeName);
                    if (t != null)
                        return t;
                }
                return null;
            }
        }

        public ParamData(string key, string v)
        {
            this.type = typeof(string).Name;
            this.key = key;
            this.v_string = v;
        }
        public ParamData(string key, int v)
        {
            this.type = typeof(int).Name;
            this.key = key;
            this.v_int = v;
        }
        public ParamData(string key, Int64 v)
        {
            this.type = typeof(Int64).Name;
            this.key = key;
            this.v_int64 = v;
        }
        public ParamData(string key, float v)
        {
            this.type = typeof(float).Name;
            this.key = key;
            this.v_float = v;
        }
        public ParamData(string key, bool v)
        {
            this.type = typeof(bool).Name;
            this.key = key;
            this.v_bool = v;
        }
        public ParamData(string key, Vector2 v)
        {
            this.type = typeof(Vector2).Name;
            this.key = key;
            this.v_vector2 = v;
        }
        public ParamData(string key, Vector3 v)
        {
            this.type = typeof(Vector3).Name;
            this.key = key;
            this.v_vector3 = v;
        }
        public ParamData(string key, Color v)
        {
            this.type = typeof(Color).Name;
            this.key = key;
            this.v_color = v;
        }

        public ParamData(string key, AnimationCurve v)
        {
            this.type = typeof(AnimationCurve).Name;
            this.key = key;
            this.v_curve = new AnimationCurve();
            AnimationTools.CopyAnimationCurve(v, this.v_curve);
        }

        public ParamData(string key, ParamDataInterface v)
        {
            this.key = key;
            this.type = typeof(ParamDataInterface).Name;
            this.real_custom_type_name = v.GetType().FullName;
            this.v_custom = v;
        }
        public ParamData(string key, object v)
        {
            this.key = key;
            SetValue(v);
        }
        public ParamData(ParamItem item)
        {
            this.key = item.name;
            this.tips = item.tips;
            SetValue(item.type, item.default_value);
        }
        public ParamData(ParamItem item, object v)
        {
            this.key = item.name;
            this.tips = item.tips;
            SetValue(item.type, v);
        }

        public ParamData Copy()
        {
            var ret = new ParamData(key, v_string);
            ret.type = type;
            ret.tips = tips;
            ret.key = key;
            ret.v_string = v_string;
            ret.v_int = v_int;
            ret.v_int64 = v_int64;
            ret.v_float = v_float;
            ret.v_bool = v_bool;
            ret.v_vector2 = v_vector2;
            ret.v_vector3 = v_vector3;
            ret.v_color = v_color;
            ret.v_curve = new AnimationCurve();
            if(v_curve != null)
            {
                AnimationTools.CopyAnimationCurve(v_curve, ret.v_curve);
            }
            ret.v_enum = new EnumData(v_enum.type_name_, v_enum.show_name_type_);
            if (v_custom != null)
            {
                ret.real_custom_type_name = real_custom_type_name;
                ret.v_custom = v_custom.Copy();
            }

            ret.is_varible = is_varible;
            ret.variable_name = variable_name;

            return ret;
        }

        public void SetValue(string v)
        {
            this.type = typeof(string).Name;
            this.v_string = v;
        }
        public void SetValue(int v)
        {
            this.type = typeof(int).Name;
            this.v_int = v;
        }
        public void SetValue(Int64 v)
        {
            this.type = typeof(Int64).Name;
            this.v_int64 = v;
        }
        public void SetValue(float v)
        {
            this.type = typeof(float).Name;
            this.v_float = v;
        }
        public void SetValue(bool v)
        {
            this.type = typeof(bool).Name;
            this.v_bool = v;
        }
        public void SetValue(Vector2 v)
        {
            this.type = typeof(Vector2).Name;
            this.v_vector2 = v;
        }
        public void SetValue(Vector3 v)
        {
            this.type = typeof(Vector3).Name;
            this.v_vector3 = v;
        }
        public void SetValue(Color v)
        {
            this.type = typeof(Color).Name;
            this.v_color = v;
        }
        public void SetValue(AnimationCurve v)
        {
            this.type = typeof(AnimationCurve).Name;
            this.v_curve = new AnimationCurve();
            AnimationTools.CopyAnimationCurve(v, this.v_curve);
        }

        public void SetValue(EnumData v)
        {
            this.type = typeof(EnumData).Name;
            this.v_enum = new EnumData(v.type_name_, v.show_name_type_);
        }

        public void SetValue(ParamDataInterface v)
        {
            this.type = typeof(ParamDataInterface).Name;
            this.v_custom = v;
            if (v != null) this.real_custom_type_name = v.GetType().FullName;
        }
        public void SetValue(object v)
        {
            if (v != null) SetValue(v.GetType().Name, v);
        }
        public void SetValue(string type_name, object v)
        {
            switch (type_name)
            {
                case "string":
                case "String":
                    this.SetValue((string)v);
                    break;
                case "int":
                case "Int32":
                    this.SetValue(Convert.ToInt32(v));
                    break;
                case "Int64":
                    this.SetValue(Convert.ToInt64(v));
                    break;
                case "float":
                case "Single":
                    this.SetValue(Convert.ToSingle(v));
                    break;
                case "bool":
                    this.SetValue((bool)v);
                    break;
                case "Vector2":
                    this.SetValue((Vector2)v);
                    break;
                case "Vector3":
                    this.SetValue((Vector3)v);
                    break;
                case "Color":
                    this.SetValue((Color)v);
                    break;
                case "AnimationCurve":
                    this.SetValue((AnimationCurve)v);
                    break;
                case "EnumData":
                    this.SetValue((EnumData)v);
                    break;
                default:
                    this.real_custom_type_name = type_name;
                    this.SetValue(v as ParamDataInterface);
                    break;
            }
        }

        public LValue gen_ltable(bool one_line)
        {
            if (is_varible)
            {
                return new LString(variable_name);
            }
            if (type == typeof(string).Name)
            {
                return new LString(v_string);
            }
            if (type == typeof(int).Name)
            {
                return new LNum(v_int);
            }
            if (type == typeof(Int64).Name)
            {
                return new LNum(v_int64);
            }
            if (type == typeof(float).Name)
            {
                return new LNum(v_float);
            }
            if (type == typeof(bool).Name)
            {
                return new LBool(v_bool);
            }
            if (type == typeof(Vector2).Name)
            {
                return new LVector3(v_vector2);
            }
            if (type == typeof(Vector3).Name)
            {
                return new LVector3(v_vector3);
            }
            if (type == typeof(Color).Name)
            {
                return new LColor(v_color);
            }
            if (type == typeof(AnimationCurve).Name)
            {
                return AnimationTools.ExportCurveToLua(v_curve);
            }
            if (type == typeof(EnumData).Name)
            {
                return v_enum.Export();
            }
            if (type == typeof(ParamDataInterface).Name)
            {
                return v_custom.gen_ltable(one_line);
            }
            return null;
        }

        public void Draw()
        {
            string label = key;
            if (tips != null) label = tips;
            if (type == typeof(string).Name)
            {
                v_string = EditorGUILayout.TextField(label, v_string);
            }
            else if (type == typeof(int).Name)
            {
                v_int = EditorGUILayout.IntField(label, v_int);
            }
            else if (type == typeof(Int64).Name)
            {
                v_int64 = Convert.ToInt64(EditorGUILayout.TextField(label, v_int64.ToString()));
            }
            else if (type == typeof(float).Name)
            {
                v_float = EditorGUILayout.FloatField(label, v_float);
            }
            else if (type == typeof(bool).Name)
            {
                v_bool = EditorGUILayout.Toggle(label, v_bool);
            }
            else if (type == typeof(Vector2).Name)
            {
                v_vector2 = EditorGUILayout.Vector2Field(label, v_vector2);
            }
            else if (type == typeof(Vector3).Name)
            {
                v_vector3 = EditorGUILayout.Vector3Field(label, v_vector3);
            }
            else if (type == typeof(Color).Name)
            {
                v_color = EditorGUILayout.ColorField(new GUIContent(label), v_color, true, true, true);
            }
            else if (type == typeof(AnimationCurve).Name)
            {
                v_curve = EditorGUILayout.CurveField(label, v_curve);
            }
            else if (type == typeof(EnumData).Name)
            {
                if(v_enum.type_name_!="")
                {
                    v_enum.InitList();
                    v_enum.select_ = EditorGUILayout.Popup(label, v_enum.select_, v_enum.show_name_list_);
                }
            }
            else
            {
                if (v_custom != null)
                {
                    v_custom.Draw();
                }
            }
        }
    }

    [System.Serializable]
    [LTable(gen_by_self = true)]
    public class ParamTable {
        public List<ParamData> list = new List<ParamData>();

        public ParamData Add(string key, object value) {
            return Add(new ParamData(key, value));
        }

        public ParamData Add(ParamData data) {
            list.Add(data);
            return data;
        }

        public ParamData Remove(ParamData data) {
            list.Remove(data);
            return data;
        }

        public ParamData Remove(string key) {
            var data = Get(key);
            if (data != null) Remove(data);
            return data;
        }

        public ParamData Get(string key) {
            return list.Find(x => x.key == key);
        }

        public ParamData Set(string key, object value) {
            ParamData data = Get(key);
            if (data != null) {
                data.SetValue(value);
            } else {
                data = Add(key, value);
            }
            return data;
        }

        public int Count() {
            return list.Count;
        }

        public ParamData this[string key]
        {
            get { return Get(key); }
            set { Set(key, value); }
        }

        public void Clear() {
            list.Clear();
        }

        public LValue gen_ltable(bool one_line) {
            LTable t = new LTable(one_line);
            foreach (var data in list) {
                t[data.key] = data.gen_ltable(true);
            }
            return t;
        }

        public void Draw() {
            foreach (var data in list) {
                data.Draw();
            }
        }
    }

    [System.Serializable]
    [LTable(gen_by_self = true)]
    public abstract class ParamSchema {
        public List<ParamData> list = new List<ParamData>();

        public abstract ParamItem[] GetSchema();

        public virtual void Init() {
            list.Clear();
            foreach (var item in GetSchema()) {
                list.Add(new ParamData(item));
            }
        }

        public ParamData Get(string key) {
            var data = list.Find(x => x.key == key);
            if (data == null) {
                var items = GetSchema();
                foreach (var item in items) {
                    if (item.name == key) {
                        data = new ParamData(item);
                        list.Add(data);
                    }
                }
            }
            return data;
        }

        public void Set(string key, object value) {
            ParamData data = Get(key);
            if (data != null) {
                data.SetValue(value);
            }
        }

        public ParamData this[string key]
        {
            get { return Get(key); }
            set { Set(key, value); }
        }

        public void Clear() {
            list.Clear();
        }

        public virtual void CopyFrom(ParamSchema scr) {
            list = new List<ParamData>(scr.list.Count);
            foreach (var data in scr.list) {
                list.Add(data.Copy());
            }
        }


        public virtual LValue gen_ltable(bool one_line) {
            LTable t = new LTable(one_line);
            foreach (var define in GetSchema()) {
                t[define.name] = Get(define.name).gen_ltable(true);
            }
            return t;
        }

        public virtual void Draw() {
            foreach (var item in GetSchema()) {
                Get(item.name).Draw();
            }
        }
    }

    [System.Serializable]
    [LTable(gen_by_self = true)]
    public class EnumData  // 枚举
    {
        public int select_;
        public string[] select_list_;
        public string[] show_name_list_;

        public string type_name_;
        public string show_name_type_;

        public EnumData(string type_name, string show_name_type)
        {
            type_name_ = type_name;
            show_name_type_ = show_name_type;
        }

        public void InitList()
        {
            if(Type.GetType(type_name_) == null)
            {
                return;
            }
            Array array = Enum.GetValues(Type.GetType(type_name_));
            select_list_ = new string[array.Length];
            for (int i = 0; i < array.Length; i++)
            {
                select_list_[i] = array.GetValue(i).ToString();
            }

            array = Enum.GetValues(Type.GetType(show_name_type_));
            show_name_list_ = new string[array.Length];
            for (int i = 0; i < array.Length; i++)
            {
                show_name_list_[i] = array.GetValue(i).ToString();
            }
        }

        public LString Export()
        {
            InitList();
            return new LString(select_list_[select_]);
        }
    }
}