using UnityEngine;
using UnityEngine.UI;
using UnityEngine.EventSystems;
[RequireComponent (typeof(CustomEventTrigger))]
public class GuideMask : Graphic, ICanvasRaycastFilter
{
    private RectTransform target_rect_comp_;
    private Camera ui_camera_;
    private CustomEventTrigger event_trigger_;
    private Vector3 target_pos_ = Vector3.zero;
    private Vector2 target_size_ = Vector2.zero;
    private int event_type_;
    private bool is_valid_;
    private Vector3[] world_corners_ = new Vector3[4];
    private Vector2[] ui_corners_ = new Vector2[4];

    protected override void Awake()
    {
        ui_camera_ = GameObject.Find("/UICamera").GetComponent<Camera>();
        event_trigger_ = GetComponent<CustomEventTrigger>();
    }

    void Update()
    {
        if (ui_camera_ == null || ui_camera_.gameObject == null || target_rect_comp_ == null || target_rect_comp_.gameObject == null || !target_rect_comp_.gameObject.activeInHierarchy)
        {
            if (is_valid_)
            {
                is_valid_ = false;
                SetAllDirty();
            }
            return;
        }
        if (!is_valid_)
        {
            is_valid_ = true;
            SetAllDirty();
        }
        if (target_pos_ != target_rect_comp_.position || target_size_ != target_rect_comp_.rect.size)
        {
            target_pos_ = target_rect_comp_.position;
            target_size_ = target_rect_comp_.rect.size;
            target_rect_comp_.GetWorldCorners(world_corners_);
            for(int i = 0; i < world_corners_.Length; ++i) {
                var world_point = RectTransformUtility.WorldToScreenPoint(ui_camera_, world_corners_[i]);
                RectTransformUtility.ScreenPointToLocalPointInRectangle(rectTransform, world_point, ui_camera_, out ui_corners_[i]);
            }
            SetAllDirty();
            return;
        }
    }

    protected override void OnPopulateMesh(VertexHelper vh)
    {
        vh.Clear();

        if (!is_valid_)
        {
            return;
        }

        Vector4 outer = new Vector4(-rectTransform.pivot.x * rectTransform.rect.width,
                                 -rectTransform.pivot.y * rectTransform.rect.height,
                                 (1 - rectTransform.pivot.x) * rectTransform.rect.width,
                                 (1 - rectTransform.pivot.y) * rectTransform.rect.height);
        Vector4 inner = new Vector4(ui_corners_[0].x, ui_corners_[0].y,
                                    ui_corners_[2].x, ui_corners_[2].y);
        UIVertex vert = UIVertex.simpleVert;
        //矩形1
        vert.position = new Vector2(outer.x, outer.y); //顶点0
        vert.color = color;
        vh.AddVert(vert);
        vert.position = new Vector2(outer.x, outer.w); //顶点1
        vert.color = color;
        vh.AddVert(vert);
        vert.position = new Vector2(inner.x, outer.w); //顶点2
        vert.color = color;
        vh.AddVert(vert);
        vert.position = new Vector2(inner.x, outer.y); //顶点3
        vert.color = color;
        vh.AddVert(vert);
        //矩形2
        vert.position = new Vector2(inner.x, inner.w); //顶点4
        vert.color = color;
        vh.AddVert(vert);
        vert.position = new Vector2(inner.x, outer.w); //顶点5
        vert.color = color;
        vh.AddVert(vert);
        vert.position = new Vector2(inner.z, outer.w); //顶点6
        vert.color = color;
        vh.AddVert(vert);
        vert.position = new Vector2(inner.z, inner.w); //顶点7
        vert.color = color;
        vh.AddVert(vert);
        //矩形3
        vert.position = new Vector2(inner.z, outer.y); //顶点8
        vert.color = color;
        vh.AddVert(vert);
        vert.position = new Vector2(inner.z, outer.w); //顶点9
        vert.color = color;
        vh.AddVert(vert);
        vert.position = new Vector2(outer.z, outer.w); //顶点10
        vert.color = color;
        vh.AddVert(vert);
        vert.position = new Vector2(outer.z, outer.y); //顶点11
        vert.color = color;
        vh.AddVert(vert);
        //矩形4
        vert.position = new Vector2(inner.x, outer.y); //顶点12
        vert.color = color;
        vh.AddVert(vert);
        vert.position = new Vector2(inner.x, inner.y); //顶点13
        vert.color = color;
        vh.AddVert(vert);
        vert.position = new Vector2(inner.z, inner.y); //顶点14
        vert.color = color;
        vh.AddVert(vert);
        vert.position = new Vector2(inner.z, outer.y); //顶点15
        vert.color = color;
        vh.AddVert(vert);

        //矩形1的两个三角形
        vh.AddTriangle(0, 1, 2);
        vh.AddTriangle(2, 3, 0);

        //矩形2的两个三角形
        vh.AddTriangle(4, 5, 6);
        vh.AddTriangle(6, 7, 4);

        //矩形3的两个三角形
        vh.AddTriangle(8, 9, 10);
        vh.AddTriangle(10, 11, 8);

        //矩形4的两个三角形
        vh.AddTriangle(12, 13, 14);
        vh.AddTriangle(14, 15, 12);
    }

    public bool IsRaycastLocationValid(Vector2 sp, Camera eventCamera)
    {
        if (target_rect_comp_ == null || target_rect_comp_.gameObject == null || !target_rect_comp_.gameObject.activeInHierarchy)
        {
            return false;
        }
        bool is_raycast_valid = RectTransformUtility.RectangleContainsScreenPoint(target_rect_comp_, sp, eventCamera);
        return !is_raycast_valid;
    }

    public void SetTarget(GameObject go, int event_type, float _alpha)
    {
        _alpha = Mathf.Clamp(_alpha, 0f, 1f);
        color = new Color(color.r, color.g, color.b, _alpha);
        if (target_rect_comp_!= null){
            UnListenerEvent(target_rect_comp_.gameObject);
        }
        if (go == null)
        {
            target_rect_comp_ = null;
        }
        else
        {
            target_rect_comp_ = go.GetComponent<RectTransform>();
            ListenerEvent(go, event_type);
        }
    }

    private void ListenerEvent(GameObject go, int event_type)
    {
        UIEventListener listener = go.GetComponent<UIEventListener>();
        if (listener == null)
        {
            listener = go.AddComponent<UIEventListener>();
        }
        if (event_type == 1)
        {
            listener.onClick = TriggerEvent;
        }
        else if (event_type == 2)
        {
            listener.onDrag = TriggerEvent;
        }
    }

    private void UnListenerEvent(GameObject go)
    {
        UIEventListener listener = go.GetComponent<UIEventListener>();
        if (listener != null)
        {
            listener.ClearAll();
        }
    }

    private void TriggerEvent(GameObject go)
    {
        if (event_trigger_ != null)
        {
            event_trigger_.TriggerEvent("");
        }
    }
}