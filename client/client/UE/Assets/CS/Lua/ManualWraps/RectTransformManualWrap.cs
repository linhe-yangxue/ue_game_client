using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using UnityEngine.UI;
using SLua;
[ExtendLuaClass(typeof(RectTransform))]
public class RectTransformManualWrap : LuaObject
{
    [UnityEngine.Scripting.Preserve]
    public static void reg(IntPtr l)
    {
        addMember(l, GetPreferredSize);
    }
    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int GetPreferredSize(IntPtr l)
    {
        try
        {
            RectTransform self = (RectTransform)checkSelf(l);
            LayoutRebuilder.ForceRebuildLayoutImmediate(self);
            Vector2 size = new Vector2(LayoutUtility.GetPreferredSize(self, 0), LayoutUtility.GetPreferredSize(self, 1));
            pushValue(l, true);
            pushValue(l, size);
            return 2;
        }
        catch (Exception e)
        {
            return error(l, e);
        }
    }
}
