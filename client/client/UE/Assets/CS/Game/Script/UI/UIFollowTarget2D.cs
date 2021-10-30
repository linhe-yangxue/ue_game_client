using UnityEngine;
using UnityEngine.UI;
using System.Collections;

public class UIFollowTarget2D : MonoBehaviour
{
    private Transform target_point_;
    private Vector2 offset_;
    private Camera ui_camera_;
    private RectTransform parent_rect_;
    private RectTransform rect_;

    public void SetTarget(GameObject target, Vector2 offset)
    {
        if (target == null) return;
        target_point_ = target.transform;
        offset_ = offset;
        ui_camera_ = GameObject.Find("/UICamera").GetComponent<Camera>();
        rect_ = GetComponent<RectTransform>();
        parent_rect_ = transform.parent.GetComponent<RectTransform>();
        FollowTarget();
    }

    void Update()
    {
        if (target_point_ != null && Camera.main != null)
        {
            FollowTarget();
        }
    }

    void FollowTarget()
    {
        Vector3 view_point = Camera.main.WorldToViewportPoint(target_point_.position);
        if (view_point.z <= 0)
        {
            return;
        }
        Vector3 screen_pos = ui_camera_.WorldToScreenPoint(target_point_.position);
        Vector2 pos;
        if(RectTransformUtility.ScreenPointToLocalPointInRectangle(parent_rect_, screen_pos, ui_camera_, out pos)){
            rect_.localPosition = pos + offset_;
        }
    }
}
