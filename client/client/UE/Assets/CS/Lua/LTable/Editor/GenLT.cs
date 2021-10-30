using System;
using System.Collections.Generic;
using System.Reflection;

namespace LT
{
    public class LTItem
    {
        public int index = -1;
        public string name = null;
        public bool is_one_line = false;
        public Type t = null;
        public Type rt = null;
    }

    public static class GenLTable
    {
        static Dictionary<Type, List<LTItem>> data = new Dictionary<Type, List<LTItem>>();

        public static bool init()
        {
            data.Clear();
            Assembly asm = Assembly.GetExecutingAssembly();
            foreach (Type t in asm.GetTypes())
            {
                LTableAttribute la = null;
                foreach (object o in t.GetCustomAttributes(false))
                {
                    la = o as LTableAttribute;
                    if (la != null)
                    {
                        break;
                    }
                }
                if (la == null) continue;
                if (!la.gen_by_self)
                {
                    var lts = gen_item(t);
                    data.Add(t, lts);
                }
            }
            return true;
        }

        public static LValue gen(object o, Type t, bool one_line = false)
        {
            if (o == null) return null;
            if (o as LValue != null) return o as LValue;
            if (!t.IsClass || t == typeof(string)) return gen_value(o, t, one_line);
            try
            {
                if (t.IsArray) return gen_array(o, t, one_line);
                //Type[] generic_types = t.GetGenericArguments();
                if (t.GetInterface("IDictionary") != null) return gen_dictionary(o, t, one_line);
                if (t.GetInterface("IList") != null) return gen_list(o, t, one_line);
                List<LTItem> lts = null;
                data.TryGetValue(t, out lts);
                if (lts == null)
                {
                    MethodInfo mt = t.GetMethod("gen_ltable", BindingFlags.Instance | BindingFlags.Public);
                    if (mt == null) return null;
                    var v = mt.Invoke(o, new object[] { one_line });
                    return v as LTable;
                }
                LTable table = new LTable(one_line);
                foreach (LTItem lt in lts)
                {
                    LValue k = null;
                    LValue v = null;
                    FieldInfo p = lt.rt.GetField(lt.name, BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Instance);
                    object ov = p.GetValue(o);
                    v = gen(ov, lt.t, lt.is_one_line);
                    // key
                    if (lt.index > 0)
                    {
                        k = new LNum(lt.index);
                    }
                    else
                    {
                        k = new LString(lt.name);
                    }
                    table[k] = v;
                }
                return table;
            }
            catch (Exception e)
            {
                UnityEngine.Debug.LogError(e);
                return null;
            }
        }
        private static LTable gen_dictionary(object o, Type t, bool one_line = false)
        {
            Type[] generic_types = t.GetGenericArguments();
            Type key_type = generic_types[0]; Type value_type = generic_types[1];
            PropertyInfo pk = t.GetProperty("Keys");
            object ekeys = pk.GetValue(o, null);
            List<object> keys = new List<object>();
            List<LValue> lkeys = enumerable2_lvalue_list(ekeys, key_type, one_line, keys);
            LTable lt = new LTable(one_line);
            PropertyInfo pi = t.GetProperty("Item");
            for (int i = 0; i < lkeys.Count; ++i)
            {
                object value = pi.GetValue(o, new object[] { keys[i] });
                lt[lkeys[i]] = gen(value, value_type, one_line);
            }
            return lt;
        }
        private static LTable gen_list(object o, Type t, bool one_line = false)
        {
            Type et = t.GetGenericArguments()[0];
            LTable lt = new LTable(one_line);
            PropertyInfo pi = t.GetProperty("Item");
            PropertyInfo pc = t.GetProperty("Count");
            int count = (int)pc.GetValue(o, null);
            for (int i = 0; i < count; ++i)
            {
                object v = pi.GetValue(o, new object[] { i });
                lt[i + 1] = gen(v, et, one_line);
            }
            return lt;
        }
        private static LTable gen_array(object o, Type t, bool one_line = false)
        {
            Type[] generic_types = t.GetGenericArguments();
            LTable lt = new LTable(one_line);
            MethodInfo mi = t.GetMethod("GetValue");
            PropertyInfo pc = t.GetProperty("Length");
            int count = (int)pc.GetValue(o, null);
            for (int i = 0; i < count; ++i)
            {
                object v = mi.Invoke(o, new object[] { i });
                lt[i + 1] = gen(v, generic_types[0], one_line);
            }
            return lt;
        }
        private static List<LValue> enumerable2_lvalue_list(object enumerable, Type t, bool one_line, List<object> values)
        {
            List<LValue> ret = new List<LValue>();
            if (t == typeof(int))
            {
                foreach (var o in enumerable as IEnumerable<int>)
                {
                    ret.Add(gen(o, t, one_line));
                    values.Add(o);
                }
            }
            else if (t == typeof(Int64))
            {
                foreach (var o in enumerable as IEnumerable<Int64>)
                {
                    ret.Add(gen(o, t, one_line));
                    values.Add(o);
                }
            }
            else if (t == typeof(string))
            {
                foreach (var o in enumerable as IEnumerable<string>)
                {
                    ret.Add(gen(o, t, one_line));
                    values.Add(o);
                }
            }

            return ret;
        }
        private static LValue gen_value(object o, Type t, bool is_one_line = false)
        {
            if (o == null) return null;
            LValue v = null;
            if (o == null) return null;
            if (t == typeof(string))
            {
                v = new LString(o as string);
            }
            else if (t == typeof(int))
            {
                v = new LNum((int)o);
            }
            else if (t == typeof(Int64))
            {
                v = new LNum((Int64)o);
            }
            else if (t == typeof(float))
            {
                v = new LNum((float)o);
            }
            else if (t == typeof(double))
            {
                v = new LNum((float)o);
            }

            return v;
        }
        private static List<LTItem> gen_item(Type t)
        {
            List<LTItem> ret = new List<LTItem>();
            FieldInfo[] fis = t.GetFields(BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Instance);
            foreach (FieldInfo fi in fis)
            {
                LTableMemberAttribute lm = null;
                foreach (object o in fi.GetCustomAttributes(true))
                {
                    lm = o as LTableMemberAttribute;
                    if (lm != null) break;
                }
                if (lm == null) continue;
                LTItem lt = new LTItem();
                lt.index = lm.index;
                lt.name = lm.name == null ? fi.Name : lm.name;
                lt.is_one_line = lm.one_line;
                lt.rt = fi.ReflectedType;
                lt.t = fi.FieldType;

                ret.Add(lt);
            }
            return ret;
        }
    }
}
