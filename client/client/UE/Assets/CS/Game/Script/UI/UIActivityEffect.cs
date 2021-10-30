using SLua;
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UIActivityEffect : MonoBehaviour {

    [DoNotToLua]
    public float btn_scale_value_ = 2.3f;
    [DoNotToLua]
    public float reduce_speed_ = 5;
    [DoNotToLua]
    public float moveY_speed_ = 0.15f;

    [DoNotToLua]
    public float item_scale_total_time_ = 0.4f;

    private bool start_effect_ = false;
    private bool btn_effect_ = true;
    private bool item_scale_effect_ = true;
    private bool item_moveY_effect_ = true;
    private bool item_recover_scale_effect_ = true;
    private bool only_btn_scale_ = false;

    private float btn_scale_limite_ = 1;
    private float item_scale_limite_ = 0.85f;
    private float item_scale_time_;

    private Transform target_;
    private Transform item_content;
    private Transform target_content;

    public delegate void ActivityEffectFinishDelegate(string name);
    public ActivityEffectFinishDelegate OnActivityEffectFinish;

    public void InitActivtyEffect(string name, bool only_btn_scale)
    {
        if (name != "")
        {
            target_ = transform.parent.Find(name);
            if (target_ == null) throw new Exception(string.Format("can't find gameObject {0} in {1}", name, gameObject));
            target_content = target_.Find("Content");
        }
        start_effect_ = true;
        item_scale_time_ = item_scale_total_time_;
        item_content = transform.Find("Content");
        only_btn_scale_ = only_btn_scale;
    }

    void Update()
    {
        if ( start_effect_ )
        {
            if ( btn_effect_ )
            {
                btn_scale_value_ = btn_scale_value_ - 0.1f;
                item_content.Find("RemindFinish").transform.localScale = new Vector3(btn_scale_value_, btn_scale_value_, btn_scale_value_);
                if (btn_scale_value_ <= btn_scale_limite_)
                {
                    btn_effect_ = false;
                    if (only_btn_scale_)
                    {
                        if (OnActivityEffectFinish != null)
                        {
                            OnActivityEffectFinish(transform.name);
                        }
                    }
                }
                return;
            }
            if (only_btn_scale_)
            {
                return;
            }
            if (item_scale_effect_ || item_moveY_effect_)
            {
                if (item_scale_effect_)
                {
                    float temp_time = item_scale_time_ / item_scale_total_time_;
                    float scale_value = Mathf.Lerp(1, item_scale_limite_, temp_time);
                    item_content.localScale = new Vector3(scale_value, scale_value, scale_value);
                    if (scale_value == item_scale_limite_)
                    {
                        item_scale_time_ = item_scale_total_time_;
                        item_scale_effect_ = false;
                    }
                    item_scale_time_ = item_scale_time_ - Time.deltaTime;
                }
                if (item_moveY_effect_)
                {
                    float pos_y = item_content.position.y - moveY_speed_;
                    if (pos_y > target_content.position.y)
                    {
                        item_content.position = new Vector3(item_content.position.x, pos_y, item_content.position.z);
                        Vector2 size_delta = transform.GetComponent<RectTransform>().sizeDelta;
                        float y = size_delta.y - reduce_speed_;
                        if (y > 0)
                        {
                            transform.GetComponent<RectTransform>().sizeDelta = new Vector2(size_delta.x, y);
                        }
                        else
                        {
                            transform.GetComponent<RectTransform>().sizeDelta = new Vector2(size_delta.x, 0);
                        }
                    }
                    else
                    {
                        Vector2 size_delta = transform.GetComponent<RectTransform>().sizeDelta;
                        transform.GetComponent<RectTransform>().sizeDelta = new Vector2(size_delta.x, 0);
                        item_content.position = target_content.position;
                        item_content.gameObject.SetActive(false);
                        target_content.gameObject.SetActive(true);
                        item_moveY_effect_ = false;
                    }
                }
                return;
            }
            if (item_recover_scale_effect_)
            {
                float temp_time = item_scale_time_ / item_scale_total_time_;
                float scale_value = Mathf.Lerp(1, item_scale_limite_, temp_time);
                target_content.localScale = new Vector3(scale_value, scale_value, scale_value);
                if (scale_value == 1)
                {
                    start_effect_ = false;
                    item_recover_scale_effect_ = false;
                    if (OnActivityEffectFinish != null)
                    {
                        OnActivityEffectFinish(transform.name);
                    }
                }
                item_scale_time_ = item_scale_time_ - Time.deltaTime;
            }
        }
    }
}
