using UnityEditor;
using UnityEngine;

[CustomPropertyDrawer(typeof(RenameAttribute))]    //用到RenameAttribute的地方都会被重绘  
public class RenameDrawer : PropertyDrawer    //PropertyDrawer为修改struct/class的外观的Editor类  
{
    public override void OnGUI(Rect position, SerializedProperty property, GUIContent label)
    {
        RenameAttribute rename = (RenameAttribute)attribute;
        label.text = rename.name;
        //重绘GUI  
        EditorGUI.PropertyField(position, property, label);
    }
}