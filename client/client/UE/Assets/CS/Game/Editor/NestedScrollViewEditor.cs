using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(NestedScrollView))]
public class NestedScrollViewEditor : UnityEditor.UI.ScrollRectEditor
{
    SerializedProperty parent_scroll;
    protected override void OnEnable()
    {
        base.OnEnable();
        parent_scroll = serializedObject.FindProperty("parent_scroll");
    }
    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();
        EditorGUILayout.PropertyField(parent_scroll);
        serializedObject.ApplyModifiedProperties();
    }
}
