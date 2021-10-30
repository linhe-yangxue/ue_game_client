using Tweening;
using UnityEngine;


public class UITweenAlpha : UITweenBase {

    public float from_;
    public float to_;
    private CanvasGroup canvas_group_;

    CanvasGroup GetCanvasGroup()
    {
        if (canvas_group_ == null)
        {
            canvas_group_ = gameObject.GetComponent<CanvasGroup>();
            if (canvas_group_ == null)
            {
                canvas_group_ = gameObject.AddComponent<CanvasGroup>();
            }
        }
        return canvas_group_;
    }

    Tweener GetTweener()
    {
        if (tweener_ == null)
        {
            CanvasGroup canvas_group = GetCanvasGroup();
            tweener_ =  canvas_group.DOFade(to_, duration_).SetDelay(delay_time_).SetEase(ease_type_).SetLoops(loops_, loop_type_).SetAutoKill(is_auto_kill_).Pause();
        }
        else
        {
            if (is_auto_kill_)
            {
                tweener_.Kill();
                CanvasGroup canvas_group = GetCanvasGroup();
                tweener_ = canvas_group.DOFade(to_, duration_).SetDelay(delay_time_).SetEase(ease_type_).SetLoops(loops_, loop_type_).SetAutoKill(is_auto_kill_).Pause();
            }
        }
        return tweener_;
    }

    public override void Play()
    {
        CanvasGroup canvas_group = GetCanvasGroup();
        canvas_group.alpha = from_;
        GetTweener().Restart();
    }
}
