using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.EventSystems;

public class UIPassEvent : MonoBehaviour, IPointerDownHandler, IPointerUpHandler, IPointerEnterHandler, IPointerExitHandler, IPointerClickHandler
{
    private bool is_pass_ = false;

    public void OnPointerDown(PointerEventData event_data)
    {
        PassEvent(event_data, ExecuteEvents.pointerDownHandler);
    }

    public void OnPointerUp(PointerEventData event_data)
    {
        PassEvent(event_data, ExecuteEvents.pointerUpHandler);
    }

    public void OnPointerEnter(PointerEventData event_data)
    {
        PassEvent(event_data, ExecuteEvents.pointerEnterHandler);
    }

    public void OnPointerExit(PointerEventData event_data)
    {
        PassEvent(event_data, ExecuteEvents.pointerExitHandler);
    }

    public void OnPointerClick(PointerEventData event_data)
    {
        PassEvent(event_data, ExecuteEvents.pointerClickHandler);
    }

    public void PassEvent<T>(PointerEventData event_data, ExecuteEvents.EventFunction<T> function) where T : IEventSystemHandler
    {
        if(is_pass_)return;
        is_pass_ = true;
        List<RaycastResult> results = new List<RaycastResult>();
        EventSystem.current.RaycastAll(event_data, results);
        GameObject current = event_data.pointerCurrentRaycast.gameObject;
        if (results.Count >= 2)
        {
            GameObject go = results[1].gameObject;
            _PassEvent(go, event_data, function);
        }
        is_pass_ = false;
    }

    void _PassEvent<T>(GameObject go, PointerEventData event_data, ExecuteEvents.EventFunction<T> function) where T : IEventSystemHandler
    {
        Button btn_comp = go.GetComponent<Button>();
        if (btn_comp != null && btn_comp.enabled)
        {
            ExecuteEvents.Execute(go, event_data, function);
        }
        else if (go.transform.parent != null)
        {
            _PassEvent(go.transform.parent.gameObject, event_data, function);
        }
    }
}
