using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UIAnimTurnBack : UIAnimBase
{
    // 翻牌动画
    public Vector3 target_euler_;
    public Vector3 start_euler_;
    public AnimationCurve curve_;
    public GameObject back_image_;

    public override void OnEnable()
    {
        base.OnEnable();
        back_image_.SetActive(true);
        transform.eulerAngles = start_euler_;
    }

    public override void UpdateAnim(float process)
    {
        base.UpdateAnim(process);
        transform.eulerAngles = Vector3.Lerp(start_euler_, target_euler_, curve_.Evaluate(process));
        if (back_image_ !=null && transform.eulerAngles.y < 90)
        {
            back_image_.SetActive(false);
        }
    }
}
