using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EffectAnimBase : MonoBehaviour {
    public float time_ = 1;
    public float start_time_ = 0;
    public bool is_loop_ = true;
    public float loop_start_ = 0;
    public bool auto_play_ = true;
    public bool use_unscale_time = false;
    public AnimationCurve process_ = new AnimationCurve(new Keyframe(0, 0, 0, 1), new Keyframe(1, 1, 1, 0));

    [System.NonSerialized]
    public bool is_play_ = false;
    [System.NonSerialized]
    public float cur_time_ = 0;
    [System.NonSerialized]
    public float speed_ = 1;

	// Use this for initialization
	void OnEnable () {
        if (auto_play_) Play();
	}
    void OnDisable () {
        if (is_play_) Stop();
	}
    public virtual void Play() {
        is_play_ = true;
        cur_time_ = start_time_;
        UpdateAnim(0);
    }
    public virtual void Stop() {
        is_play_ = false;
    }
    public void SetSpeed(float speed) {
        speed_ = speed;
    }
    public float GetSpeed() {
        return speed_;
    }

	// Update is called once per frame
    void Update() {
        if (use_unscale_time) {
            UpdateAnim(Time.unscaledDeltaTime * speed_);
        } else {
            UpdateAnim(Time.deltaTime * speed_);
        }
    }
    void UpdateAnim(float delta_time) {
        if (is_play_) {
            SetTime(cur_time_ + delta_time);
        }
    }
    public void SetTime(float time) {
        cur_time_ = time;
        if (is_loop_) {
            if (cur_time_ > loop_start_) {
                cur_time_ = (cur_time_ - loop_start_) % (time_ - loop_start_) + loop_start_;
            }
        } else {
            if (cur_time_ > time_) {
                is_play_ = false;
                cur_time_ = time_;
            }
        }
        SetAnim(cur_time_, process_.Evaluate(cur_time_ / time_));
    }
    public virtual void SetAnim(float time, float process) {
    }

}
