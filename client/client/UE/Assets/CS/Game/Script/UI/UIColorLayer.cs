using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class UIColorLayer : Graphic {
    public Slider slider_;
	public bool is_vertical = false;
	private Color[] colors_ = new Color[0];
	private Vector2 rect_size_;

    protected override void Awake() {
        rect_size_ = GetPixelAdjustedRect().size;
    }

	protected override void OnPopulateMesh(VertexHelper vh)
    {
        rect_size_ = GetPixelAdjustedRect().size;
        vh.Clear();
        if (is_vertical)
        {
            DrawVerticalColor(vh);
        }
        else
        {
            DrawHorizontalColor(vh);
        }
    }

	private void DrawVerticalColor(VertexHelper vh)
    {
        int count = colors_.Length;
        float offset = rect_size_.y / (count - 1);
        Vector2 top_left_pos = new Vector2(-rect_size_.x / 2.0f, rect_size_.y / 2.0f);
        Vector2 top_right_pos = new Vector2(rect_size_.x / 2.0f, rect_size_.y / 2.0f);
        Vector2 bottom_left_pos = top_left_pos - new Vector2(0, offset);
        Vector2 bottom_right_pos = top_right_pos - new Vector2(0, offset);
        for (int i = 0; i < count - 1; i++)
        {
            Color startColor = colors_[i];
            Color endColor = colors_[i + 1];
            var v1 = GetUIVertex(top_left_pos, startColor);
            var v2 = GetUIVertex(top_right_pos, startColor);
            var v3 = GetUIVertex(bottom_right_pos, endColor);
            var v4 = GetUIVertex(bottom_left_pos, endColor);
            vh.AddUIVertexQuad(new UIVertex[] { v1, v2, v3, v4 });
            top_left_pos = bottom_left_pos;
            top_right_pos = bottom_right_pos;
            bottom_left_pos = top_left_pos - new Vector2(0, offset);
            bottom_right_pos = top_right_pos - new Vector2(0, offset);
        }
    }

    private void DrawHorizontalColor(VertexHelper vh)
    {
        int count = colors_.Length;
        float offset = rect_size_.x / (count - 1);
        Vector2 top_left_pos = new Vector2(-rect_size_.x / 2.0f, rect_size_.y / 2.0f);
        Vector2 top_right_pos = top_left_pos + new Vector2(offset, 0);
        Vector2 bottom_left_pos = top_left_pos - new Vector2(0, rect_size_.y);
        Vector2 bottom_right_pos = bottom_left_pos + new Vector2(offset, 0);
        for (int i = 0; i < count - 1; i++)
        {
            Color startColor = colors_[i];
            Color endColor = colors_[i + 1];
            var v1 = GetUIVertex(top_left_pos, startColor);
            var v2 = GetUIVertex(top_right_pos, endColor);
            var v3 = GetUIVertex(bottom_right_pos, endColor);
            var v4 = GetUIVertex(bottom_left_pos, startColor);
            vh.AddUIVertexQuad(new UIVertex[] { v1, v2, v3, v4 });
            top_left_pos = top_right_pos;
            top_right_pos = top_left_pos + new Vector2(offset, 0);
            bottom_left_pos = bottom_right_pos;
            bottom_right_pos = bottom_left_pos + new Vector2(offset, 0);
        }
    }

    private UIVertex GetUIVertex(Vector2 point, Color color0)
    {
        UIVertex vertex = new UIVertex
        {
            position = point,
            color = color0,
        };
        return vertex;
    }

    public void SetColor(Color[] colors)
    {
        colors_ = colors;
        SetVerticesDirty();
    }
    public virtual Color GetColor()
    {
        int count = colors_.Length;
        if(is_vertical){
            var dist = rect_size_.y / (count - 1);
            var offset = -rect_size_.y * slider_.value;
            var index = (int)(offset / dist);
            var per = offset % dist / dist;
            if (offset >= rect_size_.y)
            {
                index--;
                per++;
            }
            Color start = colors_[index];
            Color end = colors_[index + 1];
            return start * (1 - per) + end * per;
        }else{
            var dist = rect_size_.x / (count -1);
            var offset = rect_size_.x * slider_.value;
            int index = (int)(offset / dist);
            var per = offset % dist / dist;
            if (offset >= rect_size_.x)
            {
                index--;
                per++;
            }
            Color start = colors_[index];
            Color end = colors_[index + 1];
            return start * (1 - per) + end * per;
        }
    }
}
