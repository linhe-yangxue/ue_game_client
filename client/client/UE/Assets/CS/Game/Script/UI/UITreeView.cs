using UnityEngine;
using UnityEngine.UI;
using System.Collections;
using System.Collections.Generic;
using UnityEngine.EventSystems;

[RequireComponent(typeof(ScrollRect))]
public class UITreeView : UIBehaviour
{
    public delegate void ViewChangeDelegate(GameObject go, UITreeNodeData data);
    public ViewChangeDelegate OnViewChange;
    public delegate void SelectNodeDelegate(UITreeNodeData data);
    public SelectNodeDelegate OnSelectNode;

    public int cell_padding_ = 0;
    public bool is_one_open_ = true;
    public bool is_auto_select_child_= false;
    public GameObject[] level_tree_node_;

    private float[] cell_height;
    private float _content_height_;
    private float _view_height_;
    private RectTransform _content_;
    private RectTransform _view_rect_;
    private ScrollRect _scroll_rect_;
    private UITreeNodeData _cur_select_node_data_;
    
    private Dictionary<GameObject, int> _node_go_id_dict_ = new Dictionary<GameObject, int>();
    private Dictionary<int, Queue<GameObject>> _unactive_node_go_dict_ = new Dictionary<int, Queue<GameObject>>();
    private Dictionary<int,GameObject> _active_node_go_dict_ = new Dictionary<int,GameObject>();
    private List<UITreeNodeData> _visible_data_list_ = new List<UITreeNodeData>();
    private List<UITreeNodeData> _data_ = new List<UITreeNodeData>();
    
    protected override void Awake()
    {
        _scroll_rect_ = GetComponent<ScrollRect>();
        _content_ = _scroll_rect_.content;
        _scroll_rect_.onValueChanged.RemoveAllListeners();
        _scroll_rect_.onValueChanged.AddListener(UpdatePos);
        _view_rect_ = GetComponent<RectTransform>();
        _view_height_ = _view_rect_.sizeDelta.y;
        cell_height = new float[level_tree_node_.Length];
        for(int i=0;i < level_tree_node_.Length; i++)
        {
            GameObject go = level_tree_node_[i];
            go.SetActive(false);
            cell_height[i] = go.GetComponent<RectTransform>().sizeDelta.y;
        }
    }

    public void Init(UITreeNodeData[] arr)
    {
        _data_.Clear();
        for (int i = 0; i < arr.Length; i++)
        {
            arr[i].SetIndex(i);
            _data_.Add(arr[i]);
        }
        UpdateTreeView();
    }


    public UITreeNodeData GetCurNodeData()
    {
        if (_cur_select_node_data_ != null)
        {
            return _cur_select_node_data_;
        }
        return null;
    }

    public void SelectNodeById(int id)
    {
        UITreeNodeData data = GetNodeById(id);
        if (data != null)
        {
            SelectNode(data);
        }
    }

    private UITreeNodeData GetNodeById(int id, UITreeNodeData data = null)
    {

        if(data == null){
            for (int i = 0; i < _data_.Count; i++)
            {
                var item = _data_[i];
                item = GetNodeById(id, item);
                if(item != null)return item;
            }
        }else{
            if (data.id == id)
            {
                return data;
            }
            else
            {
                for (int i = 0; i < data.child.Count; i++)
                {
                    var item = data.child[i];
                    item = GetNodeById(id, item);
                    if (item != null) return item;
                }
            }
        }
        return null;
    }

    public void SelectNode(UITreeNodeData node_data)
    {
        _cur_select_node_data_ = node_data;
        bool is_expand = node_data.is_expand;
        if (is_one_open_ && !is_expand)
        {
            foreach (var data in _visible_data_list_)
            {
                if (data.is_expand && data.index != node_data.index)
                {
                    data.SetExpand(false);
                }
            }
        }
        node_data.SetExpand(!is_expand);
        if (OnSelectNode != null)
        {
            OnSelectNode(node_data);
        }
        UpdateTreeView();
    }

    public void UpdatePos(Vector2 pos)
    {
        float min = _content_.anchoredPosition.y;
        float max = min + _view_height_;
        for (int i = 0; i < _visible_data_list_.Count; i++){
            var node_data = _visible_data_list_[i];
            if ((node_data.pos < (min - node_data.height) || node_data.pos > max) && _active_node_go_dict_.ContainsKey(i))
            {
                DelTreeNode(i);
            }
            else if ((node_data.pos >= (min - node_data.height) && node_data.pos <= max) && !_active_node_go_dict_.ContainsKey(i))
            {
                AddTreeNode(i);
            }
        }
    }

    public void UpdateTreeView()
    {
        foreach (var i in _active_node_go_dict_.Keys)
        {
            DelTreeNode(i, false);
        }
        _active_node_go_dict_.Clear();
        _visible_data_list_.Clear();
        _content_height_ = 0;
        for (int i = 0; i < _data_.Count; i++)
        {
             InitQueue(_data_[i]);
        }
        _content_.sizeDelta = new Vector2(_content_.sizeDelta.x, _content_height_);
        UpdatePos(Vector2.zero);
        if (is_one_open_ && _cur_select_node_data_ != null)
        {
            if (_cur_select_node_data_.is_expand)
            {
                float val = 1 - (_cur_select_node_data_.pos / (_content_height_ - _view_height_));
                val = Mathf.Clamp01(val);
                _scroll_rect_.verticalNormalizedPosition = val;
            }
        }
    }

    public void UpdateTreeNode()
    {
        foreach (var item in _active_node_go_dict_)
        {
            if (OnViewChange != null)
            {
                UITreeNodeData node_data = _visible_data_list_[item.Key];
                OnViewChange.Invoke(item.Value, node_data);
            }
        }
    }

    private void InitQueue(UITreeNodeData node_data)
    {
        node_data.pos = _content_height_;
        node_data.height = cell_height[node_data.level];
        _content_height_ += cell_height[node_data.level] + cell_padding_;
        _visible_data_list_.Add(node_data);
        if (node_data.is_expand && node_data.child.Count > 0)
        {
            for (int i = 0; i < node_data.child.Count; i++)
            {
               InitQueue(node_data.child[i]);
            }
        }
    }

    private void AddTreeNode(int index)
    {
        UITreeNodeData node_data = _visible_data_list_[index];
        GameObject node;
        int id = level_tree_node_[node_data.level].gameObject.GetInstanceID();
        if (_unactive_node_go_dict_.ContainsKey(id) && _unactive_node_go_dict_[id].Count > 0)
        {
            node = _unactive_node_go_dict_[id].Dequeue();
        }
        else
        {
            node = GameObject.Instantiate(level_tree_node_[node_data.level]) as GameObject;
            _node_go_id_dict_.Add(node, id);
            node.transform.SetParent(_content_, false);
        }
        node.GetComponent<RectTransform>().anchoredPosition = new Vector2(0, -node_data.pos);
        if(_cur_select_node_data_ == node_data)
        {
            node_data.is_select = true;
        }else
        {
            node_data.is_select = false;
        }
        if (OnViewChange != null)
        {
            OnViewChange.Invoke(node, node_data);
        }
        node.gameObject.SetActive(true);
        var btn = node.GetComponent<Button>();
        if (btn != null)
        {
            btn.onClick.AddListener(delegate(){
                if(is_auto_select_child_ && node_data.child.Count > 0){
                    SelectNode(node_data.child[0]);
                }else{
                    SelectNode(node_data);
                }
            });
        }
        _active_node_go_dict_.Add(index, node);
    }

    private void DelTreeNode(int index, bool remove = true)
    {
        GameObject node = _active_node_go_dict_[index];
        node.GetComponent<Button>().onClick.RemoveAllListeners();
        int id = _node_go_id_dict_[node];
        if (!_unactive_node_go_dict_.ContainsKey(id))
        {
            _unactive_node_go_dict_[id] = new Queue<GameObject>();
        }
        Queue<GameObject> queue  =  _unactive_node_go_dict_[id];
        queue.Enqueue(node);
        node.gameObject.SetActive(false);
        if (remove)
        {
            _active_node_go_dict_.Remove(index);
        }
    }
}

public class UITreeNodeData
{
    public int id;
    public int level;
    public int index;
    public UITreeNodeData parent;
    public List<UITreeNodeData> child = new List<UITreeNodeData>();
    public bool is_expand;
    public float pos;
    public float height;
    public bool is_select;

    public UITreeNodeData(int id, int level)
    {
        this.id = id;
        this.level = level;
    }

    public void SetIndex(int index)
    {
        this.index = index;
        for (int i = 0; i < this.child.Count; i++)
        {
            this.child[i].SetIndex(index);
        }
    }

    public void AddChild(UITreeNodeData c)
    {
        c.parent = this;
        child.Add(c);
    }

    public void RemoveChild(UITreeNodeData c)
    {
        child.Remove(c);
    }

    public int GetChildCount()
    {
        return child.Count;
    }

    public void SetExpand(bool is_expand){
        if(is_expand)
        {
            if(parent!=null)parent.SetExpand(true);
        }else{
            foreach (var c in child)
            {
                c.SetExpand(false);
            }
        }
        if(child.Count > 0){
            this.is_expand = is_expand;
        }
    }

    public UITreeNodeData GetRootNode()
    {
        if (parent!=null)
        {
            return parent.GetRootNode();
        }
        else
        {
            return this;
        }
    }
}
