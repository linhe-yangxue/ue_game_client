using System;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.EventSystems;
using System.Collections.Generic;

public class UIEventTrigger : MonoBehaviour, IPointerDownHandler, IPointerUpHandler, IPointerEnterHandler, IPointerExitHandler,IPointerClickHandler
{
    public float long_press_threshold_ = 1.0f;

    public delegate void DefaultTriggerFunc();
    public delegate void PressEventTriggerFunc(Vector2 pos);
    public delegate void ReleaseEventTriggerFunc(string go_name);
    public delegate void ClickEventTriggerFunc(int click_count);

    PressEventTriggerFunc OnPressFunc = null;
    ReleaseEventTriggerFunc OnReleaseFunc = null;
    DefaultTriggerFunc OnEnterFunc = null;
    DefaultTriggerFunc OnExitFunc = null;

    DefaultTriggerFunc OnLongPressFunc = null;
    ClickEventTriggerFunc OnPointerClickFunc = null;
    private bool _press_flag;
    private bool _long_press_flag;
    private float _press_time;
    private bool _press_on_go;

    void Awake()
    {
        _press_flag = false;
        _long_press_flag = false;
        _press_time = 0;
        _press_on_go = false;
    }

    void Update()
    {
        if (_press_flag && _press_on_go)
        {
            _press_time += Time.deltaTime;
            if (_press_time >= long_press_threshold_ && !_long_press_flag)
            {
                _long_press_flag = true;
                if (OnLongPressFunc != null)
                {
                    OnLongPressFunc();
                }
            }
        }
    }


    public void SetPressFunc(PressEventTriggerFunc func)
    {
        OnPressFunc = func;
    }

    public void SetReleasFunc(ReleaseEventTriggerFunc func)
    {
        OnReleaseFunc = func;
    }

    public void SetEnterFunc(DefaultTriggerFunc func)
    {
        OnEnterFunc = func;
    }

    public void SetExitFunc(DefaultTriggerFunc func)
    {
        OnExitFunc = func;
    }

    public void SetPointerClickFunc(ClickEventTriggerFunc func)
    {
        OnPointerClickFunc = func;
    }


    public void SetLongPressFunc(DefaultTriggerFunc func)
    {
        OnLongPressFunc = func;
    }

    public void OnPointerDown(PointerEventData event_data)
    {
        if (OnPressFunc != null)
        {
            OnPressFunc(event_data.pressPosition);
        }
        if(OnLongPressFunc != null)
        {
            _press_flag = true;
            _long_press_flag = false;
            _press_time = 0;
        }
    }

    public void OnPointerUp(PointerEventData event_data)
    {
        _press_flag = false;
        if (OnReleaseFunc != null)
        {
            if (event_data.pointerEnter != null)
            {
                OnReleaseFunc(event_data.pointerEnter.name);
            }
            else
            {
                OnReleaseFunc("");
            }
        }
    }

    public void OnPointerEnter(PointerEventData event_data)
    {
        _press_on_go = true;
        if (OnEnterFunc != null)
        {
            OnEnterFunc();
        }
    }

    public void OnPointerExit(PointerEventData event_data)
    {
        _press_on_go = false;
        _press_time = 0;
        if (OnExitFunc != null)
        {
            OnExitFunc();
        }
    }

    public void OnPointerClick(PointerEventData event_data)
    {
       if(OnPointerClickFunc != null)
        {
            OnPointerClickFunc(event_data.clickCount);
        }
    }
}
