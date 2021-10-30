using System;
using SLua;
using System.Collections.Generic;
[UnityEngine.Scripting.Preserve]
public class Lua_UITreeNodeData : LuaObject {
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int constructor(IntPtr l) {
		try {
			UITreeNodeData o;
			System.Int32 a1;
			checkType(l,2,out a1);
			System.Int32 a2;
			checkType(l,3,out a2);
			o=new UITreeNodeData(a1,a2);
			pushValue(l,true);
			pushValue(l,o);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int SetIndex(IntPtr l) {
		try {
			UITreeNodeData self=(UITreeNodeData)checkSelf(l);
			System.Int32 a1;
			checkType(l,2,out a1);
			self.SetIndex(a1);
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int AddChild(IntPtr l) {
		try {
			UITreeNodeData self=(UITreeNodeData)checkSelf(l);
			UITreeNodeData a1;
			checkType(l,2,out a1);
			self.AddChild(a1);
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int RemoveChild(IntPtr l) {
		try {
			UITreeNodeData self=(UITreeNodeData)checkSelf(l);
			UITreeNodeData a1;
			checkType(l,2,out a1);
			self.RemoveChild(a1);
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int GetChildCount(IntPtr l) {
		try {
			UITreeNodeData self=(UITreeNodeData)checkSelf(l);
			var ret=self.GetChildCount();
			pushValue(l,true);
			pushValue(l,ret);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int SetExpand(IntPtr l) {
		try {
			UITreeNodeData self=(UITreeNodeData)checkSelf(l);
			System.Boolean a1;
			checkType(l,2,out a1);
			self.SetExpand(a1);
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int GetRootNode(IntPtr l) {
		try {
			UITreeNodeData self=(UITreeNodeData)checkSelf(l);
			var ret=self.GetRootNode();
			pushValue(l,true);
			pushValue(l,ret);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_id(IntPtr l) {
		try {
			UITreeNodeData self=(UITreeNodeData)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.id);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_id(IntPtr l) {
		try {
			UITreeNodeData self=(UITreeNodeData)checkSelf(l);
			System.Int32 v;
			checkType(l,2,out v);
			self.id=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_level(IntPtr l) {
		try {
			UITreeNodeData self=(UITreeNodeData)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.level);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_level(IntPtr l) {
		try {
			UITreeNodeData self=(UITreeNodeData)checkSelf(l);
			System.Int32 v;
			checkType(l,2,out v);
			self.level=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_index(IntPtr l) {
		try {
			UITreeNodeData self=(UITreeNodeData)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.index);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_index(IntPtr l) {
		try {
			UITreeNodeData self=(UITreeNodeData)checkSelf(l);
			System.Int32 v;
			checkType(l,2,out v);
			self.index=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_parent(IntPtr l) {
		try {
			UITreeNodeData self=(UITreeNodeData)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.parent);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_parent(IntPtr l) {
		try {
			UITreeNodeData self=(UITreeNodeData)checkSelf(l);
			UITreeNodeData v;
			checkType(l,2,out v);
			self.parent=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_child(IntPtr l) {
		try {
			UITreeNodeData self=(UITreeNodeData)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.child);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_child(IntPtr l) {
		try {
			UITreeNodeData self=(UITreeNodeData)checkSelf(l);
			System.Collections.Generic.List<UITreeNodeData> v;
			checkType(l,2,out v);
			self.child=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_is_expand(IntPtr l) {
		try {
			UITreeNodeData self=(UITreeNodeData)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.is_expand);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_is_expand(IntPtr l) {
		try {
			UITreeNodeData self=(UITreeNodeData)checkSelf(l);
			System.Boolean v;
			checkType(l,2,out v);
			self.is_expand=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_pos(IntPtr l) {
		try {
			UITreeNodeData self=(UITreeNodeData)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.pos);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_pos(IntPtr l) {
		try {
			UITreeNodeData self=(UITreeNodeData)checkSelf(l);
			System.Single v;
			checkType(l,2,out v);
			self.pos=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_height(IntPtr l) {
		try {
			UITreeNodeData self=(UITreeNodeData)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.height);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_height(IntPtr l) {
		try {
			UITreeNodeData self=(UITreeNodeData)checkSelf(l);
			System.Single v;
			checkType(l,2,out v);
			self.height=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_is_select(IntPtr l) {
		try {
			UITreeNodeData self=(UITreeNodeData)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.is_select);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_is_select(IntPtr l) {
		try {
			UITreeNodeData self=(UITreeNodeData)checkSelf(l);
			System.Boolean v;
			checkType(l,2,out v);
			self.is_select=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[UnityEngine.Scripting.Preserve]
	static public void reg(IntPtr l) {
		getTypeTable(l,"UITreeNodeData");
		addMember(l,SetIndex);
		addMember(l,AddChild);
		addMember(l,RemoveChild);
		addMember(l,GetChildCount);
		addMember(l,SetExpand);
		addMember(l,GetRootNode);
		addMember(l,"id",get_id,set_id,true);
		addMember(l,"level",get_level,set_level,true);
		addMember(l,"index",get_index,set_index,true);
		addMember(l,"parent",get_parent,set_parent,true);
		addMember(l,"child",get_child,set_child,true);
		addMember(l,"is_expand",get_is_expand,set_is_expand,true);
		addMember(l,"pos",get_pos,set_pos,true);
		addMember(l,"height",get_height,set_height,true);
		addMember(l,"is_select",get_is_select,set_is_select,true);
		createTypeMetatable(l,constructor, typeof(UITreeNodeData));
	}
}
