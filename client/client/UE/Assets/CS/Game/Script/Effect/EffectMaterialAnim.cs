using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[AddComponentMenu("Game/Effect/Material Anim")]
public class EffectMaterialAnim : EffectMaterialAnimBase {
    public string param_name_ = "_Process";
    public float start_float_ = 0;
    public float end_float_ = 1;

    public override void SetAnim(float time, float process) {
        var value = Mathf.Lerp(start_float_, end_float_, process);
        foreach (var mat in GetMats()) {
            mat.SetFloat(param_name_, value);
        }
    }
}
