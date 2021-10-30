using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class GameEditorGUI {
    static public void CorrectColorSpace() {
        if (PlayerSettings.colorSpace == ColorSpace.Linear) {
            GL.sRGBWrite = true;
        }
    }
    static public void RestoreColorSpace() {
        GL.sRGBWrite = false;
    }

    static public void DrawTexture(Rect position, Texture image, ScaleMode scaleMode = ScaleMode.StretchToFill, bool alphaBlend = true, float imageAspect = 1) {
        CorrectColorSpace();
        GUI.DrawTexture(position, image, scaleMode, alphaBlend, imageAspect);
        RestoreColorSpace();
    }

    static public void DrawMaterial(Rect rect, Material mat, int pass = -1) {
        CorrectColorSpace();
        var pos = rect.position;
        var size = rect.size;
        var matrix = Matrix4x4.TRS(
            new Vector3(pos.x, pos.y, 1),
            Quaternion.identity,
            new Vector3(size.x, size.y, 1));
        Mesh mesh = MeshUtil.GetRectMesh();
        mat.SetPass(0);
        Graphics.DrawMeshNow(mesh, matrix);
        RestoreColorSpace();
    }
}
