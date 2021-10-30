using System;
using SLua;
using System.Collections.Generic;
[UnityEngine.Scripting.Preserve]
public class Lua_UIColorPicker : LuaObject {
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int SetHSVColor(IntPtr l) {
		try {
			UIColorPicker self=(UIColorPicker)checkSelf(l);
			UnityEngine.Color a1;
			checkType(l,2,out a1);
			self.SetHSVColor(a1);
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int SetRGBColor(IntPtr l) {
		try {
			UIColorPicker self=(UIColorPicker)checkSelf(l);
			UnityEngine.Color a1;
			checkType(l,2,out a1);
			self.SetRGBColor(a1);
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int GetHSVColor(IntPtr l) {
		try {
			UIColorPicker self=(UIColorPicker)checkSelf(l);
			var ret=self.GetHSVColor();
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
	static public int GetRGBColor(IntPtr l) {
		try {
			UIColorPicker self=(UIColorPicker)checkSelf(l);
			var ret=self.GetRGBColor();
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
	static public int get_hue_layer_(IntPtr l) {
		try {
			UIColorPicker self=(UIColorPicker)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.hue_layer_);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_hue_layer_(IntPtr l) {
		try {
			UIColorPicker self=(UIColorPicker)checkSelf(l);
			UIColorLayer v;
			checkType(l,2,out v);
			self.hue_layer_=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_saturation_layer_(IntPtr l) {
		try {
			UIColorPicker self=(UIColorPicker)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.saturation_layer_);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_saturation_layer_(IntPtr l) {
		try {
			UIColorPicker self=(UIColorPicker)checkSelf(l);
			UIColorLayer v;
			checkType(l,2,out v);
			self.saturation_layer_=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_brighness_layer_(IntPtr l) {
		try {
			UIColorPicker self=(UIColorPicker)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.brighness_layer_);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_brighness_layer_(IntPtr l) {
		try {
			UIColorPicker self=(UIColorPicker)checkSelf(l);
			UIColorLayer v;
			checkType(l,2,out v);
			self.brighness_layer_=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_alpha_layer_(IntPtr l) {
		try {
			UIColorPicker self=(UIColorPicker)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.alpha_layer_);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_alpha_layer_(IntPtr l) {
		try {
			UIColorPicker self=(UIColorPicker)checkSelf(l);
			UIColorLayer v;
			checkType(l,2,out v);
			self.alpha_layer_=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[UnityEngine.Scripting.Preserve]
	static public void reg(IntPtr l) {
		getTypeTable(l,"UIColorPicker");
		addMember(l,SetHSVColor);
		addMember(l,SetRGBColor);
		addMember(l,GetHSVColor);
		addMember(l,GetRGBColor);
		addMember(l,"hue_layer_",get_hue_layer_,set_hue_layer_,true);
		addMember(l,"saturation_layer_",get_saturation_layer_,set_saturation_layer_,true);
		addMember(l,"brighness_layer_",get_brighness_layer_,set_brighness_layer_,true);
		addMember(l,"alpha_layer_",get_alpha_layer_,set_alpha_layer_,true);
		createTypeMetatable(l,null, typeof(UIColorPicker),typeof(UnityEngine.EventSystems.UIBehaviour));
	}
}
