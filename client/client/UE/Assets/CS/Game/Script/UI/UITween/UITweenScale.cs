using Tweening;
using UnityEngine;

public class UITweenScale : UITweenBase {

    public Vector3 from_;
    public Vector3 to_;

    Tweener GetTweener()
    {
        if(tweener_ == null)
        {
            tweener_ = rect_.DOScale(to_, duration_).SetDelay(delay_time_).SetEase(ease_type_).SetLoops(loops_, loop_type_).SetAutoKill(is_auto_kill_).Pause();
        }
		else
        {
            if(is_auto_kill_)
            {
                tweener_.Kill();
                tweener_ = rect_.DOScale(to_, duration_).SetDelay(delay_time_).SetEase(ease_type_).SetLoops(loops_, loop_type_).SetAutoKill(is_auto_kill_).Pause();
            }
        }
        return tweener_;
    }

    public override void Play()
    {
        rect_.localScale = from_;
        GetTweener().Restart();
    }
}
