using UnityEngine;
using UnityEngine.UI;
using System.Collections.Generic;

public class UIPolygon : Graphic
{
    [Range(3, 10)]
    public int sides_;
    [Range(0, 360)]
    public int rot_;
    private float radius_;
    private List<float> cur_list;
    private List<float> target_list;
    private bool is_play_anim_ = false;

    private float cur_time_;
    private const float ANIM_TIME = 0.2f;

    public void SetValue(List<float> list, bool is_anim = true)
    {
        target_list = list;
        sides_ = target_list.Count;
        is_play_anim_ = is_anim;
        if (is_anim)
        {
            cur_list = new List<float>();
            for(int i=0; i < target_list.Count; i++)
            {
                cur_list.Add(0);
            }
            cur_time_ = 0;
        }
        else
        {
            cur_list = target_list;
        }
        SetVerticesDirty();
    }

    void Update()
    {
        if (is_play_anim_)
        {
            
            cur_time_ = cur_time_ + Time.deltaTime;
            if(cur_time_  >= ANIM_TIME)
            {
                is_play_anim_ = false;
            }
            float percent = is_play_anim_ ? cur_time_ / ANIM_TIME : 1;
            for (int i = 0; i < cur_list.Count; ++i)
            {
                cur_list[i] = target_list[i] * percent;
            }
            SetVerticesDirty();
        }
    }

    protected override void OnPopulateMesh(VertexHelper vh)
    {
        radius_ = GetComponent<RectTransform>().rect.width * 0.5f;
        vh.Clear();
        vh.AddVert(new Vector2(0, 0), color, Vector2.zero);
        float delta_angle = 360 / sides_;
        for (int i = 0; i < sides_; i++)
        {
            var radian = Mathf.PI / 180 * (delta_angle * i + rot_);
            if(cur_list != null && i < cur_list.Count)
            {
                float value = radius_ * cur_list[i];
                vh.AddVert(new Vector2(value * Mathf.Cos(radian), value * Mathf.Sin(radian)), color, Vector2.zero);
            }
            else
            {
                vh.AddVert(new Vector2(radius_ * Mathf.Cos(radian), radius_ * Mathf.Sin(radian)), color, Vector2.zero);
            }
        }
        for(int i=1; i <= sides_; i++)
        {
            if(i == sides_)
            {
                vh.AddTriangle(0, i, 1);
            }
            else
            {
                vh.AddTriangle(0, i, i+1);
            }
        }
    }
}