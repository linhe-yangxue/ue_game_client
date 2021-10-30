using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[AddComponentMenu("Game/Effect/Rotation Anim")]
public class EffectRotationAnim : EffectAnimBase {
    public Vector3 start_rotation_ = Vector3.zero;
    public Vector3 end_rotation_ = new Vector3(0, 360, 0);

    void Awake() {
    }
    public override void SetAnim(float time, float process) {
        transform.localRotation = Quaternion.Euler(Vector3.Lerp(start_rotation_, end_rotation_, process));
    }
}
