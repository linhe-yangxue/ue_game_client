using System.Collections;
using System.Collections.Generic;
using UnityEngine.Events;
using UnityEngine;

public class UIAnimBase : MonoBehaviour
{
    [System.Serializable]
    public class TriggerEvent : UnityEvent { }
    [SerializeField]
    public TriggerEvent OnTriggerEvent = new TriggerEvent();
    public float time_;
    public float repeat_count = 1;

    private float cur_time_;
    private float cur_count_ = 0;
    private bool is_finish_ = false;
    private RectTransform _rect_;
    public RectTransform rect_
    {
        get
        {
            if (_rect_ == null)
            {
                _rect_ = GetComponent<RectTransform>();
            }
            return _rect_;
        }
    }

    public virtual void OnEnable()
    {
        cur_time_ = 0;
        cur_count_ = 0;
        is_finish_ = false;
        UpdateAnim(0);
    }

    void Update()
    {
        if (is_finish_) return;
        cur_time_ = cur_time_ + Time.deltaTime;
        if (cur_time_ >= time_)
        {
            cur_count_++;
            if (repeat_count != 0 && cur_count_ >= repeat_count)
            {
                is_finish_ = true;
                OnTriggerEvent.Invoke();
                enabled = false;
            }
            else
            {
                cur_time_ = 0;
            }
        }
        UpdateAnim(Mathf.Clamp01(cur_time_ / time_));
    }

    public virtual void UpdateAnim(float process)
    {

    }
}
