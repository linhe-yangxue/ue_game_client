using System;
using UnityEngine;
using UnityEngine.EventSystems;

public class UIDragEventTrigger : MonoBehaviour, IDragHandler, IBeginDragHandler, IEndDragHandler{

    public delegate void DragEventTriggerFunc(Vector2 delta, Vector2 pos);

    DragEventTriggerFunc OnDragFunc = null;
    DragEventTriggerFunc OnBeginDragFunc = null;
    DragEventTriggerFunc OnEndDragFunc = null;

    public void SetDragFunc(DragEventTriggerFunc func)
    {
        OnDragFunc = func;
    }
    public void SetBeginDragFunc(DragEventTriggerFunc func)
    {
        OnBeginDragFunc = func;
    }
    public void SetEndDragFunc(DragEventTriggerFunc func)
    {
        OnEndDragFunc = func;
    }

    public void OnDrag(PointerEventData event_data)
    {
        if (OnDragFunc != null)
        {
            OnDragFunc(event_data.delta, event_data.position);
        }
    }

    public void OnBeginDrag(PointerEventData event_data)
    {
        if (OnBeginDragFunc != null)
        {
            OnBeginDragFunc(event_data.delta, event_data.position);
        }
    }

    public void OnEndDrag(PointerEventData event_data)
    {
        if (OnEndDragFunc != null)
        {
            OnEndDragFunc(event_data.delta, event_data.position);
        }
    }
}
