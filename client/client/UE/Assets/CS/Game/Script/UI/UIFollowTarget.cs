using UnityEngine;

public class UIFollowTarget : MonoBehaviour
{
    public Canvas canvas_;
    public CanvasGroup canvas_group_;
    private Transform target_point_;
    private Vector2 offset_;

    private float cur_time_ = 0;
    private const float ANIM_TIME = 0.4f;

    void OnEnable()
    {
        if(canvas_group_ !=null){
            cur_time_ = ANIM_TIME;
            canvas_group_.alpha = 0f;
        }
        if (target_point_ != null)
        {
            FollowTarget();
        }
    }

    public void SetTarget(GameObject target, Vector2 offset)
    {
        if (target == null) return;
        target_point_ = target.transform;
        offset_ = offset;
        FollowTarget();
    }

    void Update()
    {
        if(cur_time_ > 0){
            cur_time_ = cur_time_ -  Time.deltaTime;
            if(cur_time_ <= 0){
                cur_time_ = 0;
            }
            canvas_group_.alpha = (ANIM_TIME - cur_time_) / ANIM_TIME;
        }
    }

    void OnGUI()
    {
        if (target_point_ != null && Camera.main != null)
        {
            FollowTarget();
        }
    }

    void FollowTarget()
    {
        Vector3 screen_point = Camera.main.WorldToScreenPoint(target_point_.position);
        screen_point += new Vector3(offset_.x * canvas_.scaleFactor, offset_.y * canvas_.scaleFactor);
        transform.position = Camera.main.ScreenToWorldPoint(screen_point);
        screen_point.y = screen_point.y + Screen.height;
        Vector3 pos = Camera.main.ScreenToWorldPoint(screen_point);
        float fov_scale = 60f;
        if(Camera.main.fieldOfView > 0){
            fov_scale = 60f / Camera.main.fieldOfView;
        }
        transform.localScale = Vector3.one * (transform.position - pos).magnitude * fov_scale;
    }
}