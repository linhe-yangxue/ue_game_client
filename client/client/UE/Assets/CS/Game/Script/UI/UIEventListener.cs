using UnityEngine;
using UnityEngine.Events;
using UnityEngine.EventSystems;

public class UIEventListener : MonoBehaviour, IDragHandler, IPointerClickHandler{

    public delegate void EventDelegate(GameObject go);
    public EventDelegate onClick;
    public EventDelegate onDrag;


    public void OnPointerClick(PointerEventData event_data)
    {
        if (onClick != null) onClick(gameObject);
    }

    public void OnDrag(PointerEventData event_data)
    {
        if (onDrag != null) onDrag(gameObject);
    }

    public void ClearAll()
    {
        onClick = null;
        onDrag = null;
    }
}
