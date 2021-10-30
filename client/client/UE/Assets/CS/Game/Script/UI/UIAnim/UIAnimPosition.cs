using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UIAnimPosition : UIAnimBase
{
    public Vector3 start_pos_;
    public Vector3 end_pos_;
    public AnimationCurve curve_ = new AnimationCurve(new Keyframe(0, 0, 0, 1), new Keyframe(1, 1, 1, 0));
    public float arc_height_ = 0;
    [Range(0.1f, 0.9f)] public float arc_pct_;

    private Vector2 anim_dir_;
    private Vector2 arc_dir_;

    public override void OnEnable()
    {
        CalcDir();
        base.OnEnable();
    } 

    public override void UpdateAnim(float process)
    {
        Vector3 value = Vector3.Lerp(start_pos_, end_pos_, curve_.Evaluate(process));
        Vector2 arc_offset = Vector2.zero;
		float height = Mathf.Abs(arc_height_);
		float factor = 0;
		if (process > arc_pct_)
		{
			factor = (1 - process) / (1 - arc_pct_);
		}
		else
		{
			factor = process / arc_pct_;
		}

		if (arc_height_ < 0) {
			arc_offset = arc_dir_ * height * Mathf.Sin(factor * Mathf.PI * 0.5f);
			arc_offset = -arc_offset;
		}
        rect_.anchoredPosition3D = value + new Vector3(arc_offset.x, arc_offset.y, 0);
    }

    public void SetStartPos(Vector3 pos){
        start_pos_ = pos;
        CalcDir();
    }

    public void SetEndPos(Vector3 pos){
        end_pos_ = pos;
        CalcDir();
    }

    private void CalcDir(){
        anim_dir_ = end_pos_ - start_pos_;
        arc_dir_ = Quaternion.AngleAxis(90, Vector3.back) * anim_dir_;
        arc_dir_.Normalize();
    }
}
