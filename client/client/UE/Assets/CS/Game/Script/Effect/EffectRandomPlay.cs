using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[AddComponentMenu("Game/Effect/Effect Random Play")]
public class EffectRandomPlay : EffectAnimBase {
    public float min_time = 1;
    public float max_time = 2;

    float cur_time = 0;
    float total_time = 0;
    Dictionary<GameObject, float> actived_objs_ = new Dictionary<GameObject, float>();
    List<GameObject> remove_list = new List<GameObject>();

    public override void Play() {
        base.Play();
        _OnLoop(false);
    }

    void Update() {
        if (is_play_) {
            var delta_time = Time.deltaTime * speed_;
            while (delta_time > 0) {
                if (cur_time + delta_time >= total_time) {
                    delta_time -= total_time - cur_time;
                    _OnLoop(true);
                    if (!is_loop_) {
                        Stop();
                        break;
                    }
                } else {
                    cur_time += delta_time;
                    delta_time = 0;
                }
            }
        }
        if (actived_objs_.Count > 0) {
            var time = Time.time;
            foreach (var kv in actived_objs_) {
                if (time >= kv.Value) {
                    remove_list.Add(kv.Key);
                }
            }
            if (remove_list.Count > 0) {
                foreach (var obj in remove_list) {
                    obj.SetActive(false);
                    actived_objs_.Remove(obj);
                }
                remove_list.Clear();
            }
        }
    }
    void _OnLoop(bool active) {
        cur_time = 0;
        total_time = Random.Range(min_time, max_time);
        if (active) {
            var child_count = transform.childCount;
            var rand = Random.Range(0, child_count);
            var obj = transform.GetChild(rand).gameObject;
            obj.SetActive(true);
            actived_objs_[obj] = Time.time + time_ / speed_;
        }
    }

}
