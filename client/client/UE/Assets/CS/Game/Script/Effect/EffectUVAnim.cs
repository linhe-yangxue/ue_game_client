using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

[AddComponentMenu("Game/Effect/UV Anim")]
public class EffectUVAnim : EffectMaterialAnimBase {
    public string param_name_ = "_MainTex";
    public Vector2 start_scale_ = new Vector2(1, 1);
    public Vector2 start_offset_ = new Vector2(0, 0);
    public Vector2 end_scale_ = new Vector2(1, 1);
    public Vector2 end_offset_ = new Vector2(1, 0);
    public bool support_ui_ = true;
    RawImage image_;

    public override void Play() {
        if (support_ui_) image_ = GetComponent<RawImage>();
        base.Play();
    }

    public override void SetAnim(float time, float process) {
        var offset = Vector2.Lerp(start_offset_, end_offset_, process);
        var scale = Vector2.Lerp(start_scale_, end_scale_, process);
        if (image_ != null) {
            image_.uvRect = new Rect(offset, scale);
        } else {
            foreach (var mat in GetMats()) {
                mat.SetTextureOffset(param_name_, offset);
                mat.SetTextureScale(param_name_, scale);
            }
        }
    }
}
