using SLua;
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using Spine.Unity;

public class SkeletonGraphicGhost : MonoBehaviour
{
    Mesh mesh_;
    Texture tex_;

    Color color1_, color2_;
    float time_, curent_time_;
    Material material_;

    void LateUpdate()
    {
        if (mesh_ != null)
        {
            curent_time_ += Time.deltaTime;
            Color color = Color.Lerp(color1_, color2_, curent_time_ / time_);
            if (curent_time_ > time_)
            {
                GameObject.Destroy(mesh_);
                GameObject.Destroy(gameObject);
            }
            material_.SetColor("_Color", color);
        }
    }

    static public GameObject CreateSkeletonGraphicGhost(GameObject go, GameObject target_obj, float time, Color color1, Color color2, float scale)
    {
        var obj = new GameObject("SkeletonGraphicGhost");
        var trans = obj.transform;
        trans.SetParent(go.transform.parent);
        trans.SetSiblingIndex(go.transform.GetSiblingIndex());
        trans.position = target_obj.transform.position;
        trans.rotation = target_obj.transform.rotation;
        trans.localScale = target_obj.transform.localScale * scale;

        var mesh_renderer = obj.AddComponent<MeshRenderer>();
        var mesh_filter = obj.AddComponent<MeshFilter>();

        var old_mesh = target_obj.GetComponent<MeshFilter>().mesh;
        var new_mesh = new Mesh();
        new_mesh.vertices = old_mesh.vertices;
        new_mesh.uv = old_mesh.uv;

        //new_mesh.colors = old_mesh.colors;  默认白色
        new_mesh.triangles = old_mesh.triangles;
        Material material = target_obj.GetComponent<MeshRenderer>().material;

        mesh_filter.mesh = new_mesh;
        mesh_renderer.material = material;

        var ghost = obj.AddComponent<SkeletonGraphicGhost>();
        ghost.mesh_ = new_mesh;
        ghost.color1_ = color1;
        ghost.color2_ = color2;
        ghost.time_ = time;
        ghost.curent_time_ = 0;
        ghost.material_ = mesh_renderer.material;
        return obj;
    }
}
