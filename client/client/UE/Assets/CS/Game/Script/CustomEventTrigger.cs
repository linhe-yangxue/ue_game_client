using UnityEngine;

public class CustomEventTrigger : MonoBehaviour {

    public delegate void EventListener(string event_name);

    EventListener event_listerner_;

    public void AddListener(EventListener ls)
    {
        event_listerner_ = ls;
    }

    public void ClearListener()
    {
        event_listerner_ = null;
    }

    public void TriggerEvent(string event_name)
    {
        if (event_listerner_ != null)
        {
            event_listerner_(event_name);
        }
    }
}