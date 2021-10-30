using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(CanvasGroup))]
public class UIAnimAlpha : UIAnimBase
{
    public AnimationCurve curve_ = new AnimationCurve(new Keyframe(0, 0, 0, 1), new Keyframe(1, 1, 1, 0));

    private CanvasGroup cavas_group_;


    public override void OnEnable()
    {
        cavas_group_ = GetComponent<CanvasGroup>();
        base.OnEnable();
    }

    public override void UpdateAnim(float process)
    {
        cavas_group_.alpha = curve_.Evaluate(process);
    }
}
