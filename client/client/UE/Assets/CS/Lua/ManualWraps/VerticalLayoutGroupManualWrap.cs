using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using UnityEngine.UI;
using SLua;
[ExtendLuaClass(typeof(VerticalLayoutGroup))]
public class VerticalLayoutGroupManualWrap : LuaObject
{
    [UnityEngine.Scripting.Preserve]
    public static void reg(IntPtr l)
    {
        addMember(l, "padding", get_padding, set_padding, true);
        addMember(l, "spacing", get_spacing, set_spacing, true);
    }
    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int get_padding(IntPtr l)
    {
        try
        {
            UnityEngine.UI.VerticalLayoutGroup self = (UnityEngine.UI.VerticalLayoutGroup)checkSelf(l);
            pushValue(l, true);
            pushValue(l, self.padding);
            return 2;
        }
        catch (Exception e)
        {
            return error(l, e);
        }
    }
    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int set_padding(IntPtr l)
    {
        try
        {
            UnityEngine.UI.VerticalLayoutGroup self = (UnityEngine.UI.VerticalLayoutGroup)checkSelf(l);
            UnityEngine.RectOffset v;
            checkType(l, 2, out v);
            self.padding = v;
            pushValue(l, true);
            return 1;
        }
        catch (Exception e)
        {
            return error(l, e);
        }
    }
    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int get_spacing(IntPtr l)
    {
        try
        {
            UnityEngine.UI.VerticalLayoutGroup self = (UnityEngine.UI.VerticalLayoutGroup)checkSelf(l);
            pushValue(l, true);
            pushValue(l, self.spacing);
            return 2;
        }
        catch (Exception e)
        {
            return error(l, e);
        }
    }
    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int set_spacing(IntPtr l)
    {
        try
        {
            UnityEngine.UI.VerticalLayoutGroup self = (UnityEngine.UI.VerticalLayoutGroup)checkSelf(l);
            float v;
            checkType(l, 2, out v);
            self.spacing = v;
            pushValue(l, true);
            return 1;
        }
        catch (Exception e)
        {
            return error(l, e);
        }
    }
}
