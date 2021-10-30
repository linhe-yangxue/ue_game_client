using System;
using SLua;
using System.Collections.Generic;
[UnityEngine.Scripting.Preserve]
public class Lua_GameEventMgr : LuaObject {
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int RegisterUIEvent(IntPtr l) {
		try {
			GameEventMgr self=(GameEventMgr)checkSelf(l);
			UnityEngine.GameObject a1;
			checkType(l,2,out a1);
			System.Int32 a2;
			checkType(l,3,out a2);
			self.RegisterUIEvent(a1,a2);
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int UnRegisterUIEvent(IntPtr l) {
		try {
			GameEventMgr self=(GameEventMgr)checkSelf(l);
			UnityEngine.GameObject a1;
			checkType(l,2,out a1);
			System.Int32 a2;
			checkType(l,3,out a2);
			self.UnRegisterUIEvent(a1,a2);
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int RegisterCustomEvent(IntPtr l) {
		try {
			GameEventMgr self=(GameEventMgr)checkSelf(l);
			UnityEngine.GameObject a1;
			checkType(l,2,out a1);
			self.RegisterCustomEvent(a1);
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int UnRegisterCustomEvent(IntPtr l) {
		try {
			GameEventMgr self=(GameEventMgr)checkSelf(l);
			UnityEngine.GameObject a1;
			checkType(l,2,out a1);
			self.UnRegisterCustomEvent(a1);
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int GetInstance_s(IntPtr l) {
		try {
			var ret=GameEventMgr.GetInstance();
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
	static public int get_ET_ApplicationFocus(IntPtr l) {
		try {
			pushValue(l,true);
			pushValue(l,GameEventMgr.ET_ApplicationFocus);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_ET_UIOnClicked(IntPtr l) {
		try {
			pushValue(l,true);
			pushValue(l,GameEventMgr.ET_UIOnClicked);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_ET_UIToggle(IntPtr l) {
		try {
			pushValue(l,true);
			pushValue(l,GameEventMgr.ET_UIToggle);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_ET_UIPress(IntPtr l) {
		try {
			pushValue(l,true);
			pushValue(l,GameEventMgr.ET_UIPress);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_ET_UIRelease(IntPtr l) {
		try {
			pushValue(l,true);
			pushValue(l,GameEventMgr.ET_UIRelease);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_ET_UIEnter(IntPtr l) {
		try {
			pushValue(l,true);
			pushValue(l,GameEventMgr.ET_UIEnter);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_ET_UIExit(IntPtr l) {
		try {
			pushValue(l,true);
			pushValue(l,GameEventMgr.ET_UIExit);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_ET_UIDrag(IntPtr l) {
		try {
			pushValue(l,true);
			pushValue(l,GameEventMgr.ET_UIDrag);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_ET_UITreeViewChange(IntPtr l) {
		try {
			pushValue(l,true);
			pushValue(l,GameEventMgr.ET_UITreeViewChange);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_ET_UITreeViewSelect(IntPtr l) {
		try {
			pushValue(l,true);
			pushValue(l,GameEventMgr.ET_UITreeViewSelect);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_ET_UISwipeViewChange(IntPtr l) {
		try {
			pushValue(l,true);
			pushValue(l,GameEventMgr.ET_UISwipeViewChange);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_ET_UISwipeViewSelect(IntPtr l) {
		try {
			pushValue(l,true);
			pushValue(l,GameEventMgr.ET_UISwipeViewSelect);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_ET_UITextPicPopulateMesh(IntPtr l) {
		try {
			pushValue(l,true);
			pushValue(l,GameEventMgr.ET_UITextPicPopulateMesh);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_ET_UILongPress(IntPtr l) {
		try {
			pushValue(l,true);
			pushValue(l,GameEventMgr.ET_UILongPress);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_ET_UIPointerClick(IntPtr l) {
		try {
			pushValue(l,true);
			pushValue(l,GameEventMgr.ET_UIPointerClick);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_ET_UISliderValueChange(IntPtr l) {
		try {
			pushValue(l,true);
			pushValue(l,GameEventMgr.ET_UISliderValueChange);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_ET_UIInputFieldValueChange(IntPtr l) {
		try {
			pushValue(l,true);
			pushValue(l,GameEventMgr.ET_UIInputFieldValueChange);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_ET_UITextPicOnClickHref(IntPtr l) {
		try {
			pushValue(l,true);
			pushValue(l,GameEventMgr.ET_UITextPicOnClickHref);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_ET_UIActivityEffectFinish(IntPtr l) {
		try {
			pushValue(l,true);
			pushValue(l,GameEventMgr.ET_UIActivityEffectFinish);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_ET_UIChatViewUpdate(IntPtr l) {
		try {
			pushValue(l,true);
			pushValue(l,GameEventMgr.ET_UIChatViewUpdate);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_ET_UILoopListItemSelect(IntPtr l) {
		try {
			pushValue(l,true);
			pushValue(l,GameEventMgr.ET_UILoopListItemSelect);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_ET_UIDynamicListItemSelect(IntPtr l) {
		try {
			pushValue(l,true);
			pushValue(l,GameEventMgr.ET_UIDynamicListItemSelect);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_ET_UIDynamicListItemUpdate(IntPtr l) {
		try {
			pushValue(l,true);
			pushValue(l,GameEventMgr.ET_UIDynamicListItemUpdate);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_ET_UIDynamicListItemRequest(IntPtr l) {
		try {
			pushValue(l,true);
			pushValue(l,GameEventMgr.ET_UIDynamicListItemRequest);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_ET_UISlideSelectChange(IntPtr l) {
		try {
			pushValue(l,true);
			pushValue(l,GameEventMgr.ET_UISlideSelectChange);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_ET_UIScrollListViewChange(IntPtr l) {
		try {
			pushValue(l,true);
			pushValue(l,GameEventMgr.ET_UIScrollListViewChange);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_ET_UISlideSelectBegin(IntPtr l) {
		try {
			pushValue(l,true);
			pushValue(l,GameEventMgr.ET_UISlideSelectBegin);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_ET_UISlideSelectEnd(IntPtr l) {
		try {
			pushValue(l,true);
			pushValue(l,GameEventMgr.ET_UISlideSelectEnd);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_ET_UIScrollRectOnValueChanged(IntPtr l) {
		try {
			pushValue(l,true);
			pushValue(l,GameEventMgr.ET_UIScrollRectOnValueChanged);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_ET_UIBeginDrag(IntPtr l) {
		try {
			pushValue(l,true);
			pushValue(l,GameEventMgr.ET_UIBeginDrag);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_ET_UIEndDrag(IntPtr l) {
		try {
			pushValue(l,true);
			pushValue(l,GameEventMgr.ET_UIEndDrag);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_ET_CustomEvent(IntPtr l) {
		try {
			pushValue(l,true);
			pushValue(l,GameEventMgr.ET_CustomEvent);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_ET_AnimEvent(IntPtr l) {
		try {
			pushValue(l,true);
			pushValue(l,GameEventMgr.ET_AnimEvent);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_ET_Resource(IntPtr l) {
		try {
			pushValue(l,true);
			pushValue(l,GameEventMgr.ET_Resource);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_ET_EffectEvent(IntPtr l) {
		try {
			pushValue(l,true);
			pushValue(l,GameEventMgr.ET_EffectEvent);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_ET_Input(IntPtr l) {
		try {
			pushValue(l,true);
			pushValue(l,GameEventMgr.ET_Input);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_ET_SDK(IntPtr l) {
		try {
			pushValue(l,true);
			pushValue(l,GameEventMgr.ET_SDK);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_ET_Trigger(IntPtr l) {
		try {
			pushValue(l,true);
			pushValue(l,GameEventMgr.ET_Trigger);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_ET_LuaReload(IntPtr l) {
		try {
			pushValue(l,true);
			pushValue(l,GameEventMgr.ET_LuaReload);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[UnityEngine.Scripting.Preserve]
	static public void reg(IntPtr l) {
		getTypeTable(l,"GameEventMgr");
		addMember(l,RegisterUIEvent);
		addMember(l,UnRegisterUIEvent);
		addMember(l,RegisterCustomEvent);
		addMember(l,UnRegisterCustomEvent);
		addMember(l,GetInstance_s);
		addMember(l,"ET_ApplicationFocus",get_ET_ApplicationFocus,null,false);
		addMember(l,"ET_UIOnClicked",get_ET_UIOnClicked,null,false);
		addMember(l,"ET_UIToggle",get_ET_UIToggle,null,false);
		addMember(l,"ET_UIPress",get_ET_UIPress,null,false);
		addMember(l,"ET_UIRelease",get_ET_UIRelease,null,false);
		addMember(l,"ET_UIEnter",get_ET_UIEnter,null,false);
		addMember(l,"ET_UIExit",get_ET_UIExit,null,false);
		addMember(l,"ET_UIDrag",get_ET_UIDrag,null,false);
		addMember(l,"ET_UITreeViewChange",get_ET_UITreeViewChange,null,false);
		addMember(l,"ET_UITreeViewSelect",get_ET_UITreeViewSelect,null,false);
		addMember(l,"ET_UISwipeViewChange",get_ET_UISwipeViewChange,null,false);
		addMember(l,"ET_UISwipeViewSelect",get_ET_UISwipeViewSelect,null,false);
		addMember(l,"ET_UITextPicPopulateMesh",get_ET_UITextPicPopulateMesh,null,false);
		addMember(l,"ET_UILongPress",get_ET_UILongPress,null,false);
		addMember(l,"ET_UIPointerClick",get_ET_UIPointerClick,null,false);
		addMember(l,"ET_UISliderValueChange",get_ET_UISliderValueChange,null,false);
		addMember(l,"ET_UIInputFieldValueChange",get_ET_UIInputFieldValueChange,null,false);
		addMember(l,"ET_UITextPicOnClickHref",get_ET_UITextPicOnClickHref,null,false);
		addMember(l,"ET_UIActivityEffectFinish",get_ET_UIActivityEffectFinish,null,false);
		addMember(l,"ET_UIChatViewUpdate",get_ET_UIChatViewUpdate,null,false);
		addMember(l,"ET_UILoopListItemSelect",get_ET_UILoopListItemSelect,null,false);
		addMember(l,"ET_UIDynamicListItemSelect",get_ET_UIDynamicListItemSelect,null,false);
		addMember(l,"ET_UIDynamicListItemUpdate",get_ET_UIDynamicListItemUpdate,null,false);
		addMember(l,"ET_UIDynamicListItemRequest",get_ET_UIDynamicListItemRequest,null,false);
		addMember(l,"ET_UISlideSelectChange",get_ET_UISlideSelectChange,null,false);
		addMember(l,"ET_UIScrollListViewChange",get_ET_UIScrollListViewChange,null,false);
		addMember(l,"ET_UISlideSelectBegin",get_ET_UISlideSelectBegin,null,false);
		addMember(l,"ET_UISlideSelectEnd",get_ET_UISlideSelectEnd,null,false);
		addMember(l,"ET_UIScrollRectOnValueChanged",get_ET_UIScrollRectOnValueChanged,null,false);
		addMember(l,"ET_UIBeginDrag",get_ET_UIBeginDrag,null,false);
		addMember(l,"ET_UIEndDrag",get_ET_UIEndDrag,null,false);
		addMember(l,"ET_CustomEvent",get_ET_CustomEvent,null,false);
		addMember(l,"ET_AnimEvent",get_ET_AnimEvent,null,false);
		addMember(l,"ET_Resource",get_ET_Resource,null,false);
		addMember(l,"ET_EffectEvent",get_ET_EffectEvent,null,false);
		addMember(l,"ET_Input",get_ET_Input,null,false);
		addMember(l,"ET_SDK",get_ET_SDK,null,false);
		addMember(l,"ET_Trigger",get_ET_Trigger,null,false);
		addMember(l,"ET_LuaReload",get_ET_LuaReload,null,false);
		GameEventMgrManualWrap.reg(l);
		createTypeMetatable(l,null, typeof(GameEventMgr));
	}
}
