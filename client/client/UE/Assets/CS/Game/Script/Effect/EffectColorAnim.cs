using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

[AddComponentMenu("Game/Effect/Color Anim")]
public class EffectColorAnim : EffectMaterialAnimBase {
    public string param_name_ = "_Color";
    public Gradient color_ = new Gradient();
    public bool use_hdr_ = false;
    public Color hdr_color_mult_ = Color.white;
    public float hdr_alpha_mult_ = 1;
    public bool change_ui_color_ = true;
    Graphic graphic_;

    public override void Play() {
        if (change_ui_color_) graphic_ = GetComponent<Graphic>();
        base.Play();
    }

    public override void SetAnim(float time, float process) {
        var color = color_.Evaluate(process);
        if (use_hdr_) {
            color *= hdr_color_mult_;
            color.a *= hdr_alpha_mult_;
        }
        if (graphic_ != null) {
            graphic_.color = color;
        } else {
            foreach (var mat in GetMats()) {
                mat.SetColor(param_name_, color);
            }
        }
    }
}
