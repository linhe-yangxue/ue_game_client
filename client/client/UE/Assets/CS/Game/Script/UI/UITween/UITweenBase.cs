using UnityEngine;
using Tweening;

public abstract class UITweenBase : MonoBehaviour {
    public bool is_auto_play_ = true;
    public bool is_auto_kill_ = true;
    public float duration_ = 0.2f;
    public float delay_time_ = 0;
    public int loops_ = 1;
    public Ease ease_type_ = Ease.Linear;
    public LoopType loop_type_;
    private RectTransform _rect_;
    protected Tweener tweener_;
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

    void OnEnable()
    {
        if (is_auto_play_)
        {
            Play();
        }
    }

    void OnDisable()
    {
        if (tweener_ != null)
        {
            tweener_.Kill();
            tweener_ = null;
        }
    }

    void OnDestroy()
    {
        if (tweener_ != null){
            tweener_.Kill();
            tweener_ = null;
        }
    }

    public float GetDurationTime()
    {
        return duration_;
    }

    public void SetDurationTime(float duration)
    {
        duration_ = duration;
    }

    public float GetDelayTime()
    {
        return delay_time_;
    }

    public void SetDelayTime(float delay_time)
    {
        delay_time_ = delay_time;
    }

    public abstract void Play();

}
