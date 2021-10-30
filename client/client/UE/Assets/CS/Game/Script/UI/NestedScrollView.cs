using UnityEngine;
using UnityEngine.UI;
using UnityEngine.EventSystems;
//仅适用于当前滑动方向与子scroll的不同时将事件发给父scroll处理
//设置 parent_scroll 和 自己的vertical 就可以了 自己的scrollrect horizontal 字段无效

public class NestedScrollView : ScrollRect {

    public ScrollRect parent_scroll;
    private bool isSelf = false;
    public override void OnBeginDrag(PointerEventData eventData)
    {

        if (vertical)
        {
            if (Mathf.Abs(eventData.delta.y) > Mathf.Abs(eventData.delta.x))
            {
                isSelf = true;
                base.OnBeginDrag(eventData);
            }
            else
            {
                isSelf = false;
                parent_scroll.OnBeginDrag(eventData);
            }
        }
        else
        {
            if (Mathf.Abs(eventData.delta.x) > Mathf.Abs(eventData.delta.y))
            {
                isSelf = true;
                base.OnBeginDrag(eventData);
            }
            else
            {
                isSelf = false;
                parent_scroll.OnBeginDrag(eventData);
            }
        }
    }

    public override void OnDrag(PointerEventData eventData)
    {
        if (isSelf)
        {
            base.OnDrag(eventData);
        }
        else
        {
            parent_scroll.OnDrag(eventData);
        }
    }

    public override void OnEndDrag(PointerEventData eventData)
    {
        if (isSelf)
        {
            base.OnEndDrag(eventData);
        }
        else
        {
            parent_scroll.OnEndDrag(eventData);
        }
    }
}
