using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

[AddComponentMenu("Game/Effect/EffectDelayKill")]
public class EffectDelayKill : EffectMaterialAnimBase {
    public bool fade_ = false;
    public string param_name_ = "_Color";
    public bool change_ui_color_ = true;

    Renderer renderer_;
    Graphic graphic_;
    bool is_org_enable_;
    Color org_color_;
    bool is_killing_;

    public bool destroy_go_ = false;

    EffectDelayKill():base() {
        is_loop_ = false;
        auto_play_ = false;
    }
    void Awake() {
        renderer_ = GetComponent<Renderer>();
        graphic_ = GetComponent<Graphic>();
        is_loop_ = false;
        auto_play_ = false;
    }
    public override void Play() {
        base.Play();
        is_killing_ = true;
    }

    public void Reset() {
        if (is_killing_) {
            Stop();
            _SetEnable(is_org_enable_);
            _SetColor(org_color_);
            is_killing_ = false;
        }
    }

    public override void SetAnim(float time, float process) {
        if (time == 0 || process <= 0) {
            is_org_enable_ = _GetEnable();
            org_color_ = _GetColor();
        } else if (time >= base.time_ || process >= 1) {
            _SetEnable(false);
            _SetColor(org_color_);
            if (destroy_go_) GameObject.Destroy(gameObject);
        } else if (fade_) {
            _SetColor(org_color_ * new Color(1, 1, 1, 1 - process));
        }
    }

    void _SetEnable(bool enable) {
        if (renderer_ != null) renderer_.enabled = enable;
        if (graphic_ != null) graphic_.enabled = enable;
    }

    bool _GetEnable() {
        if (renderer_ != null) return renderer_.enabled;
        if (graphic_ != null) return graphic_.enabled;
        return true;
    }

    void _SetColor(Color color) {
        if (change_ui_color_) {
            if(graphic_ != null){
                graphic_.color = color;
            }
        } else {
            foreach (var mat in GetMats()) {
                mat.SetColor(param_name_, color);
            }
        }
    }

    Color _GetColor() {
        if (change_ui_color_) {
            if (graphic_ != null)
            {
                return graphic_.color;
            }
        } else {
            foreach (var mat in GetMats()) {
                return mat.GetColor(param_name_);
            }
        }
        return Color.white;
    }

}

