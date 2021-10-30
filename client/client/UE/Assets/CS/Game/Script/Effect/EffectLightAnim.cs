using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[AddComponentMenu("Game/Effect/Light Anim")]
public class EffectLightAnim : EffectAnimBase {
    public Gradient color_ = new Gradient();
    public AnimationCurve light_ = new AnimationCurve(new Keyframe[] { new Keyframe(0, 1), new Keyframe(1, 1) });

	void OnDisable () {
        GameEventMgr.GetInstance().GenerateEvent(GameEventMgr.ET_EffectEvent, "LightAnim", GetInstanceID(), null);
    }

    public override void SetAnim(float time, float process) {
        var color = color_.Evaluate(process);
        var light = light_.Evaluate(process);
		color.r = color.r * light;
		color.g = color.g * light;
		color.b = color.b * light;
        GameEventMgr.GetInstance().GenerateEvent(GameEventMgr.ET_EffectEvent, "LightAnim", GetInstanceID(), color);
    }
}
