using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

[AddComponentMenu("Game/Effect/Sprite Anim")]
public class EffectSpriteAnim : EffectMaterialAnimBase {
    public string param_name_ = "_MainTex";
    public int x_count_ = 1;
    public int y_count_ = 1;
    public bool support_ui_ = true;
    RawImage image_;

    public override void Play() {
        if (support_ui_) image_ = GetComponent<RawImage>();
        base.Play();
    }

    public override void SetAnim(float time, float process) {
        float y = Mathf.Floor(process * y_count_);
        float x = Mathf.Floor((process * y_count_ - y) * x_count_);
        var offset = new Vector2(x / x_count_, (y_count_ - y - 1) / y_count_);
        var scale = new Vector2(1.0f / x_count_, 1.0f / y_count_);
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
