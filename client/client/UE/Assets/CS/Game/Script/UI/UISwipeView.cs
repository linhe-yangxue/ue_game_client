using UnityEngine;
using UnityEngine.Events;
using UnityEngine.UI;
using UnityEngine.EventSystems;
using System.Collections.Generic;

public class NodeData
{
    public int idx;
    public GameObject go;
    public void reset()
    {
        idx = -1;
    }
}

public class UISwipeView : UIBehaviour, IBeginDragHandler, IEndDragHandler, IDragHandler
{
    public delegate void ViewChangeDelegate(GameObject go, int index);
    public ViewChangeDelegate OnViewChange;
    public delegate void SelectNodeDelegate(int index);
    public SelectNodeDelegate OnSelectNode;

    public GameObject temp_;
    public bool is_vertical_;
    public float offset_ = 0;
    public RectTransform content_;
    public bool is_limit_range;
    public float move_time_ = 1;
    public int move_speed_ = 1000;

    private string prefab_path_;
    private int cell_count_;
    private int cur_index_;
    private Vector2 cell_size_;
    private Vector2 target_pos_;
    private Vector2 velocity_ = Vector2.zero;
    private bool is_drag_ = false;
    private bool is_move_ = false;
    private int offset_cell_count_ = 0;
    private List<NodeData> active_node_list_ = new List<NodeData>();
    private Queue<NodeData> unactive_node_queue_ = new Queue<NodeData>();
    private Dictionary<int, int> active_node_index_dict_ = new Dictionary<int, int>();

    public void InitSwipeView(int count, int start_index, int offset_cell_count)
    {
        cell_count_ = count;
        cur_index_ = start_index;
        offset_cell_count_ = offset_cell_count;
        for (int i = 0; i < active_node_list_.Count; i++)
        {
            NodeData node = active_node_list_[i];
            unactive_node_queue_.Enqueue(node);
            node.go.SetActive(false);
            node.reset();
        }
        active_node_list_.Clear();
        active_node_index_dict_.Clear();
        if (cell_count_ == 0)
        {
            return;
        }
        temp_.SetActive(false);
        cell_size_ = temp_.GetComponent<RectTransform>().sizeDelta;
        Vector2 size = content_.GetComponent<RectTransform>().sizeDelta;
        if (is_vertical_)
        {
            size.y = cell_count_ * cell_size_.y;
        }
        else
        {
            size.x = cell_count_ * cell_size_.x;
        }
        content_.GetComponent<RectTransform>().sizeDelta = size;
        LocalToIndex(cur_index_);
    }

    public void InitSwipViewByPrefab(int count, int start_index, float x, float y, string path_name, int offset_cell_count)
    {
        //固定对象不动态删除
        is_move_ = false;
        prefab_path_ = path_name;
        cell_count_ = count;
        cur_index_ = start_index;
        offset_cell_count_ = offset_cell_count;
        if (cell_count_ == 0)
        {
            return;
        }
        for (int i = 0; i < active_node_list_.Count; i++)
        {
            NodeData node = active_node_list_[i];
            node.reset();
        }
        active_node_list_.Clear();
        active_node_index_dict_.Clear();
        Vector2 size = content_.GetComponent<RectTransform>().sizeDelta;
        cell_size_ = new Vector2(x, y);
        if (is_vertical_)
        {
            size.y = cell_count_ * cell_size_.y;
        }
        else
        {
            size.x = cell_count_ * cell_size_.x;
        }
        content_.GetComponent<RectTransform>().sizeDelta = size;
        LocalToIndex(cur_index_);
    }

    public void MoveToLast()
    {
        if (cur_index_ != 0)
        {
            is_move_ = true;
            is_drag_ = false;
            if (is_vertical_)
            {
                target_pos_ = new Vector2(0, (cell_size_.y * (cur_index_ - 1) + offset_));
            }
            else
            {
                target_pos_ = new Vector2(-(cell_size_.x * (cur_index_ - 1) + offset_), 0);
            }
            cur_index_ = cur_index_ - 1;
        }
    }

    public void MoveToNext()
    {
        if (cur_index_ != (cell_count_ - 1))
        {
            is_move_ = true;
            is_drag_ = false;
            if (is_vertical_)
            {
                target_pos_ = new Vector2(0, (cell_size_.y * (cur_index_ + 1) + offset_));
            }
            else
            {
                target_pos_ = new Vector2(-(cell_size_.x * (cur_index_ + 1) + offset_), 0);
            }
            cur_index_ = cur_index_ + 1;
        }
    }

    void OnScrolling()
    {
        int begin_index = GetBeginIndex();
        int end_index = GetEndIndex();
        while (active_node_list_.Count > 0)
        {
            NodeData node = active_node_list_[0];
            int idx = node.idx;
            if (idx < begin_index - offset_cell_count_)
            {
                active_node_index_dict_.Remove(idx);
                active_node_list_.Remove(node);
                unactive_node_queue_.Enqueue(node);
                node.reset();
                node.go.SetActive(false);
            }
            else
            {
                break;
            }
        }

        while (active_node_list_.Count > 0)
        {
            NodeData node = active_node_list_[active_node_list_.Count - 1];
            int idx = node.idx;
            if (idx > end_index + offset_cell_count_ && idx < cell_count_)
            {
                active_node_index_dict_.Remove(idx);
                active_node_list_.RemoveAt(active_node_list_.Count - 1);
                unactive_node_queue_.Enqueue(node);
                node.reset();
            }
            else
            {
                break;
            }
        }

        for (int idx = begin_index; idx <= end_index && idx < cell_count_; ++idx)
        {
            if (active_node_index_dict_.ContainsKey(idx))
            {
                continue;
            }
            AddNode(idx);
        }
    }

    private int GetBeginIndex()
    {
        Vector2 offset = content_.localPosition;
        if (cell_count_ == 0)
        {
            return 0;
        }
        if (is_vertical_)
        {
            int idx = Mathf.FloorToInt(offset.y / cell_size_.y);
            idx = Mathf.Clamp(idx, 0, cell_count_ - 1);
            return idx;
        }
        else
        {
            float xos = -offset.x;
            int idx = Mathf.FloorToInt(xos / cell_size_.x);
            idx = Mathf.Clamp(idx, 0, cell_count_ - 1);
            return idx;
        }
    }

    private int GetEndIndex()
    {
        Vector2 offset = content_.localPosition;
        if (cell_count_ == 0)
        {
            return 0;
        }
        if (is_vertical_)
        {
            float offset_y = offset.y + GetComponent<RectTransform>().rect.height;
            int idx = Mathf.CeilToInt(offset_y / cell_size_.y);
            idx = Mathf.Clamp(idx, 0, cell_count_ - 1);
            return idx;
        }
        else
        {
            float xos = -(offset.x + -GetComponent<RectTransform>().rect.width);
     
            int idx = Mathf.CeilToInt(xos / cell_size_.x);
            idx = Mathf.Clamp(idx, 0, cell_count_ - 1);
            return idx;
        }
    }

    private Vector2 GetPosByIndex(int idx)
    {
        if (idx == -1)
        {
            return Vector2.zero;
        }
        if (is_vertical_)
        {
            return new Vector2(0, -cell_size_.y * idx);
        }
        else
        {
            return new Vector2(cell_size_.x * idx, 0);
        }
    }

    private void InsertNode(NodeData node, int idx)
    {
        if (active_node_list_.Count == 0)
        {
            active_node_list_.Add(node);
        }
        else
        {
            for (int i = 0; i < active_node_list_.Count; i++)
            {
                if (active_node_list_[i].idx > idx)
                {
                    active_node_list_.Insert(i, node);
                    return;
                }
            }
            active_node_list_.Add(node);
        }
    }

    private void AddNode(int index)
    {
        NodeData node;
        if (unactive_node_queue_.Count == 0)
        {
            node = new NodeData();
            if (prefab_path_ != null)
            {
                int num = index + 1;
                string temp_name = prefab_path_ + num;
                node.go = content_.transform.Find(temp_name).gameObject;
            }
            else
            {
                node.go = GameObject.Instantiate(temp_);
            }
        }
        else
        {
            node = unactive_node_queue_.Dequeue();
        }
        node.idx = index;
        RectTransform rtran = node.go.GetComponent<RectTransform>();
        if (is_vertical_)
        {
            rtran.pivot = new Vector2(0, 1);
        }
        else
        {
            rtran.pivot = Vector2.zero;
        }
        node.go.SetActive(true);
        node.go.transform.SetParent(content_.transform, false);
        node.go.transform.localPosition = GetPosByIndex(index);
        InsertNode(node, index);
        if (!active_node_index_dict_.ContainsKey(index))
        {
            active_node_index_dict_.Add(index, 1);
        }
        if (OnViewChange != null)
        {
            OnViewChange.Invoke(node.go, index);
        }
    }

    private void SetContentAnchoredPosition(Vector2 delta)
    {
        Vector2 new_pos;
        if (is_vertical_)
        {
            delta.x = 0;
            new_pos = content_.anchoredPosition + delta;
            if (is_limit_range)
            {
                if (new_pos.y > 0)
                {
                    new_pos.x = 0;
                }
                float max_dist_y = content_.GetComponent<RectTransform>().sizeDelta.y - this.GetComponent<RectTransform>().sizeDelta.y;
                if (new_pos.y > max_dist_y)
                {
                    new_pos.y = max_dist_y;
                }
            }
            cur_index_ = Mathf.RoundToInt((new_pos.y - offset_) / cell_size_.y);
        }
        else
        {
            delta.y = 0;
            new_pos = content_.anchoredPosition + delta;
            if (is_limit_range)
            {
                if (new_pos.x > 0)
                {
                    new_pos.x = 0;
                }
                float max_dist_x = content_.GetComponent<RectTransform>().sizeDelta.x - this.GetComponent<RectTransform>().sizeDelta.x;
                if (new_pos.x < - max_dist_x)
                {
                    new_pos.x = - max_dist_x;
                }
            }
            cur_index_ = Mathf.RoundToInt((-new_pos.x - offset_) / cell_size_.x);
        }
        if (cur_index_ < cell_count_ && cur_index_ >= 0)
        {
            content_.anchoredPosition = new_pos;
        }
    }

    public void OnBeginDrag(PointerEventData eventData)
    {
        if (!IsActive()) return;
        is_move_ = false;
        is_drag_ = true;
    }

    public void OnEndDrag(PointerEventData eventData)
    {
        if (is_drag_)
        {
            is_drag_ = false;
            SwipeToIndex(cur_index_);
        }
    }

    public void LocalToIndex(int index)
    {
        cur_index_ = Mathf.Clamp(index, 0, cell_count_ - 1);
        if (is_vertical_)
        {
            content_.anchoredPosition = new Vector2(0, (cell_size_.y * cur_index_ + offset_));
        }
        else
        {
            content_.anchoredPosition = new Vector2(-(cell_size_.x * cur_index_ + offset_), 0);
        }
        OnScrolling();
        if (OnSelectNode != null)
        {
            OnSelectNode.Invoke(cur_index_);
        }
    }

    public void SwipeToIndex(int index)
    {
        cur_index_ = Mathf.Clamp(index, 0, cell_count_ - 1);
        if (is_vertical_)
        {
            target_pos_ = new Vector2(0, (cell_size_.y * cur_index_  + offset_));
        }
        else
        {
            target_pos_ = new Vector2(-(cell_size_.x * cur_index_ + offset_), 0);
        }
        is_move_ = true;
    }

    public void OnDrag(PointerEventData eventData)
    {
        if (!IsActive() || !is_drag_)
            return;
        SetContentAnchoredPosition(eventData.delta);
        OnScrolling();
    }

    void Update()
    {
        
        if (is_move_)
        {
            if (Vector2.Distance(content_.anchoredPosition, target_pos_) < 0.02f)
            {
                content_.anchoredPosition = target_pos_;
                is_move_ = false;
                if (OnSelectNode != null)
                {
                    OnSelectNode.Invoke(cur_index_);
                }
                return;
            }

            content_.anchoredPosition = Vector2.SmoothDamp(content_.anchoredPosition, target_pos_, ref velocity_, move_time_, move_speed_, Time.deltaTime);
            OnScrolling();
        }
    }
}

