using System;
using SLua;
using System.Collections.Generic;
using System.IO;
using System.Text;

[ManualLuaClassAttribute("BindCustom")]
public class MockSslManualWrap : LuaObject
{
    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int constructor(IntPtr l)
    {
        try
        {
            MockSsl o;
            o = new MockSsl();
            pushValue(l, true);
            pushValue(l, o);
            return 2;
        }
        catch (Exception e)
        {
            return error(l, e);
        }
    }

    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int Init(IntPtr l)
    {
        try
        {
            MockSsl ms;
            checkType(l, 1, out ms);

            string targetName;
            checkType(l, 2, out targetName);

            ms.Init(targetName);
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
    static public int Update(IntPtr l)
    {
        try
        {
            MockSsl ms;
            checkType(l, 1, out ms);
            ms.Update();
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
    static public int Destroy(IntPtr l)
    {
        try
        {
            MockSsl ms;
            checkType(l, 1, out ms);
            ms.Destroy();
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
    static public int MockServerSend(IntPtr l)
    {
        try
        {
            MockSsl ms;
            checkType(l, 1, out ms);

            byte[] data;
            checkBinaryString(l, 2, out data);

            if(data != null)
            {
                ms.MockServerSend(data, 0, data.Length);
            }
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
    static public int MockServerRecv(IntPtr l)
    {
        try
        {
            MockSsl ms;
            checkType(l, 1, out ms);

            byte[] data = ms.MockServerRecv();
            pushValue(l, true);
            if(data==null)
            {
                pushVar(l, null);
            }
            else
            {
                pushValue(l, data);
            }
            
            return 2;
        }
        catch (Exception e)
        {
            return error(l, e);
        }
    }

    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int Recv(IntPtr l)
    {
        try
        {
            MockSsl ms;
            checkType(l, 1, out ms);

            byte[] data = ms.Recv();
            pushValue(l, true);
            if (data == null)
            {
                pushVar(l, null);
            }
            else
            {
                pushValue(l, data);
            }
            return 2;
        }
        catch (Exception e)
        {
            return error(l, e);
        }
    }

    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int Send(IntPtr l)
    {
        try
        {
            MockSsl ms;
            checkType(l, 1, out ms);

            byte[] data;
            checkBinaryString(l, 2, out data);

            ms.Send(data, 0, data.Length);
            pushValue(l, true);
            return 1;
        }
        catch (Exception e)
        {
            return error(l, e);
        }
    }

    [UnityEngine.Scripting.Preserve]
    static public void reg(IntPtr l)
    {
        getTypeTable(l, "MockSsl");
        addMember(l, Update);
        addMember(l, Init);
        addMember(l, MockServerRecv);
        addMember(l, MockServerSend);
        addMember(l, Recv);
        addMember(l, Send);
        addMember(l, Destroy);
        createTypeMetatable(l, constructor, typeof(MockSsl));
    }
}
