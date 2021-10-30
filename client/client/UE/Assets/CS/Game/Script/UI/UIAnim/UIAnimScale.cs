using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UIAnimScale : UIAnimBase {

    public Vector3 start_scale_;
    public Vector3 end_scale_;
    public AnimationCurve curve_ = new AnimationCurve(new Keyframe(0, 0, 0, 1), new Keyframe(1, 1, 1, 0));

    public override void UpdateAnim(float process)
    {
        Vector3 value = Vector3.Lerp(start_scale_, end_scale_, curve_.Evaluate(process));
        rect_.localScale = value;
    }
}
