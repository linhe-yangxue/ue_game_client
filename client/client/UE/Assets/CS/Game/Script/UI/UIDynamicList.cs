using System.Collections;
using UnityEngine.UI;
using System.Collections.Generic;
using UnityEngine.EventSystems;
using UnityEngine;
using System;
using SLua;

[ExecuteInEditMode]
[RequireComponent(typeof(ScrollRect))]
public class UIDynamicList : UIBehaviour, IDragHandler, IEndDragHandler
{
    //listeners
    [DoNotToLua]
    public System.Action<GameObject, int> onItemUpdate = null;
    [DoNotToLua]
    public System.Action<int> onItemRequest = null;
    [DoNotToLua]
    public System.Action<int, GameObject, bool> onItemSelect = null;

    [DoNotToLua]
    public float padding_top = 0;
    [DoNotToLua]
    public float padding_left = 0;
    [DoNotToLua]
    public float padding_space = 0;
    [Header("AnimObjects")]
    [DoNotToLua]
    public RectTransform refresh_anim_rect = null;
    [DoNotToLua]
    public GameObject more_item_anim = null;

    class ItemInfo
    {
        public RectTransform item_rect = null;
        public int info_id = int.MinValue;
        public ItemInfo(int info_id)
        {
            this.info_id = info_id;
        }
    }
    const int slide_type_hor = 1;
    const int slide_type_ver = 2;
    const float scroll_inertia_rate = 0.1f;
    const float refresh_anim_wait_time = 2.5f;
    const string select_str = "Select";
    const string pool_obj_str = "DynamicListObjPool";
    RectTransform view = null;
    RectTransform content = null;
    RectTransform item = null;
    ScrollRect scroll_cmp;
    Vector2 item_size;
    Vector2 view_size;
    int cur_slide_type = 0;
    int offset_count = 2;       //动态删除对象的偏移数量
    int cur_page_index = 0;
    float min_offset_dist = 0;
    float max_offset_dist = 0;
    float refresh_pass_time = 0;
    List<ItemInfo> item_list = new List<ItemInfo>();
    bool is_request = false;
    bool is_awake_ok = false;  //当对象在预制体中被隐藏时，不会自动执行Awake
    ItemInfo select_item_info = null;
    List<RectTransform> item_pool_list = new List<RectTransform>();
    Transform pool_parent = null;
    protected override void Awake()
    {
        if (is_awake_ok) return;
        is_awake_ok = true;
        scroll_cmp = base.GetComponent<ScrollRect>();
        scroll_cmp.inertia = true;
        scroll_cmp.decelerationRate = scroll_inertia_rate;
        this.TrySetAllBaseData();
        this.ResetSlideType();
        this.ResetOffsetDist();
    }
    void Update()
    {
        if (!Application.isPlaying && Application.isEditor)
            Invoke("UpdateListOnEditor", 0);
        if (!Application.isPlaying) return;
        if(refresh_anim_rect != null&& refresh_anim_rect.gameObject.activeInHierarchy)
        {
            refresh_pass_time += Time.deltaTime;
            if(refresh_pass_time >= refresh_anim_wait_time)
            {
                refresh_pass_time = 0;
                this.SetRefreshAnimVisable(false);
            }
        }
    }
    bool TrySetAllBaseData()
    {
        content = scroll_cmp.content;
        view = scroll_cmp.viewport;
        if (content != null&&view != null)
        {
            item = content.GetChild(0).GetComponent<RectTransform>();
            item_size = item.sizeDelta;
            view_size = base.GetComponent<RectTransform>().sizeDelta;
            return true;
        }
        return false;
    }
    void ResetSlideType()
    {
        if (scroll_cmp.horizontal)
            cur_slide_type = slide_type_hor;
        else if (scroll_cmp.vertical)
            cur_slide_type = slide_type_ver;
        else
            Debug.LogError("UIDynamicList don't have slide type");
    }
    void ResetOffsetDist()
    {
        float offset_space = offset_count * padding_space;
        if (cur_slide_type == slide_type_ver)
        {
            max_offset_dist = offset_count * item_size.y + offset_space;
            min_offset_dist =  0 - ((offset_count - 1) * item_size.y  + offset_space + view_size.y);
        }
        else if (cur_slide_type == slide_type_hor)
        {
            min_offset_dist = 0 - (offset_count * item_size.x + offset_space);
            max_offset_dist = (offset_count - 1) * item_size.x + offset_space + view_size.x;
        }
    }
    void ResetRefreshAnim()
    {
        if (refresh_anim_rect == null) return;
        Vector2 anim_size = refresh_anim_rect.sizeDelta;
        refresh_anim_rect.transform.SetParent(content.transform);
        refresh_anim_rect.transform.localScale = Vector3.one;
        refresh_anim_rect.transform.localPosition = Vector3.zero;
        refresh_anim_rect.anchorMax = item.anchorMax;
        refresh_anim_rect.anchorMin = item.anchorMin;
        refresh_anim_rect.pivot = item.pivot;
        refresh_anim_rect.sizeDelta = anim_size;
        this.SetRefreshAnimVisable(false);
    }
    void ResetPoolObj()
    {
        pool_parent = transform.Find(pool_obj_str);
        if (pool_parent == null)
        {
            pool_parent = new GameObject(pool_obj_str).transform;
            pool_parent.SetParent(transform);
            pool_parent.localScale = Vector3.one;
            pool_parent.localPosition = Vector3.zero;
        }
    }
    public void Init()
    {
        if (!is_awake_ok) this.Awake();
        is_request = false;
        select_item_info = null;
        cur_page_index = 0;
        item.gameObject.SetActive(false);
        this.ResetPoolObj();
        this.UpdateContentSize();
        this.ResetRefreshAnim();
        this.CheckMoreItemAnimVisable();
        ScrollRect.ScrollRectEvent scroll_event = new ScrollRect.ScrollRectEvent();
        scroll_cmp.onValueChanged = scroll_event;
        scroll_event.AddListener(OnContentPosChange);
    }
    void OnContentPosChange(Vector2 pos)
    {
        this.CheckMoreItemAnimVisable();
        this.UpdateListItemVisible();
    }
    public void OnDrag(PointerEventData eventData)
    {
        float delta_dist = 0;
        if (cur_slide_type == slide_type_hor) delta_dist = eventData.delta.x;
        else if (cur_slide_type == slide_type_ver) delta_dist = 0 - eventData.delta.y;
        if(delta_dist < 0)
        {
            this.CheckSendItemRequest();
        }
    }
    public void OnEndDrag(PointerEventData eventData)
    {
        is_request = false;
    }
    void CheckSendItemRequest()
    {
        if (onItemRequest == null|| is_request) return;
        Vector2 last_item_pos = this.GetItemAnchoredPos(item_list.Count - 1);
        Vector2 item2view_pos = this.Item2ViewPos(last_item_pos);
        item2view_pos.Set(item2view_pos.x + item_size.x, Mathf.Abs(item2view_pos.y - item_size.y));
        if ((cur_slide_type == slide_type_hor && item2view_pos.x < view_size.x)
            || (cur_slide_type == slide_type_ver && item2view_pos.y < view_size.y))
        {
            is_request = true;
            this.SetRefreshAnimVisable(true);
            onItemRequest(cur_page_index + 1);
        }
    }
    Vector2 Item2ViewPos(Vector2 item_pos)
    {
        Vector2 content_pos = content.anchoredPosition;
        float x = 0 - content_pos.x;
        float y = 0 - content_pos.y;
        return new Vector2(item_pos.x - x, item_pos.y - y);
    }
    void UpdateListItemVisible()
    {
        int item_count = item_list.Count;
        for (int i = 0; i < item_count; ++i)
        {
            Vector2 item_pos = this.GetItemAnchoredPos(i);
            Vector2 item2view_pos = this.Item2ViewPos(item_pos);
            float cur_dist = 0;
            if (cur_slide_type == slide_type_hor) cur_dist = item2view_pos.x;
            else if (cur_slide_type == slide_type_ver) cur_dist = item2view_pos.y;
            if (cur_dist < min_offset_dist || cur_dist > max_offset_dist)
                this.DestroyListItem(i);
            else
                this.InitListItem(i);
        }
        this.UpdateListItemTransform();
    }
    void UpdateListItemTransform()
    {
        for (int i = 0; i < item_list.Count; ++i)
        {
            RectTransform item_rect = item_list[i].item_rect;
            if (item_rect != null)
            {
                item_rect.transform.SetParent(content.transform);
                item_rect.transform.localScale = Vector3.one;
                item_rect.transform.localPosition = Vector3.zero;
                item_rect.transform.SetSiblingIndex(i + 1); //加上模板
                item_rect.sizeDelta = item_size;
                item_rect.anchoredPosition = this.GetItemAnchoredPos(i);
            }
        }
    }
    Vector2 GetItemAnchoredPos(int index)
    {
        Vector2 ret_pos = Vector2.zero;
        float x = 0, y = 0;
        if (cur_slide_type == slide_type_hor)
        {
            x = index * padding_space + index * item_size.x;
        }
        else if (cur_slide_type == slide_type_ver)
        {
            y = index * padding_space + index * item_size.y;
        }
        ret_pos.Set(x + padding_left, 0 - (y + padding_top));
        return ret_pos;
    }
    void SetContentAnchoredPos(Vector2 new_pos)
    {
        Vector2 content_pos = content.anchoredPosition;
        float new_x = content_pos.x;
        float new_y = content_pos.y;
        if (cur_slide_type == slide_type_hor) new_x = new_pos.x;
        else if (cur_slide_type == slide_type_ver) new_y = new_pos.y;
        content.anchoredPosition = new Vector2(new_x, new_y);
    }
    void UpdateContentSize()
    {
        Vector2 content_size = content.sizeDelta;
        float size_x = content_size.x, size_y = content_size.y;
        int item_count = item_list.Count;
        float space_dist = item_count > 1 ? (item_count - 1) * padding_space : 0;
        if (cur_slide_type == slide_type_hor)
        {
            size_x = padding_left + space_dist + item_count * item_size.x;
            if (refresh_anim_rect != null && refresh_anim_rect.gameObject.activeSelf)
            {
                size_x += refresh_anim_rect.sizeDelta.x;
            }
        }
        else if (cur_slide_type == slide_type_ver)
        {
            size_y = padding_top + space_dist + item_count * item_size.y;
            if (refresh_anim_rect != null && refresh_anim_rect.gameObject.activeSelf)
            {
                size_y += refresh_anim_rect.sizeDelta.y;
            }
        }
        content.sizeDelta = new Vector2(size_x, size_y);
    }
    void InitListItem(int index)
    {
        ItemInfo item_info = item_list[index];
        RectTransform item_rect = item_info.item_rect;
        if (item_rect != null) return;
        RectTransform new_item = this.GetFreeItemFromPool();
        item_info.item_rect = new_item;
        new_item.name = index.ToString();
        this.SetVisibleItemSelectState(item_info, select_item_info == item_info);
        Button item_btn = new_item.GetComponent<Button>();
        if (item_btn != null)
        {
            item_btn.onClick.RemoveAllListeners();
            item_btn.onClick.AddListener(() =>
            {
                this.TrySelectListItem(item_info, true);
            });
        }
        if (onItemUpdate != null)
        {
            onItemUpdate(new_item.gameObject, item_info.info_id);
        }

    }
    void SetVisibleItemSelectState(ItemInfo visible_item_info, bool is_select, bool is_click = false)
    {
        GameObject visible_item = visible_item_info.item_rect.gameObject;
        Transform select_go = visible_item.transform.Find(select_str);
        if (select_go != null) select_go.gameObject.SetActive(is_select);
        if(onItemSelect != null && is_select)
        {
            onItemSelect(visible_item_info.info_id, visible_item, is_click);
        }
    }
    void TrySelectListItem(ItemInfo item_info, bool is_click = false) //选择的对象超出视野而没有实体化，没有选中状态
    {
        if (select_item_info != null&&select_item_info.item_rect != null)
        {
            this.SetVisibleItemSelectState(select_item_info, false);
        }
        select_item_info = item_info;
        if (select_item_info.item_rect != null)
        {
            this.SetVisibleItemSelectState(select_item_info, true, is_click);
        }
    }
    void DestroyListItem(int index)
    {
        ItemInfo item_info = item_list[index];
        if (item_info.item_rect == null) return;
        this.ReturnItemToPool(item_info.item_rect);
        item_info.item_rect = null;
    }
    void CheckMoreItemAnimVisable()
    {
        if (more_item_anim == null) return;
        Vector2 last_item_pos = this.GetItemAnchoredPos(item_list.Count - 1);
        Vector2 item2view_pos = this.Item2ViewPos(last_item_pos);
        if ((cur_slide_type == slide_type_hor && item2view_pos.x > view_size.x)
            ||(cur_slide_type == slide_type_ver && item2view_pos.y < -view_size.y))
        {
            more_item_anim.SetActive(true);
        }
        else more_item_anim.SetActive(false);
    }
    void SetRefreshAnimVisable(bool is_visable)
    {
        if (refresh_anim_rect == null) return;
        refresh_anim_rect.gameObject.SetActive(is_visable);
        if (is_visable)
        {
            refresh_pass_time = 0;
            this.UpdateRefreshAnimPos();
        }
        this.UpdateContentSize();
    }
    void UpdateRefreshAnimPos()
    {
        if (refresh_anim_rect == null) return;
        Vector2 last_item_pos = this.GetItemAnchoredPos(item_list.Count - 1);
        float x = last_item_pos.x;
        float y = last_item_pos.y;
        if (cur_slide_type == slide_type_hor) x += item_size.x;
        else if (cur_slide_type == slide_type_ver) y -= item_size.y;
        refresh_anim_rect.anchoredPosition = new Vector2(x, y);
    }
    void UpdateByChangeItemCount()
    {
        this.UpdateContentSize();
        this.CheckMoreItemAnimVisable();
        this.UpdateListItemVisible();
        item.gameObject.name = "item_" + item_list.Count;
    }
    #region ****interfaces
    public void AddPageListItem(int[] info_list)
    {
        for (int i = 0; i < info_list.Length; ++i)
        {
            int info_id = info_list[i];
            item_list.Add(new ItemInfo(info_id));
        }
        if (info_list.Length > 0)
        {
            is_request = false;
            ++cur_page_index;
            this.SetRefreshAnimVisable(false);
            this.UpdateByChangeItemCount();
        }
    }
    public void InsertItem(int index, int info_id, bool is_update)
    {
        item_list.Insert(index, new ItemInfo(info_id));
        if(is_update) this.UpdateByChangeItemCount();
    }
    public void RemoveItem(int index, bool is_update)
    {
        this.DestroyListItem(index);
        item_list.RemoveAt(index);
        if(is_update) this.UpdateByChangeItemCount();
    }
    public void SelectItem(int index)
    {
        if (index >= 0 && index < item_list.Count)
        {
            this.TrySelectListItem(item_list[index]);
        }
    }
    public void MoveViewToItem(int index)
    {
        if (index >= 0 && index < item_list.Count)
        {
            Vector2 item_pos = this.GetItemAnchoredPos(index);
            this.SetContentAnchoredPos(new Vector2(-item_pos.x, -item_pos.y));
            this.UpdateListItemVisible();
        }
    }
    public void UpdateList()
    {
        for (int i = 0; i < item_list.Count; ++i)
        {
            this.DestroyListItem(i);
        }
        this.UpdateListItemVisible();
    }
    public void ClearList()
    {
        for (int i = 0; i < item_list.Count; ++i)
        {
            this.DestroyListItem(i);
        }
        item_list.Clear();
        select_item_info = null;
        cur_page_index = 0;
        this.UpdateByChangeItemCount();
    }
    public void SetOffsetCount(int count)
    {
        offset_count = count;
        this.ResetOffsetDist();
    }
    #endregion
    //item res pool
    RectTransform GetFreeItemFromPool()
    {
        RectTransform free_item = null;
        for(int i = 0;i < item_pool_list.Count; ++i)
        {
            RectTransform item = item_pool_list[i];
            if (!item.gameObject.activeSelf&&item.parent != content.transform)
            {
                free_item = item;
                break;
            }
        }
        if(free_item == null)
        {
            GameObject new_item = Instantiate(item.gameObject);
            free_item = new_item.GetComponent<RectTransform>();
            item_pool_list.Add(free_item);
        }
        free_item.gameObject.SetActive(true);
        return free_item;
    }
    void ReturnItemToPool(RectTransform item)
    {
        item.transform.SetParent(pool_parent);
        item.transform.localScale = Vector3.one;
        item.gameObject.SetActive(false);
    }
    void DestroyItemPool()
    {
        for(int i = 0; i < item_pool_list.Count; ++i)
        {
            RectTransform item = item_pool_list[i];
            if(item != null) Destroy(item.gameObject);
        }
        item_pool_list.Clear();
        if (pool_parent!= null) Destroy(pool_parent.gameObject);
    }
    public void DoDestroy()
    {
        onItemRequest = null;
        onItemSelect = null;
        onItemUpdate = null;
        if(item_list != null&&item_list.Count > 0) this.ClearList();
        this.DestroyItemPool();
    }
    #region **********************ExecuteInEditMode
#if UNITY_EDITOR
    void UpdateListOnEditor()
    {
        if (!this.TrySetAllBaseData()) return;
        item_size = item.sizeDelta;
        this.ResetAllUILayout();
        this.ResetSlideType();
        if (refresh_anim_rect != null)
        {
            refresh_anim_rect.transform.SetSiblingIndex(content.childCount);
            refresh_anim_rect.anchorMax = new Vector2(0, 1);
            refresh_anim_rect.anchorMin = new Vector2(0, 1);
            refresh_anim_rect.pivot = new Vector2(0, 1);
        }
        for (int i = 0; i < content.childCount; ++i)
        {
            Transform item = content.GetChild(i);
            RectTransform item_rect = item.GetComponent<RectTransform>();
            Vector2 item_pos = this.GetItemAnchoredPos(i);
            item_rect.anchoredPosition = item_pos;
            if (item_rect != refresh_anim_rect) item_rect.sizeDelta = item_size;
        }
    }
    void ResetAllUILayout()
    {
        view.anchorMax = new Vector2(1f, 1f);
        view.anchorMin = new Vector2(0f, 0f);
        view.pivot = new Vector2(0.5f, 0.5f);
        view.offsetMax = Vector2.zero;
        view.offsetMin = Vector2.zero;
        content.anchorMin = new Vector2(0, 1);
        content.anchorMax = new Vector2(0, 1);
        content.pivot = new Vector2(0, 1);
        content.anchoredPosition = Vector2.zero;
        content.sizeDelta = view_size;
        item.anchorMax = new Vector2(0, 1);
        item.anchorMin = new Vector2(0, 1);
        item.pivot = new Vector2(0, 1);
    }
#endif
    #endregion
}
