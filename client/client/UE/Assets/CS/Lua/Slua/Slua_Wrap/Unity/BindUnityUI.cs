using System;
using System.Collections.Generic;
namespace SLua {
	[LuaBinder(1)]
	public class BindUnityUI {
		public static Action<IntPtr>[] GetBindList() {
			Action<IntPtr>[] list= {
				Lua_UnityEngine_UI_Selectable.reg,
				Lua_UnityEngine_UI_Toggle.reg,
				Lua_UnityEngine_UI_ToggleGroup.reg,
				Lua_UnityEngine_UI_Button.reg,
				Lua_UnityEngine_UI_InputField.reg,
				Lua_UnityEngine_UI_Graphic.reg,
				Lua_UnityEngine_UI_MaskableGraphic.reg,
				Lua_UnityEngine_UI_Image.reg,
				Lua_UnityEngine_UI_RawImage.reg,
				Lua_UnityEngine_UI_LayoutGroup.reg,
				Lua_UnityEngine_UI_HorizontalOrVerticalLayoutGroup.reg,
				Lua_UnityEngine_UI_VerticalLayoutGroup.reg,
				Lua_UnityEngine_UI_HorizontalLayoutGroup.reg,
				Lua_UnityEngine_UI_GridLayoutGroup.reg,
				Lua_UnityEngine_UI_Text.reg,
				Lua_UnityEngine_UI_Slider.reg,
				Lua_UnityEngine_UI_LayoutElement.reg,
				Lua_UnityEngine_UI_ContentSizeFitter.reg,
				Lua_UnityEngine_UI_Scrollbar.reg,
				Lua_UnityEngine_UI_ScrollRect.reg,
				Lua_UnityEngine_UI_Mask.reg,
			};
			return list;
		}
	}
}
