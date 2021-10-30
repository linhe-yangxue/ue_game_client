// Copyright (c) 2017 (weiwei)

using UnityEngine;
using UnityEditor;
using System.Collections.Generic;
using System.Reflection;

public class EditorBase : Editor {
    public const bool kIsDev = false;
    #region Private Details
    protected class PropertyData {
        public System.Type property_type_;
        public SerializedProperty property_;
        public SerializedProperty dependent_property_;
        public string nice_name_;
        public ToolTipsAttribute tooltip_;
        public PropertyData(System.Type property_type, SerializedProperty property, SerializedProperty dependent_property, ToolTipsAttribute tooltip) {
            property_type_ = property_type;
            property_ = property;
            dependent_property_ = dependent_property;
            tooltip_ = tooltip != null ? tooltip : new ToolTipsAttribute(null);
            if (tooltip_.AliasName != null) {
                nice_name_ = tooltip_.AliasName;
            } else {
                // Fancy reg-ex to insert spaces between lower and upper case letters while preserving acronyms.
                nice_name_ = ObjectNames.NicifyVariableName(property.name);
                nice_name_ = char.ToUpper(nice_name_[0]) + nice_name_.Substring(1);
            }
        }
    }

    private List<PropertyData> _properties_ = new List<PropertyData>(64);
    private Dictionary<string, PropertyData> _property_table_ = new Dictionary<string, PropertyData>(64);
    private SerializedObject _my_serialized_object_ = null;
    #endregion // Private Details

    #region Unity Interface
    public virtual void OnEnable() {
        _ExtraceProperties();
    }

    public override void OnInspectorGUI() {
        _my_serialized_object_.Update();
        for (int i = 0; i < _properties_.Count; ++i) {
            _DrawProperty(_properties_[i]);
        }
        _my_serialized_object_.ApplyModifiedProperties();
    }
    #endregion // Unity Interface

    #region Private Functions Defines
    private bool _ShouldDraw(PropertyData property, bool force_draw = false) {
        if (property.tooltip_.OverrideDefaultDraw && !force_draw) {
            return false;
        }
        if (property.tooltip_.DevOnly && !kIsDev) {
            return false;
        } else if (property.dependent_property_ != null) {
            switch(property.dependent_property_.propertyType) {
            case SerializedPropertyType.ObjectReference:
                return property.dependent_property_.objectReferenceValue != null;
            case SerializedPropertyType.Boolean:
                return property.dependent_property_.boolValue;
            case SerializedPropertyType.Integer:
                return property.dependent_property_.intValue != 0;
            }

            if (property.dependent_property_.isArray) {
                return property.dependent_property_.arraySize > 0;
            }
        }
        return true;
    }
    protected bool _DrawProperty(PropertyData property, bool force_draw = false) {
        if (!_ShouldDraw(property, force_draw)) {
            return false;
        }
        bool ret = false;
        GUIContent label = new GUIContent(property.nice_name_, property.tooltip_.TipText);
        // 设置下一个焦点控制名字，可通过GetNameOfFocusedControl() == Name来判断是否在焦点
        GUI.SetNextControlName(property.nice_name_ + "_Control");
        if (property.tooltip_.EnumType != null && property.property_.propertyType == SerializedPropertyType.Enum) {
            System.Enum enum_value = System.Enum.ToObject(property.tooltip_.EnumType, property.property_.intValue) as System.Enum;
            int new_value = System.Convert.ToInt32(EditorGUILayout.EnumFlagsField(label, enum_value));
            if (property.property_.intValue != new_value) {
                property.property_.intValue = new_value;
                ret = true;
            }
        } else if (property.tooltip_.HasRange && property.property_.propertyType == SerializedPropertyType.Integer) {
            if (property.tooltip_.Max > property.tooltip_.Min) {
                int old_value  = property.property_.intValue;
                EditorGUILayout.IntSlider(property.property_, (int)property.tooltip_.Min, (int)property.tooltip_.Max, label);
                if (property.property_.intValue != old_value) {
                    property.property_.intValue = Mathf.Clamp(property.property_.intValue, (int)property.tooltip_.Min, (int)property.tooltip_.Max);
                    ret = true;
                }
            } else {
                int new_value = EditorGUILayout.IntField(label, property.property_.intValue);
                if (property.property_.intValue != new_value) {
                    property.property_.intValue = Mathf.Max((int)property.tooltip_.Min, new_value);
                    ret = true;
                }
            }
        } else if (property.tooltip_.HasRange && property.property_.propertyType == SerializedPropertyType.Float) {
            if (property.tooltip_.Max > property.tooltip_.Min) {
                float old_value = property.property_.floatValue;
                EditorGUILayout.Slider(property.property_, property.tooltip_.Min, property.tooltip_.Max, label);
                if (property.property_.floatValue != old_value) {
                    property.property_.floatValue = Mathf.Clamp(property.property_.floatValue, property.tooltip_.Min, property.tooltip_.Max);
                    ret = true;
                }
            } else {
                float new_value = EditorGUILayout.FloatField(label, property.property_.floatValue);
                if (new_value != property.property_.floatValue) {
                    property.property_.floatValue = Mathf.Max(property.tooltip_.Min, new_value);
                    ret = true;
                }
            }
        } else if (property.tooltip_.IsSceneObjectOverride && property.property_.propertyType == SerializedPropertyType.ObjectReference) {
            Object new_value = EditorGUILayout.ObjectField(label, property.property_.objectReferenceValue, property.property_type_, property.tooltip_.AllowSceneObjects);
            if (property.property_.objectReferenceValue != new_value) {
                property.property_.objectReferenceValue = new_value;
                ret = true;
            }
        } else if (property.tooltip_.TreatAsLayer && property.property_.propertyType == SerializedPropertyType.Integer) {
            int new_value = EditorGUILayout.LayerField(label, property.property_.intValue);
            if (new_value != property.property_.intValue) {
                property.property_.intValue = new_value;
                ret = true;
            }
        } else if (property.property_.propertyType == SerializedPropertyType.Color) {
            // HDR Color Picker
            var old_color = property.property_.colorValue;
            var new_color = EditorGUILayout.ColorField(new GUIContent(label), old_color, true, true, true);
            if (new_color != old_color) {
                property.property_.colorValue = new_color;
                ret = true;
            }
        //} else if (property.property_.propertyType == SerializedPropertyType.Gradient) {
        //    // HDR Gradient编辑器，有bug，待查
        //    using (new GUILayout.HorizontalScope()) {
        //        ret = EditorGUILayout.PropertyField(property.property_, label, true);
        //        Debug.LogWarning("aaa:" + EditorGUIUtility.hotControl);
        //        var field = typeof(SerializedProperty).GetProperty("gradientValue", BindingFlags.NonPublic | BindingFlags.Instance);
        //        var gradient = field.GetValue(property.property_, null);
        //        System.Type type = null;
        //        foreach (var assembly in System.AppDomain.CurrentDomain.GetAssemblies()) {
        //            type = assembly.GetType("UnityEditor.GradientPicker");
        //            if (type != null) break;
        //        }

        //        if (GUILayout.Button("HDR", GUILayout.Width(50))) {
        //            var method = type.GetMethod("Show", new System.Type[] { typeof(Gradient), typeof(bool) });
        //            method.Invoke(null, new object[] { gradient, true });
        //            //var editor = EditorWindow.GetWindow(type);
        //            //Debug.LogWarning("editor:" + editor);
        //            //Debug.LogWarning("Init" + type.GetMethod("Init", BindingFlags.NonPublic | BindingFlags.Instance));
        //            //type.GetMethod("Init", BindingFlags.NonPublic | BindingFlags.Instance)
        //            //    .Invoke(editor, new object[] { gradient, true });
        //        }
        //        //if (type.GetProperty("gradient").GetValue(null, null) == gradient) {
        //        //    Debug.LogWarning("aaa");
        //        //    field.SetValue(property.property_, type.GetProperty("gradient").GetValue(null, null), null);
        //        //    ret = true;
        //        //}

        //        //var editor = EditorWindow.GetWindow(type);
        //        //Debug.LogWarning("editor:"+editor);
        //        //var a = type.GetMethod("obj_address", BindingFlags.NonPublic | BindingFlags.Instance)
        //        //    .Invoke(editor, new object[]{});
        //        //Debug.LogWarning(a);
        //        //Debug.LogWarning(type.GetProperty("gradient").GetValue(null, null));
        //        //Debug.LogWarning(editor);

        //    }
        } else {
            ret = EditorGUILayout.PropertyField(property.property_, label, true);
        }
        return ret;
    }

    private void _ExtraceProperties() {
        _properties_.Clear();
        _property_table_.Clear();

        Object target_object;
        if (serializedObject != null) {
            _my_serialized_object_ = serializedObject;
            target_object = target;
        } else {
            return;
        }

        FieldInfo[] fields = target_object.GetType().GetFields(BindingFlags.Instance | BindingFlags.Public | BindingFlags.NonPublic);
        foreach(FieldInfo field in fields) {
            if ((field.Attributes & (FieldAttributes.NotSerialized | FieldAttributes.Static)) == 0) {
                if (!field.IsPublic) {
                    object[] serialize = field.GetCustomAttributes(typeof(SerializeField), true);
                    if (serialize == null || serialize.Length <= 0) {
                        continue;
                    }
                }

                object[] hide = field.GetCustomAttributes(typeof(HideInInspector), true);
                if (hide != null && hide.Length > 0) {
                    continue;
                }

                SerializedProperty dependent_property = null;
                ToolTipsAttribute tooltip = null;
                object[] tooltips = field.GetCustomAttributes(typeof(ToolTipsAttribute), true);
                if (tooltips.Length > 0) {
                    tooltip = (ToolTipsAttribute)tooltips[0];
                    if (!string.IsNullOrEmpty(tooltip.DependentProperty)) {
                        dependent_property = _my_serialized_object_.FindProperty(tooltip.DependentProperty);
                    }
                }
                PropertyData new_property = new PropertyData(field.FieldType, _my_serialized_object_.FindProperty(field.Name), dependent_property, tooltip);
                _properties_.Add(new_property);
                _property_table_.Add(field.Name, new_property);
            }
        }
    }
    #endregion  // Private Functions Defines

    #region Interface for Derived Classes
    protected T ObjectField<T>(string field_name, string tooltip, Object target_object, bool allow_scene_objects) where T : Object {
        GUI.SetNextControlName(field_name + "_Control");
        return (T)EditorGUILayout.ObjectField(new GUIContent(field_name, tooltip), target_object, typeof(T), allow_scene_objects);
    }

    protected void DrawProperty(string property_name) {
        PropertyData property;
        if (_property_table_.TryGetValue(property_name, out property)) {
            _DrawProperty(property);
        }
    }

    protected PropertyData GetProperty(string property_name) {
        PropertyData property = null;
        if (_property_table_.TryGetValue(property_name, out property)) {
            return property;
        }
        return null;
    }
    #endregion // Interface for Derived Classes
}
