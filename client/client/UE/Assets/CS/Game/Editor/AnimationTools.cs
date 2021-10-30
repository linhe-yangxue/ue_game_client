using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;
using UnityEditor;
using System.IO;
using LT;
using System.Reflection;

class AnimationTools {

    // curve ==================================================================
    static public void CopyAnimationCurve(AnimationCurve scr, AnimationCurve dst) {
        dst.keys = scr.keys;
        dst.postWrapMode = scr.postWrapMode;
        dst.preWrapMode = scr.preWrapMode;
    }

    static public LTable ExportCurveToLua(AnimationCurve curve, bool is_one_line = false) {
        var t_curve = new LTable(is_one_line);
        t_curve["preWrapMode"] = new LNum((int)curve.preWrapMode);
        t_curve["postWrapMode"] = new LNum((int)curve.postWrapMode);
        var t_keys = new LTable(is_one_line);
        var keys = curve.keys;
        for (int i = 0; i < keys.Length;++i){
            var t_key = new LTable(true);
            t_key["time"] = new LNum(keys[i].time);
            t_key["value"] = new LNum(keys[i].value);
            t_key["inTangent"] = new LNum(keys[i].inTangent);
            t_key["outTangent"] = new LNum(keys[i].outTangent);
            t_key["tangentMode"] = new LNum(keys[i].tangentMode);
            t_keys[i + 1] = t_key;
        }
        t_curve["keys"] = t_keys;
        return t_curve;
    }

    static public List<AnimationCurve> GetCurvesInClip(AnimationClip clip, string path, string property) {
        List<AnimationCurve> list = new List<AnimationCurve>();
        foreach (var binding in AnimationUtility.GetCurveBindings(clip)) {
            if (binding.path == path && binding.propertyName.StartsWith(property)) {
                list.Add(AnimationUtility.GetEditorCurve(clip, binding));
            }
        }
        return list;
    }
    static public List<AnimationCurve> GetEditorCurvesInClip(AnimationClip clip, string path, string property) {
        List<AnimationCurve> list = new List<AnimationCurve>();
        var s_obj = new SerializedObject(clip);
        var s_prop = s_obj.FindProperty("m_EulerEditorCurves");
        for (int i = 0; i < s_prop.arraySize; ++i) {
            var binding = s_prop.GetArrayElementAtIndex(i);
            if (binding.FindPropertyRelative("path").stringValue == path &&
                binding.FindPropertyRelative("attribute").stringValue.StartsWith(property)) {
                list.Add(binding.FindPropertyRelative("curve").animationCurveValue);
            }
        }
        return list;
    }

    static public List<AnimationCurve> GetPositionCurvesInClip(AnimationClip clip, string path) {
        return AnimationTools.GetCurvesInClip(clip, path, "m_LocalPosition.");
    }
    static public List<AnimationCurve> GetRotationCurvesInClip(AnimationClip clip, string path) {
        return AnimationTools.GetCurvesInClip(clip, path, "m_LocalRotation.");
    }
    static public List<AnimationCurve> GetEditorRotationCurvesInClip(AnimationClip clip, string path) {
        return AnimationTools.GetEditorCurvesInClip(clip, path, "localEulerAnglesBaked.");
    }
    static public List<AnimationCurve> GetAutoRotationCurvesInClip(AnimationClip clip, string path) {
        var list = AnimationTools.GetEditorRotationCurvesInClip(clip, path);
        if (list.Count >= 3) return list;
        list = AnimationTools.GetRotationCurvesInClip(clip, path);
        return list;
    }

    static float Evaluate(float t, Keyframe k0, Keyframe k1) {
        float dt = k1.time - k0.time;

        float m0 = k0.outTangent * dt;
        float m1 = k1.inTangent * dt;

        float t2 = t * t;
        float t3 = t2 * t;

        float a = 2 * t3 - 3 * t2 + 1;
        float b = t3 - 2 * t2 + t;
        float c = t3 - t2;
        float d = -2 * t3 + 3 * t2;

        return a * k0.value + b * m0 + c * m1 + d * k1.value;
    }

    // sample ==================================================================
#if UNITY_EDITOR
    static public void SampleEffect(GameObject obj, float time) {
        Transform trans = obj.transform;
        trans.gameObject.SetActive(true);
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
        foreach (var effect_anim in trans.GetComponentsInChildren<EffectAnimBase>()) {
            if (effect_anim.enabled && effect_anim.auto_play_) {
                effect_anim.SetTime(time);
                effect_anim.Stop();
            }
        }
    }

    static public void SampleUnit(GameObject obj, string anim_name, float time) {
        Transform trans = obj.transform;
        var animator = trans.Find("model").GetComponent<Animator>();
        var controller = animator.runtimeAnimatorController;
        foreach( var anim in controller.animationClips) {
            if (anim.name == anim_name) {
                if (anim.isLooping || anim.wrapMode == WrapMode.Loop) {
                    AnimationMode.SampleAnimationClip(animator.gameObject, anim, time % anim.length);
                } else {
                    AnimationMode.SampleAnimationClip(animator.gameObject, anim, time);
                }
            }
        }
    }
    #endif

}
