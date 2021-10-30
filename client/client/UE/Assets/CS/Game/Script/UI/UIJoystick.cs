using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.EventSystems;

[AddComponentMenu("Game/UI/UIJoystick")]
public class UIJoystick : UIBehaviour, IPointerDownHandler, IPointerUpHandler, IDragHandler
{
    const float kInactiveAlpha = 0.4f;

    public delegate void JoystickEventFunc(Vector2 dir);

    public static event JoystickEventFunc OnJoystickStart;
    public static event JoystickEventFunc OnJoystickMove;
    public static event JoystickEventFunc OnJoystickEnd;
    public static event JoystickEventFunc OnJoystickClick;

    [ToolTips("是否位置固定", "IsPosFixed")]
    public bool is_pos_fixed_ = false;
    public Canvas canvas_ = null;

    bool _is_touching_ = false;
    bool _is_joystick_start_ = false;
    bool _has_dragged = false;
    RectTransform _js_region_trans_ = null;
    RectTransform _js_trans_ = null;
    RectTransform _js_dead_trans_ = null;
    RectTransform _js_touch_trans_ = null;
    CanvasGroup _canvas_group_ = null;
    GameObject _js_touch_static_go_ = null;
    GameObject _js_touch_dynamic_go_ = null;
    float _area_radius_;
    float _touch_radius_;
    float _dead_radius_;
    Vector2 _js_default_pos_;
    Vector2 _region_size_;
    Vector2 _cur_touch_pos_;
    Vector2 _cur_joystick_dir_;
    int _cur_pointer_id_ = -1;

    protected override void Awake()
    {
        _js_region_trans_ = transform.GetComponent<RectTransform>();
        _js_trans_ = _js_region_trans_.Find("Joystick").GetComponent<RectTransform>();
        _js_touch_trans_ = _js_trans_.Find("Touch").GetComponent<RectTransform>();
        _js_dead_trans_ = _js_trans_.Find("DeadZone").GetComponent<RectTransform>();
        _canvas_group_ = _js_touch_trans_.GetComponent<CanvasGroup>();
        _js_touch_static_go_ = _js_touch_trans_.Find("Static").gameObject;
        _js_touch_dynamic_go_ = _js_touch_trans_.Find("Dynamic").gameObject;
        _js_default_pos_ = _js_trans_.anchoredPosition;
        _CalcAllSize();
        _cur_joystick_dir_ = Vector2.zero;
    }

    void _CalcAllSize()
    {
        if (_js_region_trans_ != null)
        {
            _region_size_ = new Vector2(_js_region_trans_.rect.width, _js_region_trans_.rect.height);
            _area_radius_ = _js_trans_.rect.width * 0.5f;
            _dead_radius_ = _js_dead_trans_.rect.width * 0.5f;
            _touch_radius_ = _js_touch_trans_.rect.width * 0.5f;
        }
    }

    void _UpdateAreaAngle()
    {
        if(_cur_joystick_dir_.sqrMagnitude > 0.01)
        {
            float angle = Vector2.Angle(_cur_joystick_dir_, Vector2.up);
            if (_cur_joystick_dir_.x > 0)
            {
                angle = -angle;
            }
        }
    }

    void _SetAreaPos(PointerEventData data)
    {
        if (!is_pos_fixed_)
        {
            Vector2 pos;
            if (RectTransformUtility.ScreenPointToLocalPointInRectangle(_js_region_trans_, data.position, canvas_.worldCamera, out pos))
            {
                _SetAreaPos(pos);
            }
        }
    }

    void _SetAreaPos(Vector2 pos)
    {
        if (pos.x < _area_radius_ + _touch_radius_)
        {
            pos.x = _area_radius_ + _touch_radius_;
        }
        else if (pos.x > _region_size_.x - _area_radius_)
        {
            pos.x = _region_size_.x - _area_radius_;
        }
        if (pos.y < _area_radius_ + _touch_radius_)
        {
            pos.y = _area_radius_ + _touch_radius_;
        }
        else if (pos.y > _region_size_.y - _area_radius_)
        {
            pos.y = _region_size_.y - _area_radius_;
        }
        _js_trans_.localPosition = pos;
    }

    void _UpdateTouchPosAndDir(PointerEventData data)
    {
        Vector2 pos;
        if (RectTransformUtility.ScreenPointToLocalPointInRectangle(_js_trans_, data.position, canvas_.worldCamera, out pos))
        {
            _cur_touch_pos_ = pos;
            if (_cur_touch_pos_.magnitude > _area_radius_)
            {
                _cur_touch_pos_ = _cur_touch_pos_.normalized * _area_radius_;
                //超出范围跟随移动
                if (!is_pos_fixed_)
                {
                    pos = new Vector2(_js_trans_.localPosition.x + pos.x - _cur_touch_pos_.x, _js_trans_.localPosition.y + pos.y - _cur_touch_pos_.y);
                    _SetAreaPos(pos);
                }
            }
            if (_cur_touch_pos_.magnitude <= _dead_radius_)
            {
                _cur_joystick_dir_ = Vector2.zero;
                if (_is_joystick_start_)
                {
                    if (OnJoystickEnd != null)
                    {
                        OnJoystickEnd(_cur_joystick_dir_);
                    }
                    _is_joystick_start_ = false;
                }
            }
            else
            {
                _cur_joystick_dir_ = _cur_touch_pos_;
                if (!_is_joystick_start_)
                {
                    if (OnJoystickStart != null)
                    {
                        OnJoystickStart(_cur_joystick_dir_);
                    }
                    _is_joystick_start_ = true;
                }
            }
            _js_touch_trans_.localPosition = _cur_touch_pos_;
        }
    }

    protected override void Start()
    {
        ResetJoystick();
    }

    void Update()
    {
        if (_is_touching_ && _is_joystick_start_ && OnJoystickMove != null)
        {
            OnJoystickMove(_cur_joystick_dir_);
        }
    }

    protected override void OnRectTransformDimensionsChange()
    {
        _CalcAllSize();
    }

    protected override void OnDisable()
    {
        ResetJoystick();
    }

    public void OnPointerDown(PointerEventData data)
    {
        if (_is_touching_)
        {
            return;
        }
        _is_touching_ = true;
        _cur_pointer_id_ = data.pointerId;
        //_canvas_group_.alpha = 1;
        _js_touch_static_go_.SetActive(false);
        _js_touch_dynamic_go_.SetActive(true);
        _SetAreaPos(data);
        _UpdateTouchPosAndDir(data);
        _UpdateAreaAngle();
    }

    public void OnPointerUp(PointerEventData data)
    {
        if (_is_touching_ && _cur_pointer_id_ == data.pointerId)
        {
            if (!_has_dragged)
            {
                if (OnJoystickClick != null)
                {
                    OnJoystickClick(_cur_joystick_dir_);
                }
            }
            ResetJoystick();
        }
    }

    public void OnDrag(PointerEventData data)
    {
        if (_is_touching_ && _cur_pointer_id_ == data.pointerId)
        {
            _UpdateTouchPosAndDir(data);
            _UpdateAreaAngle();
            _has_dragged = true;
        }
    }

    public void ResetJoystick()
    {
        //_canvas_group_.alpha = kInactiveAlpha;
        _js_trans_.anchoredPosition = _js_default_pos_;
        _js_touch_trans_.localPosition = Vector2.zero;
        _cur_joystick_dir_ = Vector2.zero;
        _cur_pointer_id_ = -1;
        _js_touch_static_go_.SetActive(true);
        _js_touch_dynamic_go_.SetActive(false);
        if (_is_touching_ && _is_joystick_start_ && OnJoystickEnd != null)
        {
            OnJoystickEnd(_cur_joystick_dir_);
        }
        _is_touching_ = false;
        _is_joystick_start_ = false;
        _has_dragged = false;
        _UpdateAreaAngle();
    }

    public void SetJoystickFixPos(bool is_fix_pos)
    {
        is_pos_fixed_ = is_fix_pos;
        ResetJoystick();
    }
}
