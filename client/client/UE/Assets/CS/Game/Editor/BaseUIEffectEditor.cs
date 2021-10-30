using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(BaseUIAnimEffect),true)]
public class BaseUIEffectEditor : Editor
{
    BaseUIAnimEffect _ui_anim_effect_;

    public void OnEnable()
    {
        _ui_anim_effect_ = target as BaseUIAnimEffect;
    }

    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();

        if(!_ui_anim_effect_.is_running_)
        {
            EditorApplication.update -= Update;
        }
        if (GUILayout.Button("运行"))
        {
            if (_ui_anim_effect_.is_running_)
            {
                Debug.Log("正在运行，无法再次运行");
                return;
            }
            _ui_anim_effect_.gameObject.SetActive(true);
            _ui_anim_effect_.StartEditorRun(DisableObj);
            _ui_anim_effect_.OnEnable();
            EditorApplication.update += Update;
        }
        if (GUILayout.Button("停止"))
        {
            Stop();
        }
        if (GUILayout.Button("保存"))
        {
            Stop();
            _ui_anim_effect_.ClearObj();
            GameObject source = PrefabUtility.GetCorrespondingObjectFromSource(_ui_anim_effect_.gameObject) as GameObject;
            if (source == null) return;
            PrefabUtility.ReplacePrefab(_ui_anim_effect_.gameObject, source);
        }

        if (GUILayout.Button("清除"))
        {
            _ui_anim_effect_.gameObject.SetActive(false);
            _ui_anim_effect_.OnDisable();
            _ui_anim_effect_.ClearObj();
            EditorApplication.update = null;
        }
    }

    public void Stop()
    {
        if (!_ui_anim_effect_.is_running_)
        {
            return;
        }
        DisableObj();
    }
    
    private void DisableObj()
    {
        _ui_anim_effect_.gameObject.SetActive(false);
        _ui_anim_effect_.OnDisable();
        EditorApplication.update -= Update;
    }

    public void Update()
    {
        _ui_anim_effect_.Update();
    }
}
