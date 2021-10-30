using System;
using SLua;
using System.Collections.Generic;
[UnityEngine.Scripting.Preserve]
public class Lua_UIActivityEffect : LuaObject {
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int InitActivtyEffect(IntPtr l) {
		try {
			UIActivityEffect self=(UIActivityEffect)checkSelf(l);
			System.String a1;
			checkType(l,2,out a1);
			System.Boolean a2;
			checkType(l,3,out a2);
			self.InitActivtyEffect(a1,a2);
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_OnActivityEffectFinish(IntPtr l) {
		try {
			UIActivityEffect self=(UIActivityEffect)checkSelf(l);
			UIActivityEffect.ActivityEffectFinishDelegate v;
			int op=LuaDelegation.checkDelegate(l,2,out v);
			if(op==0) self.OnActivityEffectFinish=v;
			else if(op==1) self.OnActivityEffectFinish+=v;
			else if(op==2) self.OnActivityEffectFinish-=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[UnityEngine.Scripting.Preserve]
	static public void reg(IntPtr l) {
		getTypeTable(l,"UIActivityEffect");
		addMember(l,InitActivtyEffect);
		addMember(l,"OnActivityEffectFinish",null,set_OnActivityEffectFinish,true);
		createTypeMetatable(l,null, typeof(UIActivityEffect),typeof(UnityEngine.MonoBehaviour));
	}
}
