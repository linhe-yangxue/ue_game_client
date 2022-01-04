using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using SLua;

public class GameEvent
{
    public int event_type_;
    public object event_tag_;  // tag是string,int或null，当tag为null时，在lua中会触发所有注册该事件类型的callback
    public object[] params_;  // params的类型如果是C#的类型，注意其类型必须要Export到lua中去
    public GameEvent(int event_type, object event_tag, object[] pms)
    {
        if (event_tag != null)
        {
            Type ot = event_tag.GetType();
            if (ot != typeof(int) && ot != typeof(string) && ot != typeof(double))
            {
                Debug.LogError("GameEvent的event_tag类型必须是int或者字符串");
            }
        }
        event_type_ = event_type;
        event_tag_ = event_tag;
        params_ = pms;
    }

}

public class GameEventMgr
{

    // Event Type
    public const int ET_ApplicationFocus = 3;
    public const int ET_UIOnClicked = 101;
    public const int ET_UIToggle = 102;
    public const int ET_UIPress = 103;
    public const int ET_UIRelease = 104;
    public const int ET_UIEnter = 105;
    public const int ET_UIExit = 106;
    public const int ET_UIDrag = 107;
    public const int ET_UITreeViewChange = 108;
    public const int ET_UITreeViewSelect = 109;
    public const int ET_UISwipeViewChange = 110;
    public const int ET_UISwipeViewSelect = 111;
    public const int ET_UITextPicPopulateMesh = 112;
    public const int ET_UILongPress = 113;
    public const int ET_UIPointerClick = 114;
    public const int ET_UISliderValueChange = 115;
    public const int ET_UIInputFieldValueChange = 116;
    public const int ET_UITextPicOnClickHref = 117;
    public const int ET_UIActivityEffectFinish = 118;
    public const int ET_UIChatViewUpdate = 119;
    public const int ET_UILoopListItemSelect = 120;
    public const int ET_UIDynamicListItemSelect = 121;
    public const int ET_UIDynamicListItemUpdate = 122;
    public const int ET_UIDynamicListItemRequest = 123;
    public const int ET_UISlideSelectChange = 124;
    public const int ET_UIScrollListViewChange = 125;
    public const int ET_UISlideSelectBegin = 126;
    public const int ET_UISlideSelectEnd = 127;
    public const int ET_UIScrollRectOnValueChanged = 128;
    public const int ET_UIBeginDrag = 129;
    public const int ET_UIEndDrag = 130;
    public const int ET_CustomEvent = 201;
    public const int ET_AnimEvent = 301;
    public const int ET_Resource = 401;
    public const int ET_EffectEvent = 501;
    public const int ET_Input = 701;
    public const int ET_SDK = 750;
    public const int ET_QuickSdk = 756;

    public const int ET_Trigger = 851;
    public const int ET_LuaReload = 901;


    List<GameEvent> _events_;
    static GameEventMgr _sEventMgr;

    private GameEventMgr()
    {
        AssetBundles.AssetBundleManager.OnAssetLoadOk = (AssetBundles.ABLoadOptBase opt, object asset)=>{GenerateEvent(ET_Resource, null, opt, asset);};
    }

    void _AddEvent(GameEvent ge)
    {
        if (this._events_ == null)
        {
            this._events_ = new List<GameEvent>();
        }
        this._events_.Add(ge);
    }

    static public GameEventMgr GetInstance()
    {
        if (_sEventMgr == null)
        {
            _sEventMgr = new GameEventMgr();
        }
        return _sEventMgr;
    }

    public void RegisterUIEvent(GameObject go, int event_type)
    {
        switch (event_type)
        {
            case ET_UIOnClicked:
                {
                    Button button = go.GetComponent<Button>();
                    button.onClick.AddListener(() => { GenerateEvent(ET_UIOnClicked, go.GetInstanceID()); });
                }
                break;
            case ET_UIToggle:
                {
                    Toggle toggle = go.GetComponent<Toggle>();
                    toggle.onValueChanged.AddListener((is_on) => { GenerateEvent(ET_UIToggle, go.GetInstanceID(), is_on); });
                }
                break;
            case ET_UIPress:
                {
                    UIEventTrigger trigger = go.GetComponent<UIEventTrigger>();
                    trigger.SetPressFunc((Vector2 pos) =>
                    {
                        GenerateEvent(ET_UIPress, go.GetInstanceID(), pos);
                    });
                }
                break;
            case ET_UIRelease:
                {
                    UIEventTrigger trigger = go.GetComponent<UIEventTrigger>();
                    trigger.SetReleasFunc((string go_name) =>
                    {
                        GenerateEvent(ET_UIRelease, go.GetInstanceID(), go_name);
                    });
                }
                break;
            case ET_UIEnter:
                {
                    UIEventTrigger trigger = go.GetComponent<UIEventTrigger>();
                    trigger.SetEnterFunc(() =>
                    {
                        GenerateEvent(ET_UIEnter, go.GetInstanceID());
                    });
                }
                break;
            case ET_UIExit:
                {
                    UIEventTrigger trigger = go.GetComponent<UIEventTrigger>();
                    trigger.SetExitFunc(() =>
                    {
                        GenerateEvent(ET_UIExit, go.GetInstanceID());
                    });
                }
                break;
            case ET_UIDrag:
                {
                    UIDragEventTrigger trigger = go.GetComponent<UIDragEventTrigger>();
                    trigger.SetDragFunc((Vector2 delta, Vector2 pos) =>
                    {
                        GenerateEvent(ET_UIDrag, go.GetInstanceID(), delta, pos);
                    });
                }
                break;
            case ET_UIBeginDrag:
                {
                    UIDragEventTrigger trigger = go.GetComponent<UIDragEventTrigger>();
                    trigger.SetBeginDragFunc((Vector2 delta, Vector2 pos) =>
                    {
                        GenerateEvent(ET_UIBeginDrag, go.GetInstanceID(), delta, pos);
                    });
                }
                break;
            case ET_UIEndDrag:
                {
                    UIDragEventTrigger trigger = go.GetComponent<UIDragEventTrigger>();
                    trigger.SetEndDragFunc((Vector2 delta, Vector2 pos) =>
                    {
                        GenerateEvent(ET_UIEndDrag, go.GetInstanceID(), delta, pos);
                    });
                }
                break;
            case ET_UITreeViewChange:
                {
                    UITreeView tree_view = go.GetComponent<UITreeView>();
                    tree_view.OnViewChange = (GameObject obj, UITreeNodeData data) =>
                    {
                        GenerateEvent(ET_UITreeViewChange, go.GetInstanceID(), obj, data);
                    };
                }
                break;
            case ET_UITreeViewSelect:
                {
                    UITreeView tree_view = go.GetComponent<UITreeView>();
                    tree_view.OnSelectNode = (UITreeNodeData data) =>
                    {
                        GenerateEvent(ET_UITreeViewSelect, go.GetInstanceID(), data);
                    };
                }
                break;
            case ET_UISwipeViewChange:
                {
                    UISwipeView swipe_view = go.GetComponent<UISwipeView>();
                    swipe_view.OnViewChange = (GameObject obj, int index) =>
                    {
                        GenerateEvent(ET_UISwipeViewChange, go.GetInstanceID(), obj, index);
                    };
                }
                break;
            case ET_UISwipeViewSelect:
                {
                    UISwipeView swipe_view = go.GetComponent<UISwipeView>();
                    swipe_view.OnSelectNode = (int index) =>
                    {
                        GenerateEvent(ET_UISwipeViewSelect, go.GetInstanceID(), index);
                    };
                }
                break;
            case ET_UITextPicPopulateMesh:
                {
                    TextPic text_pic = go.GetComponent<TextPic>();
                    text_pic.PopulateMeshCallBack = () =>
                    {
                        GenerateEvent(ET_UITextPicPopulateMesh, go.GetInstanceID());
                    };
                }
                break;
            case ET_UILongPress:
                {
                    UIEventTrigger long_press = go.GetComponent<UIEventTrigger>();
                    long_press.SetLongPressFunc(() =>
                    {
                        GenerateEvent(ET_UILongPress, go.GetInstanceID());
                    });
                }
                break;
            case ET_UIPointerClick:
                {
                    UIEventTrigger trigger = go.GetComponent<UIEventTrigger>();
                    trigger.SetPointerClickFunc((int click_count) =>
                    {
                        GenerateEvent(ET_UIPointerClick, go.GetInstanceID(), click_count);
                    });
                }
                break;
            case ET_UISliderValueChange:
                {
                    Slider slider = go.GetComponent<Slider>();
                    slider.onValueChanged.AddListener((float value) => { GenerateEvent(ET_UISliderValueChange, go.GetInstanceID(), value); });
                }
                break;
            case ET_UIInputFieldValueChange:
                {
                    InputField input_field = go.GetComponent<InputField>();
                    input_field.onValueChanged.AddListener((string value) => { GenerateEvent(ET_UIInputFieldValueChange, go.GetInstanceID(), value); });
                }
                break;
            case ET_UITextPicOnClickHref:
                {
                    TextPic text_pic2 = go.GetComponent<TextPic>();
                    text_pic2.ClickHrefCallBack = (string key) =>
                    {
                        GenerateEvent(ET_UITextPicOnClickHref, go.GetInstanceID(), key);
                    };
                }
                break;
            case ET_UIActivityEffectFinish:
                {
                    UIActivityEffect activity_effect = go.GetComponent<UIActivityEffect>();
                    activity_effect.OnActivityEffectFinish = (string name) =>
                    {
                        GenerateEvent(ET_UIActivityEffectFinish, go.GetInstanceID(), name);
                    };
                }
                break;
            case ET_UIChatViewUpdate:
                {
                    UIChatSwipeView chat_swipe = go.GetComponent<UIChatSwipeView>();
                    chat_swipe.UpdateChat = (int update_type) =>
                    {
                        GenerateEvent(ET_UIChatViewUpdate, go.GetInstanceID(), update_type);
                    };
                }
                break;
            case ET_UILoopListItemSelect:
                {
                    UILoopListView loop_list = go.GetComponent<UILoopListView>();
                    loop_list.OnItemSelect = () =>
                    {
                        GenerateEvent(ET_UILoopListItemSelect, go.GetInstanceID());
                    };
                }
                break;
            case ET_UIDynamicListItemSelect:
                {
                    UIDynamicList dynamic_list = go.GetComponent<UIDynamicList>();
                    dynamic_list.onItemSelect = (int info_id, GameObject select_go, bool is_click) =>
                    {
                        GenerateEvent(ET_UIDynamicListItemSelect, go.GetInstanceID(), info_id, select_go, is_click);
                    };
                    break;
                }
            case ET_UIDynamicListItemUpdate:
                {
                    UIDynamicList dynamic_list = go.GetComponent<UIDynamicList>();
                    dynamic_list.onItemUpdate = (GameObject update_go, int info_id) =>
                    {
                        GenerateEvent(ET_UIDynamicListItemUpdate, go.GetInstanceID(), update_go, info_id);
                    };
                    break;
                }
            case ET_UIDynamicListItemRequest:
                {
                    UIDynamicList dynamic_list = go.GetComponent<UIDynamicList>();
                    dynamic_list.onItemRequest = (page_index) =>
                    {
                        GenerateEvent(ET_UIDynamicListItemRequest, go.GetInstanceID(), page_index);
                    };
                    break;
                }
            case ET_UISlideSelectChange:
                {
                    UISlideSelect slide_select = go.GetComponent<UISlideSelect>();
                    slide_select.UpdateSelect = (offset) =>
                    {
                        GenerateEvent(ET_UISlideSelectChange, go.GetInstanceID(), offset);
                    };
                    break;
                }
            case ET_UIScrollListViewChange:
                {
                    UIScrollListView scroll_list_view = go.GetComponent<UIScrollListView>();
                    scroll_list_view.OnViewChange = (GameObject temp_go, int index, bool is_add) =>
                    {
                        GenerateEvent(ET_UIScrollListViewChange, go.GetInstanceID(), temp_go, index, is_add);
                    };
                    break;
                }
            case ET_UISlideSelectBegin:
                {
                    UISlideSelect slide_select = go.GetComponent<UISlideSelect>();
                    slide_select.SlideBegin = () =>
                    {
                        GenerateEvent(ET_UISlideSelectBegin, go.GetInstanceID());
                    };
                    break;
                }
            case ET_UISlideSelectEnd:
                {
                    UISlideSelect slide_select = go.GetComponent<UISlideSelect>();
                    slide_select.SlideEnd = (int index) =>
                    {
                        GenerateEvent(ET_UISlideSelectEnd, go.GetInstanceID(), index);
                    };
                    break;
                }
            case ET_UIScrollRectOnValueChanged:
                {
                    ScrollRect scroll_rect = go.GetComponent<ScrollRect>();
                    scroll_rect.onValueChanged.AddListener(delegate(Vector2 offset)
                    {
                        GenerateEvent(ET_UIScrollRectOnValueChanged, go.GetInstanceID(), offset);
                    });
                    break;
                }
}
    }

    public void UnRegisterUIEvent(GameObject go, int event_type)
    {
        switch (event_type)
        {
            case ET_UIOnClicked:
                {
                    Button button = go.GetComponent<Button>();
                    button.onClick.RemoveAllListeners();
                }
                break;
            case ET_UIToggle:
                {
                    Toggle toggle = go.GetComponent<Toggle>();
                    toggle.onValueChanged.RemoveAllListeners();
                }
                break;
            case ET_UIPress:
                {
                    UIEventTrigger trigger = go.GetComponent<UIEventTrigger>();
                    trigger.SetPressFunc(null);
                }
                break;
            case ET_UIRelease:
                {
                    UIEventTrigger trigger = go.GetComponent<UIEventTrigger>();
                    trigger.SetReleasFunc(null);
                }
                break;
            case ET_UIEnter:
                {
                    UIEventTrigger trigger = go.GetComponent<UIEventTrigger>();
                    trigger.SetEnterFunc(null);
                }
                break;
            case ET_UIExit:
                {
                    UIEventTrigger trigger = go.GetComponent<UIEventTrigger>();
                    trigger.SetExitFunc(null);
                }
                break;
            case ET_UIDrag:
                {
                    UIDragEventTrigger trigger = go.GetComponent<UIDragEventTrigger>();
                    trigger.SetDragFunc(null);
                }
                break;
            case ET_UIBeginDrag:
                {
                    UIDragEventTrigger trigger = go.GetComponent<UIDragEventTrigger>();
                    trigger.SetBeginDragFunc(null);
                }
                break;
            case ET_UIEndDrag:
                {
                    UIDragEventTrigger trigger = go.GetComponent<UIDragEventTrigger>();
                    trigger.SetEndDragFunc(null);
                }
                break;
            case ET_UITreeViewChange:
                {
                    UITreeView tree_view = go.GetComponent<UITreeView>();
                    tree_view.OnViewChange = null;
                }
                break;
            case ET_UITreeViewSelect:
                {
                    UITreeView tree_view = go.GetComponent<UITreeView>();
                    tree_view.OnSelectNode = null;
                }
                break;
            case ET_UISwipeViewChange:
                {
                    UISwipeView swipe_view = go.GetComponent<UISwipeView>();
                    swipe_view.OnViewChange = null;
                }
                break;
            case ET_UISwipeViewSelect:
                {
                    UISwipeView swipe_view = go.GetComponent<UISwipeView>();
                    swipe_view.OnSelectNode = null;
                }
                break;
            case ET_UITextPicPopulateMesh:
                {
                    TextPic text_pic = go.GetComponent<TextPic>();
                    text_pic.PopulateMeshCallBack = null;
                }
                break;
            case ET_UILongPress:
                {
                    UIEventTrigger long_press = go.GetComponent<UIEventTrigger>();
                    long_press.SetLongPressFunc(null);
                }
                break;
            case ET_UIPointerClick:
                {
                    UIEventTrigger trigger = go.GetComponent<UIEventTrigger>();
                    trigger.SetPointerClickFunc(null);
                }
                break;
            case ET_UISliderValueChange:
                {
                    Slider slider = go.GetComponent<Slider>();
                    slider.onValueChanged.RemoveAllListeners();
                }
                break;
            case ET_UIInputFieldValueChange:
                {
                    InputField input_field = go.GetComponent<InputField>();
                    input_field.onValueChanged.RemoveAllListeners();
                }
                break;
            case ET_UITextPicOnClickHref:
                {
                    TextPic text_pic2 = go.GetComponent<TextPic>();
                    text_pic2.ClickHrefCallBack = null;
                }
                break;
            case ET_UIActivityEffectFinish:
                {
                    UIActivityEffect activity_effect = go.GetComponent<UIActivityEffect>();
                    activity_effect.OnActivityEffectFinish = null;
                }
                break;
            case ET_UIChatViewUpdate:
                {
                    UIChatSwipeView chat_swipe = go.GetComponent<UIChatSwipeView>();
                    chat_swipe.UpdateChat = null;
                }
                break;
            case ET_UILoopListItemSelect:
                {
                    UILoopListView loop_list = go.GetComponent<UILoopListView>();
                    loop_list.OnItemSelect = null;
                }
                break;
            case ET_UIDynamicListItemSelect:
                {
                    UIDynamicList dynamic_list = go.GetComponent<UIDynamicList>();
                    dynamic_list.onItemSelect = null;
                    break;
                }
            case ET_UIDynamicListItemUpdate:
                {
                    UIDynamicList dynamic_list = go.GetComponent<UIDynamicList>();
                    dynamic_list.onItemUpdate = null;
                    break;
                }
            case ET_UIDynamicListItemRequest:
                {
                    UIDynamicList dynamic_list = go.GetComponent<UIDynamicList>();
                    dynamic_list.onItemRequest = null;
                    break;
                }
            case ET_UISlideSelectChange:
                {
                    UISlideSelect slide_select = go.GetComponent<UISlideSelect>();
                    slide_select.UpdateSelect = null;
                    break;
                }
            case ET_UIScrollListViewChange:
                {
                    UIScrollListView scroll_list_view = go.GetComponent<UIScrollListView>();
                    scroll_list_view.OnViewChange = null;
                    break;
                }
            case ET_UISlideSelectBegin:
                {
                    UISlideSelect slide_select = go.GetComponent<UISlideSelect>();
                    slide_select.SlideBegin = null;
                    break;
                }
            case ET_UISlideSelectEnd:
                {
                    UISlideSelect slide_select = go.GetComponent<UISlideSelect>();
                    slide_select.SlideEnd = null;
                    break;
                }
        }
    }

    public void RegisterCustomEvent(GameObject go)
    {
        CustomEventTrigger trigger = go.GetComponent<CustomEventTrigger>();
        if (trigger != null)
        {
            trigger.AddListener(delegate (string event_name) {
                GenerateEvent(ET_CustomEvent, go.GetInstanceID(), event_name);
            });
        }
    }
    public void UnRegisterCustomEvent(GameObject go)
    {
        CustomEventTrigger trigger = go.GetComponent<CustomEventTrigger>();
        if (trigger != null)
        {
            trigger.ClearListener();
        }
    }

    [DoNotToLua]
    public void GenerateEventTest(int event_type, object event_tag, params object[] pms)
    {
        GameEvent ge = new GameEvent(event_type, event_tag, pms);
        _AddEvent(ge);
    }

    [DoNotToLua]
    public void GenerateEvent(int event_type, object event_tag, params object[] pms)
    {
        Debug.Log("GenerateEvent=====" + event_type + "event_tag==" + event_tag + "params objec" + pms);
        GameEvent ge = new GameEvent(event_type, event_tag, pms);
        _AddEvent(ge);
    }

    [DoNotToLua]
    public GameEvent[] GetAllEvents()
    {
        if (_events_ == null)
        {
            _events_ = new List<GameEvent>();
        }
        GameEvent[] ret = _events_.ToArray();
        _events_.Clear();
        return ret;
    }
}
