using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using UnityEngine.UI;
using UnityEngine.EventSystems;

public class UIEffectScale : UIBehaviour
{
    public float default_width_;
    public float default_height_;
    private List<Vector3> scale_list_ = new List<Vector3>();
    private RectTransform rect_;

    protected override void Awake()
    {
        rect_ = GetComponent<RectTransform>();
        for (int i = 0; i < rect_.childCount; i++)
        {
            scale_list_.Add(rect_.GetChild(i).localScale);
        }
    }

    protected override void OnRectTransformDimensionsChange()
    {
        float width_rate = rect_.rect.width / default_width_;
        float height_rate = rect_.rect.height / default_height_;
        for (int i = 0; i < rect_.childCount; i++)
        {
            Vector3 scale = scale_list_[i];
            scale_list_.Add(rect_.GetChild(i).localScale);
            rect_.GetChild(i).localScale = new Vector3(scale.x * width_rate, scale.y * height_rate, scale.z);
        }
    }
}