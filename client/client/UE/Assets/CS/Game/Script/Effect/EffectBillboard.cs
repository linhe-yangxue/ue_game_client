using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[AddComponentMenu("Game/Effect/Billboard")]
public class EffectBillboard : MonoBehaviour {
    public Vector3 offset_ = Vector3.zero;

    void Update() {
        Quaternion rot = Quaternion.LookRotation(Camera.main.transform.rotation * Vector3.back, Vector3.up);
        rot = rot* Quaternion.Euler(offset_);
        transform.rotation = rot;
    }
}
