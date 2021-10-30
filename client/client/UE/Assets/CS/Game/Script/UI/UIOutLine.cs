using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

[RequireComponent(typeof(Graphic))]
[DisallowMultipleComponent]
[ExecuteInEditMode]
public class UIOutLine : BaseMeshEffect {
    [ColorUsage(true, true)]
    public Color color = Color.black;
    public Vector2 offset = new Vector2(-2f,-2f);

    List<UIVertex> vertex_list = new List<UIVertex>();
    List<Vector2> offset_pos_list = new List<Vector2>();
    enum SampleQuality {Low_X8, Normal_X12, High_X18, VeryHigh_X26 }
    [SerializeField]
    SampleQuality quality = SampleQuality.Low_X8;

    protected override void OnEnable()
    {
        base.OnEnable();
        UpdateOffsetPosList();
    }
    void UpdateOffsetPosList()
    {
        int sample_cicle_count = 0;
        int sample_count = 0;
        switch (quality)
        {
            case SampleQuality.Low_X8:       { sample_cicle_count = 1; sample_count = 8;  break; }
            case SampleQuality.Normal_X12:   { sample_cicle_count = 1; sample_count = 12; break; }
            case SampleQuality.High_X18:     { sample_cicle_count = 2; sample_count = 8;  break; }
            case SampleQuality.VeryHigh_X26: { sample_cicle_count = 2; sample_count = 12;  break; }
        }
        offset_pos_list.Clear();
        int cur_sample_count = sample_count;
        for (int i = 1; i <= sample_cicle_count; i++)
        {
            var offset_pos = (offset / sample_cicle_count) * i;
            float rad_step = 2 * Mathf.PI / cur_sample_count;
            float rad = (i % 2) * rad_step * 0.5f;
            for (int j = 0; j < cur_sample_count; j++)
            {
                offset_pos_list.Add(new Vector2(offset_pos.x * Mathf.Cos(rad), offset_pos.y * Mathf.Sin(rad)));
                rad += rad_step;
            }
            cur_sample_count += 2;
        }
    }
    public override void ModifyMesh(VertexHelper vh)
    {
        if (!this.isActiveAndEnabled||vh.currentVertCount == 0) return;
        vertex_list.Clear();
        vh.GetUIVertexStream(vertex_list);
        vh.Clear();
        UpdateMeshVertexs();
        vh.AddUIVertexTriangleStream(vertex_list);
    }

    void UpdateMeshVertexs()
    {
        int need_vertex_count = vertex_list.Count * (offset_pos_list.Count + 1);
        if (vertex_list.Capacity < need_vertex_count)
            vertex_list.Capacity = need_vertex_count;
        int start_index = 0;
        int end_index = 0;
        for (int i = 0; i < offset_pos_list.Count;++i)
        {
            end_index = vertex_list.Count;
            var offset_pos = offset_pos_list[i];
            for (int k = start_index; k < end_index; ++k)
            {
                var vt = vertex_list[k];
                vertex_list.Add(vt);
                Vector3 pos = vt.position;
                pos.x += offset_pos.x;
                pos.y += offset_pos.y;
                vt.position = pos;
                Color32 newColor = color;
                newColor.a = (byte)((newColor.a * vt.color.a) / 255);
                vt.color = newColor;
                vertex_list[k] = vt;
            }
            start_index = end_index;
            end_index = vertex_list.Count;
        }
    }
#if UNITY_EDITOR
    protected override void OnValidate()
    {
        UpdateOffsetPosList();
        base.graphic.SetVerticesDirty();
    }
#endif
}
