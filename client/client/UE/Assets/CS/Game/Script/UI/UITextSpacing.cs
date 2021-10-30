using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

[RequireComponent(typeof(Text))]
[DisallowMultipleComponent]
[ExecuteInEditMode]
public class UITextSpacing : BaseMeshEffect {
    public float spacing = 0;

    Text text_cmp;
    List<UILineInfo> line_info_list = new List<UILineInfo>();
    const int kCharVertexCount = 4;
    protected override void OnEnable()
    {
        base.OnEnable();
        text_cmp = GetComponent<Text>();
    }
    public override void ModifyMesh(VertexHelper vh)
    {
        if (!this.isActiveAndEnabled||vh.currentVertCount == 0) return;
        var t_cached_gen = text_cmp.cachedTextGenerator;
        line_info_list.Clear();
        t_cached_gen.GetLines(line_info_list);
        for (int i = 0; i < line_info_list.Count; ++i){
            int start_char_index = line_info_list[i].startCharIdx;
            int end_char_index;
            if(i + 1 < line_info_list.Count) {
                end_char_index = line_info_list[i + 1].startCharIdx - 1;
            }
            else end_char_index = (int)(vh.currentVertCount / kCharVertexCount) - 1;
            AdjustLineCharactersSpacing(start_char_index, end_char_index, vh);
        }
    }
    void AdjustLineCharactersSpacing(int start_char_idx, int end_char_idx, VertexHelper vh)
    {
        int center_char_idx;
        if(text_cmp.alignment == TextAnchor.LowerLeft || text_cmp.alignment == TextAnchor.MiddleLeft ||
            text_cmp.alignment == TextAnchor.UpperLeft) {
            center_char_idx = start_char_idx;
        }
        else if (text_cmp.alignment == TextAnchor.LowerCenter || text_cmp.alignment == TextAnchor.MiddleCenter ||
            text_cmp.alignment == TextAnchor.UpperCenter){
            center_char_idx = (int)((start_char_idx + end_char_idx) * 0.5f);
        }
        else{
            center_char_idx = end_char_idx;
        }
        UIVertex ui_v = new UIVertex();
        for (int char_idx = start_char_idx; char_idx <= end_char_idx; ++char_idx) {
            float cur_spacing = (char_idx - center_char_idx) * spacing;
            for(int i = 0; i < kCharVertexCount; ++i) {
                int cur_v_idx = char_idx * kCharVertexCount + i;
                vh.PopulateUIVertex(ref ui_v, cur_v_idx);
                ui_v.position += new Vector3(cur_spacing, 0, 0);
                vh.SetUIVertex(ui_v, cur_v_idx);
            }
        }
    }
#if UNITY_EDITOR
    protected override void OnValidate()
    {
        base.graphic.SetVerticesDirty();
    }
#endif
}
