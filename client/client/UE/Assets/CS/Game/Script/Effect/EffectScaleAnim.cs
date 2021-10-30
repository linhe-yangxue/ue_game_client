
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[AddComponentMenu("Game/Effect/Scale Anim")]
public class EffectScaleAnim : EffectAnimBase {
    public Vector3 start_scale_ = Vector3.one;
    public Vector3 end_scale_ = Vector3.one * 2;

    Vector3 base_sacle;

    void Awake() {
        base_sacle = transform.localScale;
    }

    public override void SetAnim(float time, float process) {
        Vector3 new_scale = Vector3.Lerp(start_scale_, end_scale_, process);
        transform.localScale = Vector3.Scale(base_sacle, new_scale);
    }
}
