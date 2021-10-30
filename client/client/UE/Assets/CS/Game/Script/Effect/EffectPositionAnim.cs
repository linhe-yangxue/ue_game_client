
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[AddComponentMenu("Game/Effect/Position Anim")]
public class EffectPositionAnim : EffectAnimBase {
    public Vector3 start_posotion_ = Vector3.zero;
    public Vector3 end_posotion_ = new Vector3(1, 0, 0);

    Vector3 last_pos = Vector3.zero;

    public override void SetAnim(float time, float process) {
        Vector3 new_pos = Vector3.Lerp(start_posotion_, end_posotion_, process);
        transform.localPosition += new_pos - last_pos;
        last_pos = new_pos;
    }
}
