// Copyright (c) 2017 (weiwei)

using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public static class UndoUtil {
    public static void Record(Object undo_obj, string undo_str) {
        Undo.RecordObject(undo_obj, undo_str);
    }
    public static void Created(Object undo_obj, string undo_str) {
        Undo.RegisterCreatedObjectUndo(undo_obj, undo_str);
    }
    public static void Destroy(GameObject undo_go, string undo_str) {
        Undo.DestroyObjectImmediate(undo_go);
    }
    public static void Parent(GameObject parent, GameObject child, string undo_str) {
        Undo.SetTransformParent(child.transform, parent.transform, undo_str);
    }
}
