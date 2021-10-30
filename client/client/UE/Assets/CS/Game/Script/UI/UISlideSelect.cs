using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.Events;
using UnityEngine.UI;
using System.Collections.Generic;
using System;

public class UISlideSelect : UIBehaviour, IBeginDragHandler, IEndDragHandler, IDragHandler
{

    public delegate void UpdateSelectDelegate(int index);
    public UpdateSelectDelegate UpdateSelect;
    public delegate void SlideBeginDelegate();
    public SlideBeginDelegate SlideBegin;
    public delegate void SlideEndDelegate(int index);
    public SlideEndDelegate SlideEnd;

    public RectTransform[] transform_list_;
    public bool is_loop_;
    public float move_time_ = 1;
    public int move_speed_ = 1000;
    public int drag_range_ = 600;
    public bool is_vertical_ = false;

    private Vector2 velocity_ = Vector2.zero;
    private float cell_width_;
    private float cell_height_;
    private int cur_index_ = 0;
    private int count_;

    private RectTransform content_;
    private float width_;
    private float height_;
    private Vector2 target_pos_;

    //loop
    private Vector2[] init_pos_list_;
    private Vector2[] target_pos_list_;
    private int offset_index_ = 0;
    private Vector2 begin_drag_pos_;
    private int move_dir_ = 0; // 往index减小的方向移动move_dir < 0
    private Vector2[] velocity_list_;

    private bool draggable_ = false;
    private bool is_drag_ = false;
    private bool is_move_ = false;

    public void Init()
    {
        if (transform_list_.Length > 0)
        {
            cell_width_ = transform_list_[0].rect.width;
            cell_height_ = transform_list_[0].rect.height;
        }
        content_ = GetComponent<RectTransform>();
        width_ = content_.rect.width;
        height_ = content_.rect.height;
        count_ = transform_list_.Length;
        draggable_ = count_ > 1;
        if (is_loop_)
        {
            init_pos_list_ = new Vector2[count_];
            target_pos_list_ = new Vector2[count_];
            velocity_list_ = new Vector2[count_];
            for (int i = 0; i < count_; i++)
            {
                init_pos_list_[i] = transform_list_[i].anchoredPosition;
                velocity_list_[i] = Vector2.zero;
            }
        }
    }

    public void SetParam(float size, int count)
    {
        content_ = GetComponent<RectTransform>();
        width_ = content_.rect.width;
        height_ = content_.rect.height;
        if (is_vertical_)
            cell_height_ = size;
        else
            cell_width_ = size;
        count_ = count;
        draggable_ = count_ > 1;
    }

    public void OnBeginDrag(PointerEventData eventData)
    {
        if (!IsActive() || !draggable_ || is_move_)
            return;
        is_drag_ = true;
        if (is_loop_)
            begin_drag_pos_ = eventData.position;
        if (SlideBegin != null)
            SlideBegin();
    }

    public void OnDrag(PointerEventData eventData)
    {
        if (!IsActive() || !is_drag_)
            return;
        if (is_loop_)
        {
            Vector2 offset = eventData.delta;
            if (is_vertical_)
            {
                offset.x = 0;
                if (Math.Abs(transform_list_[0].anchoredPosition.y - init_pos_list_[offset_index_].y) < height_)
                    for (int i = 0; i < count_; i++)
                        transform_list_[i].anchoredPosition = transform_list_[i].anchoredPosition + offset;
            }
            else {
                offset.y = 0;
                if (Math.Abs(transform_list_[0].anchoredPosition.x - init_pos_list_[offset_index_].x) < width_)
                    for (int i = 0; i < count_; i++)
                        transform_list_[i].anchoredPosition = transform_list_[i].anchoredPosition + offset;
            }
        }
        else {
            Vector2 new_pos = content_.anchoredPosition;
            if (is_vertical_)
            {
                new_pos.y = new_pos.y + eventData.delta.y;
                cur_index_ = Mathf.RoundToInt(-new_pos.y / cell_height_);
            }
            else {
                new_pos.x = new_pos.x + eventData.delta.x;
                cur_index_ = Mathf.RoundToInt(-new_pos.x / cell_width_);
            }
            if (cur_index_ < count_ && cur_index_ >= 0)
                content_.anchoredPosition = new_pos;
        }
    }

    public void OnEndDrag(PointerEventData eventData)
    {
        if (is_drag_)
        {
            if (is_loop_)
            {
                if (is_vertical_)
                {
                    move_dir_ = Mathf.Clamp(Mathf.RoundToInt((eventData.position.y - begin_drag_pos_.y) / drag_range_), -1, 1);
                    for (int i = 0; i < count_; i++)
                    {
                        target_pos_list_[i] = init_pos_list_[(int)Mathf.Repeat(i + offset_index_, count_)];
                        target_pos_list_[i].y += cell_height_ * -move_dir_;
                    }
                }
                else {
                    move_dir_ = Mathf.Clamp(Mathf.RoundToInt((eventData.position.x - begin_drag_pos_.x) / drag_range_), -1, 1);
                    for (int i = 0; i < count_; i++)
                    {
                        target_pos_list_[i] = init_pos_list_[(int)Mathf.Repeat(i + offset_index_, count_)];
                        target_pos_list_[i].x += cell_width_ * move_dir_;
                    }
                }
                offset_index_ = (int)Mathf.Repeat(offset_index_ + move_dir_, count_);
                is_move_ = true;
                if (SlideEnd != null)
                    SlideEnd(-move_dir_);
            }
            else {
                SlideToIndex(cur_index_);
            }
            is_drag_ = false;
        }
    }

    public void SetDraggable(bool value)
    {
        draggable_ = value;
    }

    /// <summary>
    /// 仅供非循环拖拽列表使用
    /// </summary>
    /// <param name="index">滑动到达目标索引</param>
    public void SlideToIndex(int index)
    {
        cur_index_ = Mathf.Clamp(index, 0, count_ - 1);
        if (is_vertical_)
            target_pos_ = new Vector2(0, -cell_height_ * cur_index_);
        else
            target_pos_ = new Vector2(-cell_width_ * cur_index_, 0);
        is_move_ = true;
        if (SlideEnd != null)
            SlideEnd(cur_index_);
    }

    /// <summary>
    /// 仅供循环拖拽列表使用
    /// </summary>
    /// <param name="offset">滑动偏移,小于0时往下标索引小的方向移动</param>
    public void SlideByOffset(int offset)
    {
        if (!IsActive() || is_move_ || !draggable_)
            return;
        if (is_loop_)
        {
            move_dir_ = offset;
            for (int i = 0; i < count_; i++)
            {
                target_pos_list_[i] = transform_list_[i].anchoredPosition;
                if (is_vertical_)
                    target_pos_list_[i].y += height_ * -move_dir_;
                else
                    target_pos_list_[i].x += width_ * move_dir_;
            }
            offset_index_ = (int)(Mathf.Repeat(offset_index_ + offset, count_) % count_);
            if (SlideEnd != null)
                SlideEnd(-move_dir_);
        }
        else {
            cur_index_ = Mathf.Clamp(cur_index_ + offset, 0, count_ - 1);
            if (is_vertical_)
                target_pos_ = new Vector2(-cell_height_ * cur_index_, 0);
            else
                target_pos_ = new Vector2(-cell_width_ * cur_index_, 0);
        }
        is_move_ = true;
    }

    public void SetToIndex(int index)
    {
        is_move_ = false;
        if (is_loop_)
        {
            for (int i = 0; i < count_; i++)
            {
                Vector2 target_pos = init_pos_list_[(i + offset_index_) % count_];
                if (is_vertical_)
                    target_pos.y += height_ * -index;
                else
                    target_pos.x += width_ * index;
                transform_list_[i].anchoredPosition = target_pos;
            }
            offset_index_ = (int)(Mathf.Repeat(offset_index_ + index, count_) % count_);

            int update_index = (int)Mathf.Repeat((index < 0 ? (count_ - 1) : 0) - offset_index_, count_);
            for (int i = 0; i < Math.Abs(index); i++)
            {
                int new_index = (int)Mathf.Repeat(update_index + (index < 0 ? -i : i), count_);
                transform_list_[new_index].anchoredPosition = index < 0 ? init_pos_list_[count_ - 1 - i] : init_pos_list_[i];
            }
        }
        else {
            cur_index_ = Mathf.Clamp(index, 0, count_ - 1);
            if (is_vertical_)
                content_.anchoredPosition = new Vector2(-cell_height_ * cur_index_, 0);
            else
                content_.anchoredPosition = new Vector2(-cell_width_ * cur_index_, 0);
        }
    }

    public void ResetLoopOffset()
    {
        is_move_ = false;
        offset_index_ = 0;
        for (int i = 0; i < count_; i++)
            transform_list_[i].anchoredPosition = init_pos_list_[i];
    }

    void Update()
    {
        if (is_move_)
        {
            if (is_loop_)
            {
                if (Vector2.Distance(transform_list_[0].anchoredPosition, target_pos_list_[0]) < 1f)
                {
                    for (int i = 0; i < count_; i++)
                        transform_list_[i].anchoredPosition = target_pos_list_[i];
                    if (move_dir_ != 0)
                    {
                        int update_index = (int)Mathf.Repeat((move_dir_ < 0 ? (count_ - 1) : 0) - offset_index_, count_);
                        for (int i = 0; i < Math.Abs(move_dir_); i++)
                        {
                            int new_index = (int)Mathf.Repeat(update_index + (move_dir_ < 0 ? -i : i), count_);
                            transform_list_[new_index].anchoredPosition = move_dir_ < 0 ? init_pos_list_[count_ - 1 - i] : init_pos_list_[i];
                            if (UpdateSelect != null)
                                UpdateSelect.Invoke(new_index);
                        }
                    }
                    else
                    {
                        if (UpdateSelect != null)
                            UpdateSelect.Invoke(-1);
                    }
                    is_move_ = false;
                }
                else {
                    for (int i = 0; i < count_; i++)
                        transform_list_[i].anchoredPosition = Vector2.SmoothDamp(transform_list_[i].anchoredPosition, target_pos_list_[i], ref velocity_list_[i], move_time_, move_speed_, Time.deltaTime);
                }
            }
            else{
                if (Vector2.Distance(content_.anchoredPosition, target_pos_) < 1f)
                {
                    content_.anchoredPosition = target_pos_;
                    if (UpdateSelect != null)
                        UpdateSelect.Invoke(cur_index_);
                    is_move_ = false;
                }
                else {
                    content_.anchoredPosition = Vector2.SmoothDamp(content_.anchoredPosition, target_pos_, ref velocity_, move_time_, move_speed_, Time.deltaTime);
                }
            }
        }
    }
}
