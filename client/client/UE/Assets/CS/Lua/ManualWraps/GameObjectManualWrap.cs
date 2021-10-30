using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using SLua;
using System;
using System.Reflection;
using UnityEngine.UI;
#if UNITY_EDITOR
using UnityEditor;
#endif


[ExtendLuaClass(typeof(GameObject))]
public class GameObjectManualWrap : LuaObject {
    public static Vector3 sRayCastUpOffset = new Vector3(0.0f, 2.0f, 0.0f);
    static ParticleSystem.Particle [] _sParticleCache = new ParticleSystem.Particle[100];

    [UnityEngine.Scripting.Preserve]
    public static void reg(IntPtr l) {
        addMember(l, New_s);
        addMember(l, GetChild);
        addMember(l, FindChild);
        addMember(l, SetParent);
        addMember(l, SetAsFirstSibling);
        addMember(l, SetAsLastSibling);
        addMember(l, SetSiblingIndex);
        addMember(l, GetOrAddComponent);
        addMember(l, SetLayerRecursive);
        addMember(l, SetRenderEnable);
        addMember(l, SetActiveRecursive);
        addMember(l, SetEffectPlaySpeed);
        addMember(l, SetPosition);
        addMember(l, TransformDirection);
        addMember(l, InverseTransformDirection);
        addMember(l, TransformPoint);
        addMember(l, InverseTransformPoint);
        addMember(l, TransformVector);
        addMember(l, InverseTransformVector);
        addMember(l, BeginDelayKill);
        addMember(l, ClearDelayKill);
        addMember(l, CheckParticleAlive);
        addMember(l, ClosestPointToCollider);
        addMember(l, PlayAnim);
        addMember(l, SetSortOrder);
        addMember(l, SetSortingLayer);
        addMember(l, SetCustomLight);
        addMember(l, ResetEffect);
#if UNITY_EDITOR
        addMember(l, SetAnimationMode, false);
        addMember(l, BeginSampling, false);
        addMember(l, EndSampling, false);
        addMember(l, SampleAnimationClip);
        addMember(l, SampleEffect);
        addMember(l, StopSampleEffect);
        addMember(l, SampleUnit);
#endif

        addMember(l, "position", get_position, set_position, true);
        addMember(l, "localPosition", get_localPosition, set_localPosition, true);
        addMember(l, "eulerAngles", get_eulerAngles, set_eulerAngles, true);
        addMember(l, "localEulerAngles", get_localEulerAngles, set_localEulerAngles, true);
        addMember(l, "right", get_right, set_right, true);
        addMember(l, "up", get_up, set_up, true);
        addMember(l, "forward", get_forward, set_forward, true);
        addMember(l, "rotation", get_rotation, set_rotation, true);
        addMember(l, "localRotation", get_localRotation, set_localRotation, true);
        addMember(l, "localScale", get_localScale, set_localScale, true);
        addMember(l, "parent", get_parent, set_parent, true);
        addMember(l, "worldToLocalMatrix", get_worldToLocalMatrix, null, true);
        addMember(l, "localToWorldMatrix", get_localToWorldMatrix, null, true);
        addMember(l, "root", get_root, null, true);
        addMember(l, "childCount", get_childCount, null, true);
        addMember(l, "lossyScale", get_lossyScale, null, true);
        addMember(l, "hasChanged", get_hasChanged, set_hasChanged, true);
        addMember(l, "layerName", get_layerName, set_layerName, true);
    }


#if UNITY_EDITOR

    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int SetAnimationMode(IntPtr l) {
        try {
            bool enable;
            checkType(l, 1, out enable);
            if (enable != AnimationMode.InAnimationMode()) {
                if (enable) AnimationMode.StartAnimationMode();
                else AnimationMode.StopAnimationMode();
            }
            pushValue(l, true);
            return 1;
        } catch (Exception e) {
            return error(l, e);
        }
    }

    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int BeginSampling(IntPtr l) {
        try {
            AnimationMode.BeginSampling();
            pushValue(l, true);
            return 1;
        } catch (Exception e) {
            return error(l, e);
        }
    }

    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int EndSampling(IntPtr l) {
        try {
            AnimationMode.EndSampling();
            pushValue(l, true);
            return 1;
        } catch (Exception e) {
            return error(l, e);
        }
    }

    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int SampleAnimationClip(IntPtr l) {
        try {
            UnityEngine.GameObject self = (UnityEngine.GameObject)checkSelf(l);
            AnimationClip anim;
            checkType(l, 2, out anim);
            float time;
            checkType(l, 3, out time);
            if (anim.isLooping || anim.wrapMode == WrapMode.Loop) {
                AnimationMode.SampleAnimationClip(self, anim, time % anim.length);
            } else {
                AnimationMode.SampleAnimationClip(self, anim, time);
            }
            pushValue(l, true);
            return 1;
        } catch (Exception e) {
            return error(l, e);
        }
    }


    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int SampleEffect(IntPtr l) {
        try {
            UnityEngine.GameObject self = (UnityEngine.GameObject)checkSelf(l);
            float time;
            checkType(l, 2, out time);
            Transform trans = self.transform;
            foreach (var particle in trans.GetComponentsInChildren<ParticleSystem>()) {
                particle.Simulate(time);
            }
            foreach (var animation in trans.GetComponentsInChildren<Animation>()) {
                var anim = animation.clip;
                AnimationMode.SampleAnimationClip(animation.gameObject, anim, time);
            }
            foreach (var animator in trans.GetComponentsInChildren<Animator>()) {
                var clip_infos = animator.GetCurrentAnimatorClipInfo(0);
                if (clip_infos.Length == 0) continue;
                var anim = clip_infos[0].clip;
                if (anim.isLooping || anim.wrapMode == WrapMode.Loop) {
                    AnimationMode.SampleAnimationClip(animator.gameObject, anim, time % anim.length);
                } else {
                    AnimationMode.SampleAnimationClip(animator.gameObject, anim, time);
                }
            }
            //foreach (var effect_anim in trans.GetComponentsInChildren<EffectAnimBase>()) {
            //    if (effect_anim.enabled && effect_anim.auto_play_) {
            //        effect_anim.SetTime(time);
            //        effect_anim.Stop();
            //    }
            //}
            pushValue(l, true);
            return 1;
        } catch (Exception e) {
            return error(l, e);
        }
    }

    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int StopSampleEffect(IntPtr l) {
        try {
            UnityEngine.GameObject self = (UnityEngine.GameObject)checkSelf(l);
            Transform trans = self.transform;
            foreach (var particle in trans.GetComponentsInChildren<ParticleSystem>()) {
                if (particle.main.playOnAwake) particle.Play();
            }
            //foreach (var effect_anim in trans.GetComponentsInChildren<EffectAnimBase>()) {
            //    if (effect_anim.auto_play_) effect_anim.is_play_ = true;
            //}
            pushValue(l, true);
            return 1;
        } catch (Exception e) {
            return error(l, e);
        }
    }

    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int SampleUnit(IntPtr l) {
        try {
            UnityEngine.GameObject self = (UnityEngine.GameObject)checkSelf(l);
            string anim_name;
            checkType(l, 2, out anim_name);
            float time;
            checkType(l, 3, out time);
            Transform trans = self.transform;
            var animator = trans.Find("model").GetComponent<Animator>();
            var controller = animator.runtimeAnimatorController;
            foreach (var anim in controller.animationClips) {
                if (anim.name == anim_name) {
                    if (anim.isLooping || anim.wrapMode == WrapMode.Loop) {
                        AnimationMode.SampleAnimationClip(animator.gameObject, anim, time % anim.length);
                    } else {
                        AnimationMode.SampleAnimationClip(animator.gameObject, anim, time);
                    }
                }
            }
            pushValue(l, true);
            return 1;
        } catch (Exception e) {
            return error(l, e);
        }
    }
#endif


    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int SetCustomLight(IntPtr l) {
        try {
            UnityEngine.GameObject self = (UnityEngine.GameObject)checkSelf(l);
            Color _GameLightColor;
            checkType(l, 2, out _GameLightColor);
            Vector3 _GameLightDir;
            checkType(l, 3, out _GameLightDir);
            Color _GameLightRoleLight;
            checkType(l, 4, out _GameLightRoleLight);
            Color _GameLightRoleDark;
            checkType(l, 5, out _GameLightRoleDark);
            Color _GameLightRoleShadow;
            checkType(l, 6, out _GameLightRoleShadow);
            Color _GameLightDynamicAmbient;
            checkType(l, 7, out _GameLightDynamicAmbient);
            foreach (var renderer in self.GetComponentsInChildren<Renderer>(true)) {
                var mats = renderer.materials;
                foreach (var mat in renderer.materials) {
                    mat.SetColor("_GameLightColor", _GameLightColor);
                    mat.SetVector("_GameLightDir", _GameLightDir);
                    mat.SetColor("_GameLightRoleLight", _GameLightRoleLight);
                    mat.SetColor("_GameLightRoleDark", _GameLightRoleDark);
                    mat.SetColor("_GameLightRoleShadow", _GameLightRoleShadow);
                    mat.SetColor("_GameLightDynamicAmbient", _GameLightDynamicAmbient);
                }
            }
            pushValue(l, true);
            return 1;
        } catch (Exception e) {
            return error(l, e);
        }
    }

    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int ResetEffect(IntPtr l)
    {
        try
        {
            UnityEngine.GameObject self = (UnityEngine.GameObject)checkSelf(l);
            TrailRenderer[] trail_comps = self.GetComponentsInChildren<TrailRenderer>();
            foreach (TrailRenderer comp in trail_comps)
            {
                comp.Clear();
            }
            ParticleSystem[] ptc_comps = self.GetComponentsInChildren<ParticleSystem>();
            foreach (var comp in ptc_comps) {
                comp.Clear();
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
    static public int SetSortOrder(IntPtr l)
    {
        try
        {
            UnityEngine.GameObject self = (UnityEngine.GameObject)checkSelf(l);
            int sort_order;
            checkType(l, 2, out sort_order);
            Renderer[] list = self.GetComponentsInChildren<Renderer>(true);
            foreach (Renderer r in list)
            {
                r.sortingOrder = sort_order;
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
    static public int SetSortingLayer(IntPtr l)
    {
        try
        {
            UnityEngine.GameObject self = (UnityEngine.GameObject)checkSelf(l);
            string sorting_layer;
            checkType(l, 2, out sorting_layer);
            Renderer[] list = self.GetComponentsInChildren<Renderer>(true);
            foreach (Renderer r in list)
            {
                r.sortingLayerName = sorting_layer;
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
    static public int PlayAnim(IntPtr l) {
        try {
            UnityEngine.GameObject self = (UnityEngine.GameObject)checkSelf(l);
            string anim_name;
            checkType(l, 2, out anim_name);
            float blend_time;
            checkType(l, 3, out blend_time);
            float start_time = 0;
            int argc = LuaDLL.lua_gettop(l);
            if (argc > 3) checkType(l, 4, out start_time);

            var animation = self.GetComponent<Animation>();
            if (animation != null) animation.CrossFade(anim_name, blend_time);
            var animator = self.GetComponent<Animator>();
            if (animator != null) {
                for (int i = 0; i < animator.layerCount; ++i) {
                    animator.CrossFadeInFixedTime(anim_name, blend_time, i, start_time);
                }
            }
            pushValue(l, true);
            return 1;
        } catch (Exception e) {
            return error(l, e);
        }
    }
    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int ClosestPointToCollider(IntPtr l) {
        try {
            UnityEngine.GameObject self = (UnityEngine.GameObject)checkSelf(l);
            Vector3 pos;
            checkType(l, 2, out pos);
            var collider = self.GetComponent<Collider>();
            Vector3 closest_pos;
            if (collider != null) {
                closest_pos = collider.ClosestPoint(pos);
            } else{
                closest_pos = self.transform.position;
            }
            pushValue(l, true);
            pushValue(l, closest_pos);
            return 2;
        } catch (Exception e) {
            return error(l, e);
        }
    }
    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
	static public int CheckParticleAlive(IntPtr l) {
		try {
            UnityEngine.GameObject self=(UnityEngine.GameObject)checkSelf(l);
            var p_cmps = self.GetComponentsInChildren<ParticleSystem>(false);
			bool is_alive = p_cmps.Length == 0;
            foreach(var p_cmp in p_cmps) {
				if (p_cmp.particleCount > 0 && p_cmp.IsAlive()) {
					is_alive = true;
				}
            }
            pushValue(l,true);
			pushValue(l, is_alive);
            return 2;
        } catch (Exception e) {
            return error(l,e);
        }
	}
    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int BeginDelayKill(IntPtr l) {
        try {
            UnityEngine.GameObject self=(UnityEngine.GameObject)checkSelf(l);
            float delay_kill_time = 0;
            var p_cmps = self.GetComponentsInChildren<ParticleSystem>(false);
            foreach(var p_cmp in p_cmps) {
                p_cmp.Stop();
                if (p_cmp.particleCount > 0 && p_cmp.IsAlive()) {
                    int real_count = p_cmp.GetParticles(_sParticleCache);
                    if (real_count > 0) {
                        float life_time = _sParticleCache[real_count - 1].remainingLifetime;
                        if(life_time < 100){
                            delay_kill_time = Mathf.Max(delay_kill_time, life_time);
                        }
                    }
                }
            }
            pushValue(l,true);
            pushValue(l, delay_kill_time);
            return 2;
        } catch (Exception e) {
            return error(l,e);
        }
    }
    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int ClearDelayKill(IntPtr l) {
        try {
            // UnityEngine.GameObject self = (UnityEngine.GameObject)checkSelf(l);
            pushValue(l, true);
            return 1;
        } catch (Exception e) {
            return error(l,e);
        }
    }
    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int New_s(IntPtr l)
    {
        try
        {
            int argc = LuaDLL.lua_gettop(l);
            if(argc == 0)
            {
                var ret = new UnityEngine.GameObject();
                pushValue(l, true);
                pushValue(l, ret);
                return 2;
            }else if(argc == 1)
            {
                System.String a1;
                checkType(l, 1, out a1);
                var ret = new UnityEngine.GameObject(a1);
                pushValue(l, true);
                pushValue(l, ret);
                return 2;
            }
            return 1;
        }
        catch (Exception e)
        {
            return error(l, e);
        }
    }
    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int GetChild(IntPtr l) {
        try {
            UnityEngine.GameObject self=(UnityEngine.GameObject)checkSelf(l);
            System.Int32 a1;
            checkType(l,2,out a1);
            var ret=self.transform.GetChild(a1);
            pushValue(l,true);
            if (ret != null) {
                pushValue(l, ret.gameObject);
                return 2;
            }
            return 1;
        }
        catch(Exception e) {
            return error(l,e);
        }
    }
    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int FindChild(IntPtr l) {
        try {
            UnityEngine.GameObject self = (UnityEngine.GameObject)checkSelf(l);
            System.String a1;
            checkType(l, 2, out a1);
            var ret = self.transform.Find(a1);
            pushValue(l, true);
            if (ret != null) {
                pushValue(l, ret.gameObject);
                return 2;
            }
            return 1;
        }
        catch(Exception e) {
            return error(l,e);
        }
    }

    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int SetParent(IntPtr l) {
        try {
            int argc = LuaDLL.lua_gettop(l);
            if (argc == 1)
            {
                UnityEngine.GameObject self = (UnityEngine.GameObject)checkSelf(l);
                self.transform.SetParent(null);
                pushValue(l, true);
                return 1;
            }
            else if (argc==2) {
                UnityEngine.GameObject self=(UnityEngine.GameObject)checkSelf(l);
                UnityEngine.GameObject a1;
                checkType(l, 2, out a1);
                self.transform.SetParent(a1.transform);
                pushValue(l,true);
                return 1;
            } else if(argc==3) {
                UnityEngine.GameObject self=(UnityEngine.GameObject)checkSelf(l);
                UnityEngine.GameObject a1;
                checkType(l, 2, out a1);
                System.Boolean a2;
                checkType(l, 3, out a2);
                self.transform.SetParent(a1.transform, a2);
                pushValue(l,true);
                return 1;
            }
            pushValue(l,false);
            LuaDLL.lua_pushstring(l,"No matched override function to call");
            return 2;
        } catch(Exception e) {
            return error(l,e);
        }
    }

    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int SetAsFirstSibling(IntPtr l) {
        try {
            UnityEngine.GameObject self = (UnityEngine.GameObject)checkSelf(l);
            self.transform.SetAsFirstSibling();
            pushValue(l,true);
            return 1;
        } catch(Exception e) {
            return error(l,e);
        }
    }

    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int SetAsLastSibling(IntPtr l)
    {
        try
        {
            UnityEngine.GameObject self = (UnityEngine.GameObject)checkSelf(l);
            self.transform.SetAsLastSibling();
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
    static public int SetSiblingIndex(IntPtr l) {
        try {
            UnityEngine.GameObject self=(UnityEngine.GameObject)checkSelf(l);
            System.Int32 a1;
            checkType(l,2,out a1);
            self.transform.SetSiblingIndex(a1);
            pushValue(l,true);
            return 1;
        } catch(Exception e) {
            return error(l,e);
        }
    }

    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int GetOrAddComponent(IntPtr l) {
        try {
            int argc = LuaDLL.lua_gettop(l);
            if(matchType(l,argc,2,typeof(string))){
                UnityEngine.GameObject self=(UnityEngine.GameObject)checkSelf(l);
                System.String a1;
                checkType(l,2,out a1);
                var ret=self.GetComponent(a1);
                if (ret == null) {
                    Type c_type = FindType(a1);
                    if (c_type == null) {
                        c_type = FindType("UnityEngine." + a1);
                    }
                    if (c_type != null) {
                        ret = self.AddComponent(c_type);
                    }
                }
                pushValue(l,true);
                pushValue(l,ret);
                return 2;
            }
            else if(matchType(l,argc,2,typeof(System.Type))){
                UnityEngine.GameObject self=(UnityEngine.GameObject)checkSelf(l);
                System.Type a1;
                checkType(l,2,out a1);
                var ret=self.GetComponent(a1);
                if (ret == null) {
                    ret = self.AddComponent(a1);
                }
                pushValue(l,true);
                pushValue(l,ret);
                return 2;
            }
            pushValue(l,false);
            LuaDLL.lua_pushstring(l,"No matched override function to call");
            return 2;
        } catch(Exception e) {
            return error(l,e);
        }
    }

    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int SetLayerRecursive(IntPtr l) {
        try {
            UnityEngine.GameObject self=(UnityEngine.GameObject)checkSelf(l);
            int v;
            checkType(l,2,out v);
            _SetLayerRecursive(self.transform, v);
            pushValue(l,true);
            return 1;
        } catch(Exception e) {
            return error(l,e);
        }
    }

    static void _SetLayerRecursive(Transform tf, int layer) {
        tf.gameObject.layer = layer;
        foreach(Transform ctf in tf) {
            _SetLayerRecursive(ctf, layer);
        }
    }

    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int SetRenderEnable(IntPtr l) {
        try {
            UnityEngine.GameObject self=(UnityEngine.GameObject)checkSelf(l);
            System.String a1;
            checkType(l,2,out a1);
            System.String a2;
            checkType(l,3,out a2);
            int new_layer = LayerMask.NameToLayer(a1);
            int cur_layer = LayerMask.NameToLayer(a2);
            _SetRenderEnable(self.transform, new_layer, cur_layer);
            pushValue(l,true);
            return 1;
        } catch(Exception e) {
            return error(l,e);
        }
    }
    public static void _SetRenderEnable(Transform tf, int new_layer, int cur_layer)
    {
        if (tf.gameObject.layer == cur_layer) {
            tf.gameObject.layer = new_layer;
        }
        foreach (Transform ctf in tf) {
            _SetRenderEnable(ctf, new_layer, cur_layer);
        }
    }

    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int SetActiveRecursive(IntPtr l) {
        try {
            UnityEngine.GameObject self=(UnityEngine.GameObject)checkSelf(l);
            bool a1;
            checkType(l,2,out a1);
            _SetActiveRecursive(self.transform, a1);
            pushValue(l,true);
            return 1;
        } catch(Exception e) {
            return error(l,e);
        }
    }
    static void _SetActiveRecursive(Transform tf, bool is_active) {
        foreach(Transform ctf in tf) {
            _SetActiveRecursive(ctf, is_active);
        }
        if (tf.gameObject.activeSelf != is_active) {
            tf.gameObject.SetActive(is_active);
        }
    }

    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int SetEffectPlaySpeed(IntPtr l) {
        try {
            UnityEngine.GameObject self=(UnityEngine.GameObject)checkSelf(l);
            float a1;
            checkType(l,2,out a1);
            _SetEffectPlaySpeed(self.transform, a1);
            pushValue(l,true);
            return 1;
        } catch(Exception e) {
            return error(l,e);
        }
    }

    static void _SetEffectPlaySpeed(Transform tf, float speed) {
        var p_cmps = tf.GetComponentsInChildren<ParticleSystem>(true);
        foreach(var cmp in p_cmps) {
            var main = cmp.main;
            main.simulationSpeed = speed;
        }
        var animators = tf.GetComponentsInChildren<Animator>(true);
        foreach (var animator in animators) {
            animator.speed = speed;
        }
    }

    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int SetPosition(IntPtr l) {
        try {
            UnityEngine.GameObject self=(UnityEngine.GameObject)checkSelf(l);
            Vector3 pos;
            checkType(l,2,out pos);
            int count = LuaDLL.lua_gettop(l);
            bool is_trace_down = count >= 3 && !(LuaDLL.lua_isnil(l, 3));
            if (is_trace_down) {
                int layer_mask;
                checkType(l, 3, out layer_mask);
                RaycastHit hit;
                if (Physics.Raycast(pos + sRayCastUpOffset, Vector3.down, out hit, 1000.0f, layer_mask)) {
                    pos.y = hit.point.y;
                }
            }
            bool has_y_offset = count >= 4 && !(LuaDLL.lua_isnil(l, 4));
            if (has_y_offset) {
                float y_offset;
                checkType(l, 4, out y_offset);
                pos.y += y_offset;
            }
            self.transform.position = pos;
            pushValue(l, true);
            pushValue(l, pos);
            return 2;
        } catch(Exception e) {
            return error(l,e);
        }
    }

    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int TransformDirection(IntPtr l) {
        try {
            int argc = LuaDLL.lua_gettop(l);
            if(argc==2){
                UnityEngine.GameObject self=(UnityEngine.GameObject)checkSelf(l);
                UnityEngine.Vector3 a1;
                checkType(l,2,out a1);
                var ret=self.transform.TransformDirection(a1);
                pushValue(l,true);
                pushValue(l,ret);
                return 2;
            } else if(argc==4){
                UnityEngine.GameObject self=(UnityEngine.GameObject)checkSelf(l);
                System.Single a1;
                checkType(l,2,out a1);
                System.Single a2;
                checkType(l,3,out a2);
                System.Single a3;
                checkType(l,4,out a3);
                var ret=self.transform.TransformDirection(a1,a2,a3);
                pushValue(l,true);
                pushValue(l,ret);
                return 2;
            }
            pushValue(l,false);
            LuaDLL.lua_pushstring(l,"No matched override function to call");
            return 2;
        } catch(Exception e) {
            return error(l,e);
        }
    }

    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int InverseTransformDirection(IntPtr l) {
        try {
            int argc = LuaDLL.lua_gettop(l);
            if(argc==2){
                UnityEngine.GameObject self=(UnityEngine.GameObject)checkSelf(l);
                UnityEngine.Vector3 a1;
                checkType(l,2,out a1);
                var ret=self.transform.InverseTransformDirection(a1);
                pushValue(l,true);
                pushValue(l,ret);
                return 2;
            } else if(argc==4){
                UnityEngine.GameObject self=(UnityEngine.GameObject)checkSelf(l);
                System.Single a1;
                checkType(l,2,out a1);
                System.Single a2;
                checkType(l,3,out a2);
                System.Single a3;
                checkType(l,4,out a3);
                var ret=self.transform.InverseTransformDirection(a1,a2,a3);
                pushValue(l,true);
                pushValue(l,ret);
                return 2;
            }
            pushValue(l,false);
            LuaDLL.lua_pushstring(l,"No matched override function to call");
            return 2;
        } catch(Exception e) {
            return error(l,e);
        }
    }

    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int TransformPoint(IntPtr l) {
        try {
            int argc = LuaDLL.lua_gettop(l);
            if (argc == 2) {
                UnityEngine.GameObject self = (UnityEngine.GameObject)checkSelf(l);
                UnityEngine.Vector3 a1;
                checkType(l, 2, out a1);
                var ret = self.transform.TransformPoint(a1);
                pushValue(l, true);
                pushValue(l, ret);
                return 2;
            } else if (argc == 4) {
                UnityEngine.GameObject self = (UnityEngine.GameObject)checkSelf(l);
                System.Single a1;
                checkType(l, 2, out a1);
                System.Single a2;
                checkType(l, 3, out a2);
                System.Single a3;
                checkType(l, 4, out a3);
                var ret = self.transform.TransformPoint(a1, a2, a3);
                pushValue(l, true);
                pushValue(l, ret);
                return 2;
            }
            pushValue(l, false);
            LuaDLL.lua_pushstring(l, "No matched override function to call");
            return 2;
        } catch (Exception e) {
            return error(l, e);
        }
    }

    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int InverseTransformPoint(IntPtr l) {
        try {
            int argc = LuaDLL.lua_gettop(l);
            if (argc == 2) {
                UnityEngine.GameObject self = (UnityEngine.GameObject)checkSelf(l);
                UnityEngine.Vector3 a1;
                checkType(l, 2, out a1);
                var ret = self.transform.InverseTransformPoint(a1);
                pushValue(l, true);
                pushValue(l, ret);
                return 2;
            } else if (argc == 4) {
                UnityEngine.GameObject self = (UnityEngine.GameObject)checkSelf(l);
                System.Single a1;
                checkType(l, 2, out a1);
                System.Single a2;
                checkType(l, 3, out a2);
                System.Single a3;
                checkType(l, 4, out a3);
                var ret = self.transform.InverseTransformPoint(a1, a2, a3);
                pushValue(l, true);
                pushValue(l, ret);
                return 2;
            }
            pushValue(l, false);
            LuaDLL.lua_pushstring(l, "No matched override function to call");
            return 2;
        } catch (Exception e) {
            return error(l, e);
        }
    }

    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int TransformVector(IntPtr l) {
        try {
            int argc = LuaDLL.lua_gettop(l);
            if (argc == 2) {
                UnityEngine.GameObject self = (UnityEngine.GameObject)checkSelf(l);
                UnityEngine.Vector3 a1;
                checkType(l, 2, out a1);
                var ret = self.transform.TransformVector(a1);
                pushValue(l, true);
                pushValue(l, ret);
                return 2;
            } else if (argc == 4) {
                UnityEngine.GameObject self = (UnityEngine.GameObject)checkSelf(l);
                System.Single a1;
                checkType(l, 2, out a1);
                System.Single a2;
                checkType(l, 3, out a2);
                System.Single a3;
                checkType(l, 4, out a3);
                var ret = self.transform.TransformVector(a1, a2, a3);
                pushValue(l, true);
                pushValue(l, ret);
                return 2;
            }
            pushValue(l, false);
            LuaDLL.lua_pushstring(l, "No matched override function to call");
            return 2;
        } catch (Exception e) {
            return error(l, e);
        }
    }

    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int InverseTransformVector(IntPtr l) {
        try {
            int argc = LuaDLL.lua_gettop(l);
            if (argc == 2) {
                UnityEngine.GameObject self = (UnityEngine.GameObject)checkSelf(l);
                UnityEngine.Vector3 a1;
                checkType(l, 2, out a1);
                var ret = self.transform.InverseTransformVector(a1);
                pushValue(l, true);
                pushValue(l, ret);
                return 2;
            } else if (argc == 4) {
                UnityEngine.GameObject self = (UnityEngine.GameObject)checkSelf(l);
                System.Single a1;
                checkType(l, 2, out a1);
                System.Single a2;
                checkType(l, 3, out a2);
                System.Single a3;
                checkType(l, 4, out a3);
                var ret = self.transform.InverseTransformVector(a1, a2, a3);
                pushValue(l, true);
                pushValue(l, ret);
                return 2;
            }
            pushValue(l, false);
            LuaDLL.lua_pushstring(l, "No matched override function to call");
            return 2;
        } catch (Exception e) {
            return error(l, e);
        }
    }
// ---------------------------------Field defines begin-----------------------------------------
    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int get_position(IntPtr l) {
        try {
            UnityEngine.GameObject self=(UnityEngine.GameObject)checkSelf(l);
            pushValue(l,true);
            pushValue(l,self.transform.position);
            return 2;
        } catch(Exception e) {
            return error(l,e);
        }
    }
    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int set_position(IntPtr l) {
        try {
            UnityEngine.GameObject self=(UnityEngine.GameObject)checkSelf(l);
            UnityEngine.Vector3 v;
            checkType(l,2,out v);
            self.transform.position=v;
            pushValue(l,true);
            return 1;
        } catch(Exception e) {
            return error(l,e);
        }
    }
    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int get_localPosition(IntPtr l) {
        try {
            UnityEngine.GameObject self=(UnityEngine.GameObject)checkSelf(l);
            pushValue(l,true);
            pushValue(l,self.transform.localPosition);
            return 2;
        }
        catch(Exception e) {
            return error(l,e);
        }
    }
    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int set_localPosition(IntPtr l) {
        try {
            UnityEngine.GameObject self=(UnityEngine.GameObject)checkSelf(l);
            UnityEngine.Vector3 v;
            checkType(l,2,out v);
            self.transform.localPosition=v;
            pushValue(l,true);
            return 1;
        }
        catch(Exception e) {
            return error(l,e);
        }
    }
    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int get_eulerAngles(IntPtr l) {
        try {
            UnityEngine.GameObject self=(UnityEngine.GameObject)checkSelf(l);
            pushValue(l,true);
            pushValue(l,self.transform.eulerAngles);
            return 2;
        }
        catch(Exception e) {
            return error(l,e);
        }
    }
    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int set_eulerAngles(IntPtr l) {
        try {
            UnityEngine.GameObject self=(UnityEngine.GameObject)checkSelf(l);
            UnityEngine.Vector3 v;
            checkType(l,2,out v);
            self.transform.eulerAngles=v;
            pushValue(l,true);
            return 1;
        }
        catch(Exception e) {
            return error(l,e);
        }
    }
    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int get_localEulerAngles(IntPtr l) {
        try {
            UnityEngine.GameObject self=(UnityEngine.GameObject)checkSelf(l);
            pushValue(l,true);
            pushValue(l,self.transform.localEulerAngles);
            return 2;
        }
        catch(Exception e) {
            return error(l,e);
        }
    }
    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int set_localEulerAngles(IntPtr l) {
        try {
            UnityEngine.GameObject self=(UnityEngine.GameObject)checkSelf(l);
            UnityEngine.Vector3 v;
            checkType(l,2,out v);
            self.transform.localEulerAngles=v;
            pushValue(l,true);
            return 1;
        }
        catch(Exception e) {
            return error(l,e);
        }
    }
    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int get_right(IntPtr l) {
        try {
            UnityEngine.GameObject self=(UnityEngine.GameObject)checkSelf(l);
            pushValue(l,true);
            pushValue(l,self.transform.right);
            return 2;
        }
        catch(Exception e) {
            return error(l,e);
        }
    }
    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int set_right(IntPtr l) {
        try {
            UnityEngine.GameObject self=(UnityEngine.GameObject)checkSelf(l);
            UnityEngine.Vector3 v;
            checkType(l,2,out v);
            self.transform.right=v;
            pushValue(l,true);
            return 1;
        }
        catch(Exception e) {
            return error(l,e);
        }
    }
    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int get_up(IntPtr l) {
        try {
            UnityEngine.GameObject self=(UnityEngine.GameObject)checkSelf(l);
            pushValue(l,true);
            pushValue(l,self.transform.up);
            return 2;
        }
        catch(Exception e) {
            return error(l,e);
        }
    }
    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int set_up(IntPtr l) {
        try {
            UnityEngine.GameObject self=(UnityEngine.GameObject)checkSelf(l);
            UnityEngine.Vector3 v;
            checkType(l,2,out v);
            self.transform.up=v;
            pushValue(l,true);
            return 1;
        }
        catch(Exception e) {
            return error(l,e);
        }
    }
    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int get_forward(IntPtr l) {
        try {
            UnityEngine.GameObject self=(UnityEngine.GameObject)checkSelf(l);
            pushValue(l,true);
            pushValue(l,self.transform.forward);
            return 2;
        }
        catch(Exception e) {
            return error(l,e);
        }
    }
    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int set_forward(IntPtr l) {
        try {
            UnityEngine.GameObject self=(UnityEngine.GameObject)checkSelf(l);
            UnityEngine.Vector3 v;
            checkType(l,2,out v);
            self.transform.forward=v;
            pushValue(l,true);
            return 1;
        }
        catch(Exception e) {
            return error(l,e);
        }
    }
    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int get_rotation(IntPtr l) {
        try {
            UnityEngine.GameObject self=(UnityEngine.GameObject)checkSelf(l);
            pushValue(l,true);
            pushValue(l,self.transform.rotation);
            return 2;
        }
        catch(Exception e) {
            return error(l,e);
        }
    }
    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int set_rotation(IntPtr l) {
        try {
            UnityEngine.GameObject self=(UnityEngine.GameObject)checkSelf(l);
            UnityEngine.Quaternion v;
            checkType(l,2,out v);
            self.transform.rotation=v;
            pushValue(l,true);
            return 1;
        }
        catch(Exception e) {
            return error(l,e);
        }
    }
    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int get_localRotation(IntPtr l) {
        try {
            UnityEngine.GameObject self=(UnityEngine.GameObject)checkSelf(l);
            pushValue(l,true);
            pushValue(l,self.transform.localRotation);
            return 2;
        }
        catch(Exception e) {
            return error(l,e);
        }
    }
    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int set_localRotation(IntPtr l) {
        try {
            UnityEngine.GameObject self=(UnityEngine.GameObject)checkSelf(l);
            UnityEngine.Quaternion v;
            checkType(l,2,out v);
            self.transform.localRotation=v;
            pushValue(l,true);
            return 1;
        }
        catch(Exception e) {
            return error(l,e);
        }
    }
    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int get_localScale(IntPtr l) {
        try {
            UnityEngine.GameObject self=(UnityEngine.GameObject)checkSelf(l);
            pushValue(l,true);
            pushValue(l,self.transform.localScale);
            return 2;
        }
        catch(Exception e) {
            return error(l,e);
        }
    }
    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int set_localScale(IntPtr l) {
        try {
            UnityEngine.GameObject self=(UnityEngine.GameObject)checkSelf(l);
            UnityEngine.Vector3 v;
            checkType(l,2,out v);
            self.transform.localScale=v;
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
            UnityEngine.GameObject self=(UnityEngine.GameObject)checkSelf(l);
            pushValue(l,true);
            pushValue(l,self.transform.parent == null? null : self.transform.parent.gameObject);
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
            UnityEngine.GameObject self=(UnityEngine.GameObject)checkSelf(l);
            UnityEngine.GameObject v;
            checkType(l,2,out v);
            self.transform.parent=v.transform;
            pushValue(l,true);
            return 1;
        }
        catch(Exception e) {
            return error(l,e);
        }
    }
    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int get_worldToLocalMatrix(IntPtr l) {
        try {
            UnityEngine.GameObject self=(UnityEngine.GameObject)checkSelf(l);
            pushValue(l,true);
            pushValue(l,self.transform.worldToLocalMatrix);
            return 2;
        }
        catch(Exception e) {
            return error(l,e);
        }
    }
    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int get_localToWorldMatrix(IntPtr l) {
        try {
            UnityEngine.GameObject self=(UnityEngine.GameObject)checkSelf(l);
            pushValue(l,true);
            pushValue(l,self.transform.localToWorldMatrix);
            return 2;
        }
        catch(Exception e) {
            return error(l,e);
        }
    }
    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int get_root(IntPtr l) {
        try {
            UnityEngine.GameObject self=(UnityEngine.GameObject)checkSelf(l);
            pushValue(l,true);
            pushValue(l,self.transform.root == null ? null : self.transform.root.gameObject);
            return 2;
        }
        catch(Exception e) {
            return error(l,e);
        }
    }
    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int get_childCount(IntPtr l) {
        try {
            UnityEngine.GameObject self=(UnityEngine.GameObject)checkSelf(l);
            pushValue(l,true);
            pushValue(l,self.transform.childCount);
            return 2;
        }
        catch(Exception e) {
            return error(l,e);
        }
    }
    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int get_lossyScale(IntPtr l) {
        try {
            UnityEngine.GameObject self=(UnityEngine.GameObject)checkSelf(l);
            pushValue(l,true);
            pushValue(l,self.transform.lossyScale);
            return 2;
        }
        catch(Exception e) {
            return error(l,e);
        }
    }
    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int get_hasChanged(IntPtr l) {
        try {
            UnityEngine.GameObject self=(UnityEngine.GameObject)checkSelf(l);
            pushValue(l,true);
            pushValue(l,self.transform.hasChanged);
            return 2;
        }
        catch(Exception e) {
            return error(l,e);
        }
    }
    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int set_hasChanged(IntPtr l) {
        try {
            UnityEngine.GameObject self=(UnityEngine.GameObject)checkSelf(l);
            bool v;
            checkType(l,2,out v);
            self.transform.hasChanged=v;
            pushValue(l,true);
            return 1;
        }
        catch(Exception e) {
            return error(l,e);
        }
    }
    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int get_layerName(IntPtr l) {
        try {
            UnityEngine.GameObject self=(UnityEngine.GameObject)checkSelf(l);
            string layer_name = LayerMask.LayerToName(self.layer);
            pushValue(l,true);
            pushValue(l,layer_name);
            return 2;
        }
        catch(Exception e) {
            return error(l,e);
        }
    }
    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int set_layerName(IntPtr l) {
        try {
            UnityEngine.GameObject self=(UnityEngine.GameObject)checkSelf(l);
            string v;
            checkType(l,2,out v);
            self.layer = LayerMask.NameToLayer(v);
            pushValue(l,true);
            return 1;
        }
        catch(Exception e) {
            return error(l,e);
        }
    }
}
