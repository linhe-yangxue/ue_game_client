using System;
using SLua;
using System.Collections.Generic;
[UnityEngine.Scripting.Preserve]
public class Lua_UITreeView : LuaObject {
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int Init(IntPtr l) {
		try {
			UITreeView self=(UITreeView)checkSelf(l);
			UITreeNodeData[] a1;
			checkArray(l,2,out a1);
			self.Init(a1);
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int GetCurNodeData(IntPtr l) {
		try {
			UITreeView self=(UITreeView)checkSelf(l);
			var ret=self.GetCurNodeData();
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
	static public int SelectNodeById(IntPtr l) {
		try {
			UITreeView self=(UITreeView)checkSelf(l);
			System.Int32 a1;
			checkType(l,2,out a1);
			self.SelectNodeById(a1);
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int SelectNode(IntPtr l) {
		try {
			UITreeView self=(UITreeView)checkSelf(l);
			UITreeNodeData a1;
			checkType(l,2,out a1);
			self.SelectNode(a1);
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int UpdatePos(IntPtr l) {
		try {
			UITreeView self=(UITreeView)checkSelf(l);
			UnityEngine.Vector2 a1;
			checkType(l,2,out a1);
			self.UpdatePos(a1);
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int UpdateTreeView(IntPtr l) {
		try {
			UITreeView self=(UITreeView)checkSelf(l);
			self.UpdateTreeView();
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int UpdateTreeNode(IntPtr l) {
		try {
			UITreeView self=(UITreeView)checkSelf(l);
			self.UpdateTreeNode();
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_OnViewChange(IntPtr l) {
		try {
			UITreeView self=(UITreeView)checkSelf(l);
			UITreeView.ViewChangeDelegate v;
			int op=LuaDelegation.checkDelegate(l,2,out v);
			if(op==0) self.OnViewChange=v;
			else if(op==1) self.OnViewChange+=v;
			else if(op==2) self.OnViewChange-=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_OnSelectNode(IntPtr l) {
		try {
			UITreeView self=(UITreeView)checkSelf(l);
			UITreeView.SelectNodeDelegate v;
			int op=LuaDelegation.checkDelegate(l,2,out v);
			if(op==0) self.OnSelectNode=v;
			else if(op==1) self.OnSelectNode+=v;
			else if(op==2) self.OnSelectNode-=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_cell_padding_(IntPtr l) {
		try {
			UITreeView self=(UITreeView)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.cell_padding_);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_cell_padding_(IntPtr l) {
		try {
			UITreeView self=(UITreeView)checkSelf(l);
			System.Int32 v;
			checkType(l,2,out v);
			self.cell_padding_=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_is_one_open_(IntPtr l) {
		try {
			UITreeView self=(UITreeView)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.is_one_open_);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_is_one_open_(IntPtr l) {
		try {
			UITreeView self=(UITreeView)checkSelf(l);
			System.Boolean v;
			checkType(l,2,out v);
			self.is_one_open_=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_is_auto_select_child_(IntPtr l) {
		try {
			UITreeView self=(UITreeView)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.is_auto_select_child_);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_is_auto_select_child_(IntPtr l) {
		try {
			UITreeView self=(UITreeView)checkSelf(l);
			System.Boolean v;
			checkType(l,2,out v);
			self.is_auto_select_child_=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_level_tree_node_(IntPtr l) {
		try {
			UITreeView self=(UITreeView)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.level_tree_node_);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_level_tree_node_(IntPtr l) {
		try {
			UITreeView self=(UITreeView)checkSelf(l);
			UnityEngine.GameObject[] v;
			checkArray(l,2,out v);
			self.level_tree_node_=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[UnityEngine.Scripting.Preserve]
	static public void reg(IntPtr l) {
		getTypeTable(l,"UITreeView");
		addMember(l,Init);
		addMember(l,GetCurNodeData);
		addMember(l,SelectNodeById);
		addMember(l,SelectNode);
		addMember(l,UpdatePos);
		addMember(l,UpdateTreeView);
		addMember(l,UpdateTreeNode);
		addMember(l,"OnViewChange",null,set_OnViewChange,true);
		addMember(l,"OnSelectNode",null,set_OnSelectNode,true);
		addMember(l,"cell_padding_",get_cell_padding_,set_cell_padding_,true);
		addMember(l,"is_one_open_",get_is_one_open_,set_is_one_open_,true);
		addMember(l,"is_auto_select_child_",get_is_auto_select_child_,set_is_auto_select_child_,true);
		addMember(l,"level_tree_node_",get_level_tree_node_,set_level_tree_node_,true);
		createTypeMetatable(l,null, typeof(UITreeView),typeof(UnityEngine.EventSystems.UIBehaviour));
	}
}
