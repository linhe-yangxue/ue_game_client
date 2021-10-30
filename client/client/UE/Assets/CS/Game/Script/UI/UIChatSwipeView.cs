using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.Events;
using UnityEngine.UI;
using System.Collections.Generic;

public class UIChatSwipeView : UIBehaviour, IBeginDragHandler, IEndDragHandler, IDragHandler
{
    public delegate void UpdateChatDelegate(int index);  // 1: 上  2:下
    public UpdateChatDelegate UpdateChat;
    public float hide_scroll_delay_ = 1;

    private Transform content_;
    private Scrollbar vertical_scroll_bar_;
    private float hide_scroll_timer_;
    public void Init()
    {
        content_ = this.GetComponent<Transform>().Find("View/Content");
        vertical_scroll_bar_ = GetComponent<ScrollRect>().verticalScrollbar;
    }

    public void OnBeginDrag(PointerEventData eventData)
    {
        hide_scroll_timer_ = 0;
        vertical_scroll_bar_.GetComponent<Image>().color = Color.white;
        vertical_scroll_bar_.GetComponent<Scrollbar>().interactable = true;
    }

    public void OnDrag(PointerEventData eventData)
    {
    }

    public void OnEndDrag(PointerEventData eventData)
    {
        hide_scroll_timer_ = hide_scroll_delay_;

        Vector3 pos = content_.GetComponent<RectTransform>().anchoredPosition;
        float content_heigh = content_.GetComponent<RectTransform>().rect.height;
        float view_heigh = this.GetComponent<RectTransform>().rect.height;
        if (content_heigh > view_heigh && -pos.y - (content_heigh - view_heigh) - 10 > 0)
        {
            if (UpdateChat != null)
            {
                UpdateChat.Invoke(1);
            }
        }
        if (pos.y + 10 < 0 )
        {
            if (UpdateChat != null)
            {
                UpdateChat.Invoke(2);
            }
        }
    }
    void Update()
    {
        if (hide_scroll_timer_ > 0)
        {
            hide_scroll_timer_ -= Time.deltaTime;
            if (hide_scroll_timer_ <= 0)
            {
                vertical_scroll_bar_.GetComponent<Image>().color = Color.clear;
                vertical_scroll_bar_.GetComponent<Scrollbar>().interactable = false;
                hide_scroll_timer_ = 0;
            }
        }
    }

}
