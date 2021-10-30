using UnityEngine;

public class EffectLine : MonoBehaviour {
    LineRenderer[] line_comps_;

    void Awake()
    {
        line_comps_ = GetComponentsInChildren<LineRenderer>(true);
        for (int i = 0; i < line_comps_.Length; i++)
        {
            line_comps_[i].useWorldSpace = true;
        }
    }

    public void SetPosition(Vector3 begin_pos, Vector3 end_pos){
        for (int i = 0; i < line_comps_.Length; i++)
        {
            LineRenderer comp = line_comps_[i];
            comp.SetPosition(0, begin_pos);
            comp.SetPosition(1, end_pos);
        }
    }
}
