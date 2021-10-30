using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class EffectMaterialAnimBase : EffectAnimBase {
    public int material_id_ = -1;
    Material[] materials_;

    public Material[] GetMats() {
        if (materials_ == null) {
#if UNITY_EDITOR
            if (!UnityEditor.EditorApplication.isPlaying) {
                var renderer = GetComponent<Renderer>();
                if (renderer) {
                    var share_mat = GetComponent<Renderer>().sharedMaterials;
                    var new_mat = new List<Material>();
                    if (material_id_ < 0) {
                        for (int i = 0; i < share_mat.Length; ++i) {
                            if (UnityEditor.AssetDatabase.Contains(share_mat[i])) {
                                share_mat[i] = new Material(share_mat[i]);
                            }
                            new_mat.Add(share_mat[i]);
                        }
                        renderer.sharedMaterials = share_mat;
                    } else {
                        if (UnityEditor.AssetDatabase.Contains(share_mat[material_id_])) {
                            share_mat[material_id_] = new Material(share_mat[material_id_]);
                        }
                        new_mat.Add(share_mat[material_id_]);
                    }
                    materials_ = new_mat.ToArray();
                    renderer.sharedMaterials = share_mat;
                } else {
                    var graphic = GetComponent<Graphic>();
                    var mat = new Material(graphic.material);
                    graphic.material = mat;
                    materials_ = new Material[] { mat };
                }
            }
            else
#endif
            {
                var renderer = GetComponent<Renderer>();
                if (renderer) {
                    if (material_id_ < 0) {
                        materials_ = renderer.materials;
                    } else {
                        materials_ = new Material[] { renderer.materials[material_id_] };
                    }
                } else {
                    var graphic = GetComponent<Graphic>();
                    var mat = new Material(graphic.material);
                    graphic.material = mat;
                    materials_ = new Material[] { mat };
                }
            }
        }
        return materials_;
    }
}
