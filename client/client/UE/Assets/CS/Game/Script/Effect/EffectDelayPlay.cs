using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[AddComponentMenu("Game/Effect/EffectDelayPlay")]
public class EffectDelayPlay : MonoBehaviour {
    [ToolTips("延迟播放的时间，单位是秒", 0.0f, 10.0f, "延迟播放的时间")]
    public float delay_time_ = 1;

    void Start() {
        gameObject.SetActive(false);
        Invoke("DelayFunc", delay_time_);
    }

    void DelayFunc() {
        gameObject.SetActive(true);
    }
}
