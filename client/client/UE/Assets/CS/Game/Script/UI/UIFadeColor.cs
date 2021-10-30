using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

[RequireComponent(typeof(Graphic))]
[DisallowMultipleComponent]
public class UIFadeColor : BaseMeshEffect
{
    public bool is_whole_rect = true;
    public Color start_color = new Color(0, 0, 0, 1);
    public Color end_color = new Color(1, 0, 0, 1);
    public float angle = 90;

    List<UIVertex> ui_v_list = new List<UIVertex>();
    public override void ModifyMesh(VertexHelper vh)
    {
        if (!this.isActiveAndEnabled) return;
        float rad = angle * Mathf.Deg2Rad;
        Vector2 normal_dir = new Vector2(Mathf.Cos(rad), Mathf.Sin(rad));
        ui_v_list.Clear();
        vh.GetUIVertexStream(ui_v_list);
        if (!is_whole_rect) UpdateSingleMesh(normal_dir);
        else UpdateWholeMeshRect(normal_dir);
        vh.Clear();
        vh.AddUIVertexTriangleStream(ui_v_list);
    }
    void UpdateWholeMeshRect(Vector2 normal_dir)
    {
        if (ui_v_list.Count == 0) return;
        Vector2 max_pos = ui_v_list[0].position;
        Vector2 min_pos = ui_v_list[0].position;
        foreach (var ui_v in ui_v_list)
        {
            Vector2 v_pos = ui_v.position;
            max_pos = Vector2.Max(v_pos, max_pos);
            min_pos = Vector2.Min(v_pos, min_pos);
        }
        Vector2 center_pos = (max_pos + min_pos) * 0.5f;
        float max_dist = Mathf.Abs(Vector2.Dot(max_pos - center_pos, normal_dir));
        max_dist = Mathf.Max(max_dist, Mathf.Abs(Vector2.Dot(new Vector2(min_pos.x, max_pos.y) - center_pos, normal_dir)));
        for (int i = 0; i < ui_v_list.Count; ++i)
        {
            UIVertex v = ui_v_list[i];
            Vector2 v_pos = v.position;
            float v_dist = Vector2.Dot(v_pos - center_pos, normal_dir);
            v.color = (Color32)Color.Lerp(start_color, end_color, (v_dist / max_dist + 1) * 0.5f);
            ui_v_list[i] = v;
        }
    }
    void UpdateSingleMesh(Vector2 normal_dir)
    {
        for (int i = 0; i + 2 < ui_v_list.Count; i += 3)
        {
            UIVertex v1 = ui_v_list[i], v2 = ui_v_list[i + 1], v3 = ui_v_list[i + 2];
            Vector2 v1_pos = v1.position, v2_pos = v2.position, v3_pos = v3.position;
            Vector2 min_pos = Vector2.Min(v1_pos, Vector2.Min(v2_pos, v3_pos));
            Vector2 max_pos = Vector2.Max(v1_pos, Vector2.Max(v2_pos, v3_pos));
            Vector2 center_pos = (max_pos + min_pos) * 0.5f;
            float v1_dist = Vector2.Dot(v1_pos - center_pos, normal_dir);
            float v2_dist = Vector2.Dot(v2_pos - center_pos, normal_dir);
            float v3_dist = Vector2.Dot(v3_pos - center_pos, normal_dir);
            float max_dist = Mathf.Max(Mathf.Abs(v1_dist), Mathf.Abs(v2_dist), Mathf.Abs(v3_dist));
            v1.color = (Color32)Color.Lerp(start_color, end_color, (v1_dist / max_dist + 1) * 0.5f);
            v2.color = (Color32)Color.Lerp(start_color, end_color, (v2_dist / max_dist + 1) * 0.5f);
            v3.color = (Color32)Color.Lerp(start_color, end_color, (v3_dist / max_dist + 1) * 0.5f);
            ui_v_list[i] = v1;
            ui_v_list[i + 1] = v2;
            ui_v_list[i + 2] = v3;
        }
    }
#if UNITY_EDITOR
    protected override void OnValidate()
    {
        base.graphic.SetVerticesDirty();
    }
#endif
}
