using System.Collections.Generic;

#if UNITY_EDITOR 
using UnityEditor;
#endif
using UnityEngine;

public class BaseUIAnimEffect : MonoBehaviour
{
    public delegate void NormalDele();

    [HideInInspector]
    public bool is_running_ = false;

    private List<GameObject> _list_;
    private NormalDele _end_call_back_;
    float _last_update_time_;
    float _delta_time_;

    public T CreateObj<T>(GameObject init_ui_obj)
    {
        if (_list_ == null)
        {
            _list_ = new List<GameObject>();
        }
        GameObject obj = GameObject.Instantiate(init_ui_obj, transform);
        _list_.Add(obj);
        return obj.GetComponent<T>();
    }

    public void ClearObj()
    {
        if (_list_ == null)
        {
            return;
        }
        foreach (var item in _list_)
        {
            GameObject.DestroyImmediate(item);
        }
        _list_.Clear();
        ClearAllObj();
    }

    public void StartEditorRun(NormalDele call_back)
    {
        SetIsRunning(true);
        _end_call_back_ = call_back;
    }

    public void StopEditorRun()
    {
#if UNITY_EDITOR
        SetIsRunning(false);
        if (_end_call_back_ != null)
        {
            _end_call_back_();
        }
#endif
    }

    public virtual void Update()
    {
#if UNITY_EDITOR
        float current_time = (float)EditorApplication.timeSinceStartup;
        _delta_time_ = current_time - _last_update_time_;
        _last_update_time_ = current_time;
#endif
    }

    public virtual void OnEnable()
    {

    }

    public virtual void OnDisable()
    {

    }

    public virtual void ClearAllObj()
    {

    }

    public void SetIsRunning(bool val)
    {
        is_running_ = val;
    }

    public void DestroyGo(GameObject obj)
    {
#if UNITY_EDITOR
        if(Application.isPlaying)
        {
            GameObject.Destroy(obj);
        }
        else
        {
            GameObject.DestroyImmediate(obj);
        }
        return;
#endif 
        GameObject.Destroy(obj);
    }

    public float deltaTime
    {
        get
        {
#if UNITY_EDITOR
            if (Application.isPlaying)
            {
                return Time.deltaTime;
            }
            else
            {
                return _delta_time_;
            }
#endif
            return Time.deltaTime;
        }
    }
}
