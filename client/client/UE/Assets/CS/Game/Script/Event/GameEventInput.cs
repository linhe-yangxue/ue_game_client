using UnityEngine;
using UnityEngine.UI;
using System.Collections.Generic;
using UnityEngine.EventSystems;

public class GameEventInput : Singleton<GameEventInput> {
    GameEventMgr _event_mgr_ = null;

    static public bool IsPositionOnUI(Vector3 position) {
        PointerEventData eventDataCurrentPosition = new PointerEventData(EventSystem.current);
        eventDataCurrentPosition.position = position;
        List<RaycastResult> results = new List<RaycastResult>();
        EventSystem.current.RaycastAll(eventDataCurrentPosition, results);
        return results.Count > 0;
    }
    static public bool IsTouchOnUI(Touch touch) {
        return EventSystem.current.IsPointerOverGameObject(touch.fingerId);
    }


	// Use this for initialization
	void Start () {
        _event_mgr_ = GameEventMgr.GetInstance();
	}

    protected override void OnDisable() {
        base.OnDisable();
    }
	
    void OnApplicationFocus(bool focus_status) {
        if (_event_mgr_ == null) {
            return;
        }
        _event_mgr_.GenerateEvent(GameEventMgr.ET_ApplicationFocus, null, focus_status);
    }
}

