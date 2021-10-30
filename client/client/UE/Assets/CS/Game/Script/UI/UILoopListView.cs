using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UILoopListView : MonoBehaviour
{

    public delegate void ItemSelectDelegate();
    public ItemSelectDelegate OnItemSelect = null;
    public RectTransform content_;
    public float anim_time_ = 1f;
    public float init_anim_time_ = 1f;
    public float start_value_ = 0.5f;
    public float show_count_ = 0;
    public AnimationCurve pos_x_curve_;
    public AnimationCurve pos_y_curve_;
    public AnimationCurve scale_curve_;
    public AnimationCurve alpha_curve_;
    private Vector2 content_size_;
    private int cur_select_index_ = 1;
    private int cur_target_index_ = 1;
    private float cur_anim_time_ = 0;
    private bool is_moving_ = false;
    private int child_count_ = 0;
    private float add_value_ = 0;
    private List<LoopSwipeItem> child_items_ = new List<LoopSwipeItem>();

    // anim 
    private bool is_play_init_anim_ = false;
    private List<LoopSwipeItem> anim_items_ = new List<LoopSwipeItem>();


    public void Refresh(bool is_play_init_anim)
    {
        content_size_ = content_.rect.size;
        child_count_ = content_.childCount;
        add_value_ = 1f / show_count_;
        child_items_.Clear();
        anim_items_.Clear();
        for (int i = 0; i < child_count_; i++)
        {
            LoopSwipeItem item = new LoopSwipeItem();
            child_items_.Add(item);
            item.start_val_ = start_value_ + i * add_value_;
            RectTransform rect = content_.GetChild(i) as RectTransform;
            item.rect_comp_ = rect;
            CanvasGroup canvas_group = rect.GetComponent<CanvasGroup>();
            if (canvas_group == null)
            {
                canvas_group = rect.gameObject.AddComponent<CanvasGroup>();
            }
            item.canvas_group_ = canvas_group;
            item.SetActive(true, true);
            UpdateItemOffset(item, (1 - cur_select_index_) * add_value_);
            if (is_play_init_anim)
            {
                if (item.target_val_ < 1)
                {
                    anim_items_.Add(item);
                }
            }
        }
        is_play_init_anim_ = is_play_init_anim;
        if (is_play_init_anim_)
        {
            cur_anim_time_ = 0;
            foreach (var item in anim_items_)
            {
                UpdateItemPos(item, item.target_val_ - 1);
            }
        }

    }

    void Update()
    {
        if (is_play_init_anim_)
        {
            cur_anim_time_ += Time.deltaTime;
            if (cur_anim_time_ >= init_anim_time_)
            {
                cur_anim_time_ = init_anim_time_;
                is_play_init_anim_ = false;
            }
            float t = cur_anim_time_ / init_anim_time_;
            foreach (var item in anim_items_)
            {
                float val = Mathf.Lerp(item.target_val_ - 1, item.target_val_, t);
                UpdateItemPos(item, val);
            }
        }
        else if (is_moving_)
        {
            cur_anim_time_ += Time.deltaTime;
            if (cur_anim_time_ >= anim_time_)
            {
                is_moving_ = false;
                cur_select_index_ = (cur_target_index_ + child_count_) % child_count_;
                if (cur_select_index_ == 0)
                {
                    cur_select_index_ = child_count_;
                }
            }
            float diff = Mathf.Lerp(cur_select_index_, cur_target_index_, cur_anim_time_ / anim_time_);
            for (int i = 0; i < child_count_; i++)
            {
                UpdateItemOffset(child_items_[i], (1 - diff) * add_value_);
            }
            if (!is_moving_)
            {
                if (OnItemSelect != null)
                {
                    OnItemSelect();
                }
            }
        }
    }

    public void SelectNext()
    {
        int select_index = cur_select_index_;
        select_index++;
        if(select_index > child_count_)
        {
            select_index = 1;
        }
        SelectIndex(select_index, true);
    }

    public void SelectLast()
    {
        int select_index = cur_select_index_;
        select_index--;
        if (select_index < 1)
        {
            select_index = child_count_;
        }
        SelectIndex(select_index, true);
    }

    public void SelectIndex(int index, bool is_show_anim)
    {
        if (is_play_init_anim_) return;
        if (index > 0 && index <= child_count_ && cur_select_index_ != index && !is_moving_)
        {
            if (Mathf.Abs(cur_select_index_ - index) > Mathf.Abs(cur_select_index_ + child_count_ - index))
            {
                cur_target_index_ = index - child_count_;
            }
            else if (Mathf.Abs(cur_select_index_ - index) > Mathf.Abs(index + child_count_ - cur_select_index_))
            {
                cur_target_index_ = index + child_count_;
            }
            else
            {
                cur_target_index_ = index;
            }
            if (is_show_anim)
            {
                cur_anim_time_ = 0;
                is_moving_ = true;
            }
            else
            {
                // 在当前帧完成
                cur_select_index_ = (cur_target_index_ + child_count_) % child_count_;
                if (cur_select_index_ == 0)
                {
                    cur_select_index_ = child_count_;
                }
                for (int i = 0; i < child_count_; i++)
                {
                    UpdateItemOffset(child_items_[i], (1 - cur_target_index_) * add_value_);
                }
                OnItemSelect();
            }
        }
    }

    public int GetCurIndex()
    {
        return cur_select_index_;
    }

    public void SetCurIndex(int index)
    {
        cur_select_index_ = index;
        Refresh(false);
    }

    public void UpdateItemOffset(LoopSwipeItem item, float offset)
    {
        float val = item.start_val_ + offset;
        float total_val = child_count_ * add_value_;
        val = (val + total_val) % total_val;
        item.target_val_ = val;
        UpdateItemPos(item, val);
    }

    public void UpdateItemPos(LoopSwipeItem item, float val)
    {
        if (val > 1 || val < 0)
        {
            item.SetActive(false);
        }
        else
        {
            Vector2 pos = new Vector2(GetPositionX(val), GetPositionY(val));
            item.rect_comp_.anchoredPosition = pos;
            float scale_value = GetScale(val);
            item.rect_comp_.localScale = new Vector3(scale_value, scale_value, 1);
            item.canvas_group_.alpha = GetAlpha(val);
            item.SetActive(true);
        }
    }

    public float GetAlpha(float val)
    {
        return alpha_curve_.Evaluate(val);
    }
    public float GetPositionX(float val)
    {
        return content_size_.x * pos_x_curve_.Evaluate(val);
    }

    public float GetPositionY(float val)
    {
        return -content_size_.y * pos_y_curve_.Evaluate(val);
    }

    public float GetScale(float val)
    {
        return scale_curve_.Evaluate(val);
    }

    public class LoopSwipeItem
    {
        public float start_val_ = 0;
        public float target_val_ = 0;

        public RectTransform rect_comp_;
        public CanvasGroup canvas_group_;
        public bool is_active_;
        public void SetActive(bool is_active, bool is_init = false)
        {
            if (!is_init && is_active == is_active_)
            {
                return;
            }
            is_active_ = is_active;
            rect_comp_.gameObject.SetActive(is_active);
        }
    }
}

