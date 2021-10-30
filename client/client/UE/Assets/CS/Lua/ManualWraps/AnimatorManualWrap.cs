using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using SLua;
using System;
using System.Reflection;

[ExtendLuaClass(typeof(Animator))]
public class AnimatorManualWrap : LuaObject {
    [UnityEngine.Scripting.Preserve]
    public static void reg(IntPtr l) {
        addMember(l, PlayLayerAnim);
        addMember(l, SetFloatParam);
        addMember(l, GetCurAnimTime);
		addMember(l, GetAnimLength);
		addMember(l, GetAllAnimLength);
		addMember(l, PlayAnim);
        addMember(l, IsStateExist);
    }
    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int IsStateExist(IntPtr l) {
        try {
            Animator self=(Animator)checkSelf(l);
            string state_name;
            checkType(l, 2, out state_name);
            int layer_num;
            checkType(l, 3, out layer_num);
            pushValue(l, true);
            pushValue(l, self.HasState(layer_num, Animator.StringToHash(state_name)));
            return 2;
        } catch (Exception e) {
            return error(l, e);
        }
    }
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
	static public int GetAllAnimLength(IntPtr l) {
		try {
			Animator self=(Animator)checkSelf(l);
			pushValue(l, true);
			LuaDLL.lua_newtable(l);
			foreach(var ac in self.runtimeAnimatorController.animationClips) {
				if (ac.isLooping) {
					continue;
				}
				pushValue(l, ac.name);
				pushValue(l, ac.length);
				LuaDLL.lua_settable(l, -3);
			}
			return 2;
		} catch (Exception e) {
            return error(l,e);
        }
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
	static public int GetAnimLength(IntPtr l) {
		try {
            Animator self=(Animator)checkSelf(l);
			string anim_name;
			checkType(l, 2, out anim_name);
			float len = 0;
			foreach(var ac in self.runtimeAnimatorController.animationClips) {
				if (ac.name == anim_name) {
					len = ac.length;
					break;
				}
			}
			pushValue(l, true);
			pushValue(l, len);
			return 2;
		} catch (Exception e) {
            return error(l,e);
        }
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int PlayAnim(IntPtr l) {
    	try {
			Animator self=(Animator)checkSelf(l);
			string state_name;
			checkType(l, 2, out state_name);
			float speed;
            checkType(l, 3, out speed);
			float begin_time;
            checkType(l, 4, out begin_time);
            float trans_time;
            checkType(l, 5, out trans_time);
            self.speed = speed;
            self.CrossFadeInFixedTime(state_name, trans_time, 0, begin_time);
            pushValue(l, true);
            return 1;
    	} catch (Exception e) {
    		return error(l, e);
    	}
    }
    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int PlayLayerAnim(IntPtr l) {
        try {
            Animator self=(Animator)checkSelf(l);
            string state_name;
            checkType(l, 2, out state_name);
            float speed;
            checkType(l, 3, out speed);
            int layer_num;
            checkType(l, 4, out layer_num);
            float begin_time;
            checkType(l, 5, out begin_time);
            float trans_time;
            checkType(l, 6, out trans_time);
            string speed_param_name;
            checkType(l, 7, out speed_param_name);
            self.SetFloat(speed_param_name, speed);
            self.CrossFadeInFixedTime(state_name, trans_time, layer_num, begin_time);
            pushValue(l,true);
            return 1;
        } catch (Exception e) {
            return error(l,e);
        }
    }
    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int SetFloatParam(IntPtr l) {
        try {
            Animator self=(Animator)checkSelf(l);
            string param_name;
            checkType(l, 2, out param_name);
            float param_value;
            checkType(l, 3, out param_value);
            self.SetFloat(param_name, param_value);
            pushValue(l,true);
            return 1;
        } catch (Exception e) {
            return error(l,e);
        }
    }
    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int GetCurAnimTime(IntPtr l) {
        try {
            Animator self=(Animator)checkSelf(l);
            int layer_num;
            checkType(l, 2, out layer_num);
            var st_info = self.GetCurrentAnimatorStateInfo(layer_num);
            pushValue(l,true);
            pushValue(l, st_info.normalizedTime * st_info.length);
            return 2;
        } catch (Exception e) {
            return error(l,e);
        }
    }
}
