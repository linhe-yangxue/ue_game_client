using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
using SLua;

public class UIScrollListView : MonoBehaviour, IBeginDragHandler, IEndDragHandler, IDragHandler
{
    public delegate void ViewChangeDelegate(GameObject go, int index, bool is_add);
    public ViewChangeDelegate OnViewChange;

    [DoNotToLua]
    public int column_length_;// 增加了多列显示功能
    [DoNotToLua]
    public GameObject temp_;
    [DoNotToLua]
    public RectTransform content_;
    [DoNotToLua]
    public int total_count_ = 0;
    [DoNotToLua]
    public bool is_vertical_ = true;
    [DoNotToLua]
    public float padding_bottom_ = 0;
    [DoNotToLua]
    public float padding_left = 0;
    [DoNotToLua]
    public float offsetX_ = 0;
    [DoNotToLua]
    public float offsetY_ = 0;
    [DoNotToLua]
    public AnimationCurve pos_x_curve_;
    [DoNotToLua]
    public AnimationCurve pos_y_curve_;
    [DoNotToLua]
    public Dictionary<int, GameObject> active_go_dict_ = new Dictionary<int, GameObject>();

    [DoNotToLua]
    public float interval;

    [DoNotToLua]
    public bool is_self_adaption;

    [DoNotToLua]
    public float adaption_interval;

    [DoNotToLua]
    public float inertia_ = 0.01f;
    [DoNotToLua]
    public AnimationCurve inertia_curve_;

    private int show_count_ = 0;
    private int start_flag_index_ = 0;
    private int end_flag_index_ = 0;
    private Vector2 cell_size_;
    private Vector2 view_size_;
    private Queue<GameObject> unactive_go_queue_ = new Queue<GameObject>();
    private Vector2 temp_size_;

    private Vector2 last_pos_;
    private Vector2 offset_;
    private float smooth_time_;
    private float smooth_timer_;
    private bool is_under_inertia_ = false;
    private float cur_offsetX_;
    private float parent_rect_width_;

    void OnEnable()
    {
        parent_rect_width_ = GetComponent<RectTransform>().rect.width;
        view_size_ = this.GetComponent<RectTransform>().rect.size;
        InitScrollListView(total_count_, show_count_);
    }

    public void InitScrollListView(int total_count, int show_count)
    {
        cur_offsetX_ = offsetX_;
        column_length_ = column_length_ == 0 ? 1 : column_length_;
        show_count_ = show_count;
        total_count_ = total_count > show_count ? total_count : show_count;
        if (active_go_dict_.Count > 0)
        {
            List<int> temp_list = new List<int>();
            foreach (var key in active_go_dict_.Keys)
            {
                temp_list.Add(key);
            }
            for (int i = 0; i < temp_list.Count; i++)
            {
                RemoveGo(temp_list[i]);
            }
            active_go_dict_.Clear();
        }

        RectTransform temp_rect = temp_.GetComponent<RectTransform>();

        RectTransform parent_rect = GetComponent<RectTransform>();
        //if (column_length_ == 1)
        //{
        //    if (is_self_adaption)
        //    {
        //        temp_size_ = new Vector2(parent_rect.rect.width - adaption_interval, temp_rect.sizeDelta.y);
        //        cur_offsetX_ = -(temp_size_.x) / 2;
        //    }
        //    else
        //    {
        //        temp_size_ = new Vector2(temp_rect.sizeDelta.x, temp_rect.sizeDelta.y);
        //        cur_offsetX_ = -temp_size_.x / 2;
        //    }
        //    temp_rect.sizeDelta = temp_size_;
        //}
        if (column_length_ == 1)
        {
            if (is_self_adaption)
            {
                temp_size_ = new Vector2(parent_rect_width_ - adaption_interval, temp_rect.sizeDelta.y);
                cur_offsetX_ = -(temp_size_.x) / 2;
            }
            else
            {
                temp_size_ = new Vector2(temp_rect.sizeDelta.x, temp_rect.sizeDelta.y);
                cur_offsetX_ = -temp_size_.x / 2;
            }
            temp_rect.sizeDelta = temp_size_;
        }
        else
        {
            temp_size_ = new Vector2(temp_rect.sizeDelta.x, temp_rect.sizeDelta.y);
            if (is_self_adaption)
            {
                interval = (parent_rect_width_ - temp_rect.sizeDelta.x * column_length_) / (column_length_ + 1);
                cur_offsetX_ = -parent_rect_width_ / column_length_;
            }
            else
            {
                cur_offsetX_ = -temp_size_.x;
            }
        }

        //view_size_ = this.GetComponent<RectTransform>().rect.size;
        cell_size_ = new Vector2(temp_size_.x + padding_left, temp_size_.y + padding_bottom_);
        content_.anchoredPosition = new Vector2(0, 0);
        start_flag_index_ = 0;
        end_flag_index_ = 0;
        for (int i = 0; i < show_count_; i++)
        {
            AddNode(i, end_flag_index_);
            end_flag_index_ = i;
        }
    }

    public void ResetScrollListView(int start_index)
    {
        cur_offsetX_ = offsetX_;
        if (active_go_dict_.Count > 0)
        {
            List<int> temp_list = new List<int>();
            foreach (var key in active_go_dict_.Keys)
            {
                temp_list.Add(key);
            }
            for (int i = 0; i < temp_list.Count; i++)
            {
                RemoveGo(temp_list[i]);
            }
            active_go_dict_.Clear();
        }
        if (total_count_ <= show_count_)
            start_index = 0;
        else if (start_index > total_count_ - show_count_)
        {
            start_index = total_count_ - show_count_ - 1;
        }
        else
        {
            start_index = start_index - 1;
        }
        end_flag_index_ = start_index;
        start_flag_index_ = start_index;
        for (int i = 0; i < show_count_; i++)
        {
            AddNode(start_index + i, end_flag_index_);
            end_flag_index_ = start_index + i;
        }
    }

    void AddNode(int index, int comparison_index)
    {
        GameObject go;
        if (unactive_go_queue_.Count == 0)
        {
            go = GameObject.Instantiate(temp_);
        }
        else
        {
            go = unactive_go_queue_.Dequeue();
        }
        go.transform.SetParent(content_, false);
        Vector2 target_pos;

        Vector3 comparison_pos = Vector3.zero;

        float value;
        if (comparison_index == index)  //初始化
            value = 0;
        else
        {
            comparison_pos = active_go_dict_[comparison_index].transform.localPosition;
            if (is_vertical_)
            {
                int comparison_row = GetRow(comparison_index);
                int m_row = GetRow(index);
                if (comparison_row == m_row)
                {
                    value = comparison_pos.y;
                }
                else
                {
                    value = m_row > comparison_row ? comparison_pos.y - cell_size_.y : comparison_pos.y + cell_size_.y;
                }
            }
            else
            {
                value = index > comparison_index ? comparison_pos.x + cell_size_.x : comparison_pos.x - cell_size_.x;
            }
        }

        target_pos = is_vertical_ ? new Vector3(0, value, 0) : new Vector3(value, 0, 0);
        go.GetComponent<RectTransform>().pivot = new Vector2(0, 1);
        go.GetComponent<RectTransform>().sizeDelta = temp_size_;

        float pos_x = cur_offsetX_ + GetPositionX(target_pos.y) + (index % column_length_) * temp_size_.x + (index % column_length_) * interval;
        float pos_y = target_pos.y;
        go.transform.localPosition = is_vertical_ ? new Vector3(pos_x, pos_y, 0) : new Vector3(target_pos.x, 0, 0);
        go.transform.localPosition += is_vertical_ ? new Vector3(interval, 0, 0) : new Vector3(0, interval, 0);

        go.transform.localScale = Vector3.one;
        go.SetActive(true);
        active_go_dict_.Add(index, go);
        if (OnViewChange != null)
        {
            OnViewChange(go, index, true);
        }
    }

    void RemoveGo(int index)
    {
        GameObject go = active_go_dict_[index];
        go.SetActive(false);
        unactive_go_queue_.Enqueue(go);
        active_go_dict_.Remove(index);
        if (OnViewChange != null)
        {
            OnViewChange(go, index, false);
        }
    }

    void UpdateItemPosition(Vector2 delta)
    {
        if (end_flag_index_ == 0)
        {
            return;
        }

        Vector2 start_pos = active_go_dict_[start_flag_index_].transform.localPosition;
        Vector2 end_pos = active_go_dict_[end_flag_index_].transform.localPosition;

        if (is_vertical_)
        {
            delta.x = 0;
        }
        else
        {
            delta.y = 0;
        }
        start_pos = start_pos + delta;
        end_pos = end_pos + delta;


        bool is_add_end = false;
        if (is_vertical_)
        {
            is_add_end = end_flag_index_ < total_count_ - 1 && end_pos.y > -(view_size_.y + 10);
        }
        else
        {
            is_add_end = end_flag_index_ < total_count_ - 1 && end_pos.x < view_size_.x + 10;
        }

        bool is_remove_end = false;
        is_remove_end = is_vertical_ ? end_pos.y <= -view_size_.y - cell_size_.y : end_pos.x > view_size_.x + cell_size_.x;

        if (is_add_end)
        {
            AddNode(end_flag_index_ + 1, end_flag_index_);
            end_flag_index_ = end_flag_index_ + 1;
        }
        else
        {
            if (is_remove_end && end_flag_index_ > show_count_)  //防止瞬间delta值过大，移除
            {
                RemoveGo(end_flag_index_);
                end_flag_index_ = end_flag_index_ - 1;
            }
        }

        bool is_remove_first = false;
        is_remove_first = is_vertical_ ? start_pos.y > cell_size_.y * 2 : start_pos.x < -cell_size_.x * 2;

        bool is_add_first = false;
        is_add_first = is_vertical_ ? start_flag_index_ > 0 && start_pos.y <= 0 : start_flag_index_ > 0 && start_pos.x >= 0;

        if (is_remove_first && total_count_ - start_flag_index_ - 1 > show_count_)   //防止瞬间delta值过大，移除
        {
            RemoveGo(start_flag_index_);
            start_flag_index_ = start_flag_index_ + 1;
        }
        else if (is_add_first)
        {
            for (int i = 0; i < column_length_; i++)
            {
                AddNode(start_flag_index_ - 1, start_flag_index_);
                start_flag_index_ = start_flag_index_ - 1;
            }
        }

        bool can_update = false;
        can_update = is_vertical_ ? start_pos.y >= 0 && (end_pos.y - cell_size_.y) < -view_size_.y : start_pos.x <= 0 && (end_pos.x + cell_size_.x) > view_size_.x;
        if (can_update)
        {
            foreach (var node_ in active_go_dict_)
            {
                GameObject go = node_.Value;
                Vector2 pos = go.transform.localPosition;
                if (is_vertical_)
                {
                    pos = new Vector2(GetPositionX(pos.y + delta.y), pos.y + delta.y);
                    if (column_length_ > 1)
                    {
                        float x = cur_offsetX_ + ((node_.Key + 1) % column_length_) * temp_size_.x + ((node_.Key + 1) % column_length_) * interval;
                        pos = new Vector2(x, pos.y);
                    }
                    else
                    {
                        pos = new Vector2(cur_offsetX_, pos.y);
                    }
                }
                else
                {
                    pos = new Vector2(pos.x + delta.x, GetPositionY(pos.x + delta.x));
                }
                go.transform.localPosition = pos;
                go.transform.localPosition += is_vertical_ ? new Vector3(interval, 0, 0) : new Vector3(0, interval, 0);
            }
        }
        else {
            is_under_inertia_ = false;
        }
    }

    float GetPositionX(float val)
    {
        if (val <= cell_size_.y && val >= -view_size_.y)
        {
            return cur_offsetX_ * pos_x_curve_.Evaluate(-val / view_size_.y);
        }
        return 0;
    }

    float GetPositionY(float val)
    {
        if (val >= -cell_size_.x && val <= view_size_.x)
        {
            return offsetY_ * pos_y_curve_.Evaluate(val / view_size_.x);
        }
        return 0;
    }

    [DoNotToLua]
    public void OnBeginDrag(PointerEventData eventData)
    {
        is_under_inertia_ = false;
    }

    [DoNotToLua]
    public void OnDrag(PointerEventData eventData)
    {
        UpdateItemPosition(eventData.delta);
        last_pos_ = eventData.position;
    }

    [DoNotToLua]
    public void OnEndDrag(PointerEventData eventData)
    {
        offset_ = eventData.position - last_pos_;
        smooth_time_ = Mathf.Abs(is_vertical_ ? offset_.y : offset_.x) * inertia_;
        if (smooth_time_ > 0)
        {
            smooth_timer_ = 0;
            offset_ = offset_ * smooth_time_;
            is_under_inertia_ = true;
        }
    }

    void Update()
    {
        if (is_under_inertia_ && smooth_timer_ < smooth_time_)
        {
            smooth_timer_ = smooth_timer_ + Time.deltaTime;
            if (smooth_timer_ >= smooth_time_)
            {
                is_under_inertia_ = false;
                smooth_timer_ = 0;
                smooth_time_ = 0;
                return;
            }
            UpdateItemPosition(offset_ * inertia_curve_.Evaluate(smooth_timer_ / smooth_time_));
        }
    }

    public void ChangeTotalCount(int total_count)
    {
        total_count_ = total_count > show_count_ ? total_count : show_count_;
    }

    private int GetRow(int index)
    {
        return index / column_length_;
    }

    public int GetStartFlagIndex()
    {
        return start_flag_index_;
    }

    public int GetEndFlagIndex()
    {
        return end_flag_index_;
    }
}
