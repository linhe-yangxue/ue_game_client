using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

[System.Serializable]
public class RectEditor {

    public enum ControlState {
        None = 0,
        select = 1,
        move = 2,
        resize = 3,
    }

    public bool can_select_ = true;
    public bool can_move_ = true;
    public bool can_resize_ = true;
    public bool lock_x_, lock_y_;
    public Vector2 snap_ = Vector2.one;
    public Vector2 big_snap_ = Vector2.one * 5;

    public bool is_select_;
    public Rect rect_;
    public Rect new_rect_;

    public ControlState state_;
    public int resize_x_, resize_y_;

    public bool is_drag_;
    public Vector2 drag_start_pos_;
    public Vector2 drag_last_pos_;

    public float control_range_ = 8;
    public float drag_range_ = 8;

    public delegate void OnSelect(Rect rect, bool confirm);
    public delegate void OnMove(Vector2 offset, bool confirm);
    public delegate void OnResize(Rect rect, Rect new_rect, bool confirm);

    public OnSelect onSelect;
    public OnMove onMove;
    public OnResize onResize;

    public void OnGUI(Rect rect) {
        DrawControl(rect);
        DrawRect(rect);
    }

    public void DrawControl(Rect rect) {
        int control_id = GetHashCode();
        var evt = Event.current;
        var event_type = evt.GetTypeForControl(control_id);
        var mouse_pos = evt.mousePosition;
        if (event_type == EventType.MouseDown && evt.button == 0) {
            if (rect.Contains(mouse_pos)) {
                if (StartDrag(mouse_pos)) {
                    GUIUtility.keyboardControl = 0;
                    GUIUtility.hotControl = control_id;
                    evt.Use();
                    is_drag_ = false;
                    drag_start_pos_ = mouse_pos;
                }
            }
        } else if (event_type == EventType.MouseDrag && GUIUtility.hotControl == control_id) {
            evt.Use();
            UpdateDrag(mouse_pos);
        } else if (event_type == EventType.MouseUp && GUIUtility.hotControl == control_id) {
            GUIUtility.hotControl = 0;
            evt.Use();
            UpdateDrag(mouse_pos);
            FinishDrag(mouse_pos);
        }
    }

    public Vector2 Snap(Vector2 pos) {
        if (Event.current.control) {
            pos.x = Mathf.Round(pos.x / big_snap_.x) * big_snap_.x;
            pos.y = Mathf.Round(pos.y / big_snap_.y) * big_snap_.y;
        } else {
            pos.x = Mathf.Round(pos.x / snap_.x) * snap_.x;
            pos.y = Mathf.Round(pos.y / snap_.y) * snap_.y;
        }
        return pos;
    }

    public void DrawRect(Rect rect) {
        if (is_select_) {
            GUI.Box(rect_, "");
        }
        if (state_ != ControlState.None) {
            GUI.Box(new_rect_, "");
        }
    }

    public void SetRect(Rect rect) {
        rect_ = FixRect(rect);
        is_select_ = true;
    }

    public void ClearRect() {
        is_select_ = false;
    }

    bool StartDrag(Vector2 mouse_pos) {
        if (is_select_) {
            int x, y;
            if (!Event.current.control && GetRectBorder(mouse_pos, out x, out y)) {
                if (x == 0 && y == 0) {
                    if (can_move_) {
                        state_ = ControlState.move;
                        new_rect_ = rect_;
                        return true;
                    }
                } else {
                    if (can_resize_) {
                        state_ = ControlState.resize;
                        resize_x_ = x;
                        resize_y_ = y;
                        new_rect_ = rect_;
                        return true;
                    }
                }
            } else {
                if (can_select_) {
                    state_ = ControlState.select;
                    new_rect_ = new Rect(mouse_pos, Vector2.zero);
                    return true;
                }
            }
        } else {
            if (can_select_) {
                state_ = ControlState.select;
                new_rect_ = new Rect(mouse_pos, Vector2.zero);
                return true;
            }
        }
        return false;
    }

    bool GetRectBorder(Vector2 mouse_pos, out int x, out int y) {
        x = 0;
        y = 0;
        var center_rect = new Rect(rect_.x + control_range_,
                                    rect_.y + control_range_,
                                    rect_.width - control_range_ * 2,
                                    rect_.height - control_range_ * 2);
        var total_rect = new Rect(rect_.x - control_range_,
                                    rect_.y - control_range_,
                                    rect_.width + control_range_ * 2,
                                    rect_.height + control_range_ * 2);
        if (center_rect.Contains(mouse_pos)) {
            return true;
        } else if (total_rect.Contains(mouse_pos)) {
            if (!lock_x_) {
                if (mouse_pos.x < center_rect.xMin) {
                    x = -1;
                } else if (mouse_pos.x > center_rect.xMax) {
                    x = 1;
                }
            }
            if (!lock_y_) {
                if (mouse_pos.y < center_rect.yMin) {
                    y = -1;
                } else if (mouse_pos.y > center_rect.yMax) {
                    y = 1;
                }
            }
            return true;
        }
        return false;
    }

    void UpdateDrag(Vector2 mouse_pos) {
        if (!is_drag_ && Vector2.Distance(drag_start_pos_, mouse_pos) > drag_range_) {
            is_drag_ = true;
            drag_last_pos_ = drag_start_pos_;
        }
        if (is_drag_) {
            var offset = mouse_pos - drag_start_pos_;
            drag_last_pos_ = mouse_pos;
            if (state_ == ControlState.select) {
                new_rect_ = FixRect(new Rect(drag_start_pos_, offset));
                if (onSelect != null) onSelect(new_rect_, false);
            } else if (state_ == ControlState.move) {
                if (lock_x_) offset.x = 0;
                if (lock_y_) offset.y = 0;
                new_rect_.position = Snap(rect_.position + offset);
                if (onMove != null) onMove(new_rect_.position - rect_.position, false);
            } else if (state_ == ControlState.resize) {
                if (lock_x_) offset.x = 0;
                if (lock_y_) offset.y = 0;
                if (resize_x_ < 0) {
                    new_rect_.xMin = Snap(rect_.min + offset).x;
                } else if (resize_x_ > 0) {
                    new_rect_.xMax = Snap(rect_.max + offset).x;
                }
                if (resize_y_ < 0) {
                    new_rect_.yMin = Snap(rect_.min + offset).y;
                } else if (resize_y_ > 0) {
                    new_rect_.yMax = Snap(rect_.max + offset).y;
                }
                if (onResize != null) onResize(rect_, new_rect_, false);
            }
        }
    }

    void FinishDrag(Vector2 mouse_pos) {
        var old_rect = rect_;
        if (is_drag_) {
            SetRect(new_rect_);
            is_drag_ = false;
            if (state_ == ControlState.select) {
                if (onSelect != null) onSelect(new_rect_, true);
            } else if (state_ == ControlState.move) {
                if (onMove != null) onMove(new_rect_.position - old_rect.position, true);
            } else if (state_ == ControlState.resize) {
                if (onResize != null) onResize(old_rect, new_rect_, true);
            }
        } else {
            if (state_ == ControlState.select) {
                SetRect(new_rect_);
                if (onSelect != null) onSelect(new_rect_, true);
            }
        }
        state_ = ControlState.None;
    }

    Rect FixRect(Rect rect) {
        return Rect.MinMaxRect(
            Mathf.Min(rect.xMin, rect.xMax),
            Mathf.Min(rect.yMin, rect.yMax),
            Mathf.Max(rect.xMin, rect.xMax),
            Mathf.Max(rect.yMin, rect.yMax));
    }
}
