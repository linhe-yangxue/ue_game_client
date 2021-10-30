// Copyright (c) 2017 (weiwei)

using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class MenuBase {

    protected static GameObject _CreateGameObject(string name) {
        GameObject new_go = new GameObject(name);
        if (SceneView.lastActiveSceneView != null && SceneView.lastActiveSceneView.camera != null) {
            Camera cam = SceneView.lastActiveSceneView.camera;
            RaycastHit hit;
            if (Physics.Raycast(cam.transform.position, cam.transform.forward, out hit)) {
                new_go.transform.position = hit.point;
            } else {
                Plane ground_plane = new Plane(Vector3.up, Vector3.zero);
                float hit_pct;
                if (ground_plane.Raycast(new Ray(cam.transform.position, cam.transform.forward), out hit_pct)) {
                    new_go.transform.position = cam.transform.position + cam.transform.forward * hit_pct;
                }
            }
        }
        return new_go;
    }
}
