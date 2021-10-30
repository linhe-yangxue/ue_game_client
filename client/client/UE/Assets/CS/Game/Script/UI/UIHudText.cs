using UnityEngine;

[RequireComponent(typeof(CanvasGroup))]
[RequireComponent(typeof(CustomEventTrigger))]
public class UIHudText : MonoBehaviour
{
    public float total_time_;
    public AnimationCurve speed_;
    public AnimationCurve scale_;
    public AnimationCurve alpha_;
    public float time_scale_ = 1;

    float cur_time_ = 0;
    bool is_begin_ = false;
    Vector3 total_offset_;
    Vector3 ui_offset_;
    Vector3 start_pos_;
    Vector3 start_scale_;
    Camera ui_camera_;
    CanvasGroup canvas_group_;
    CustomEventTrigger event_trigger_;
    RectTransform rect_;

    public void ShowHud(Vector3 pos, Vector2 offset)
    {
        this.rect_ = GetComponent<RectTransform>();
        this.ui_camera_ = GameObject.Find("/UICamera").GetComponent<Camera>();
        this.total_offset_ = Vector3.zero;
        this.ui_offset_ = offset;
        this.start_pos_ = pos;
        this.start_scale_ = transform.localScale;
        this.canvas_group_ = GetComponent<CanvasGroup>();
        this.event_trigger_ = GetComponent<CustomEventTrigger>();
        if (WorldToUI(rect_, start_pos_))
        {
            transform.position = start_pos_;
            transform.localPosition += new Vector3(ui_offset_.x, ui_offset_.y, -transform.localPosition.z);
            transform.localScale = start_scale_ * scale_.Evaluate(0);
            canvas_group_.alpha = alpha_.Evaluate(0);
            cur_time_ = 0;
            is_begin_ = true;
        }
        else
        {
            gameObject.SetActive(false);
            event_trigger_.TriggerEvent("");
        }
    }

    void Update()
    {
        if (is_begin_)
        {
            float time = cur_time_ / total_time_;
            total_offset_ += new Vector3(0, speed_.Evaluate(time), 0) * Time.deltaTime * time_scale_;
            if (WorldToUI(rect_, start_pos_) && cur_time_ <= total_time_)
            {
                transform.position = start_pos_ + total_offset_;
                transform.localPosition += new Vector3(ui_offset_.x, ui_offset_.y, -transform.localPosition.z);
                transform.localScale = start_scale_ * scale_.Evaluate(time);
                canvas_group_.alpha = alpha_.Evaluate(time);
                cur_time_ += Time.deltaTime * time_scale_;
            }
            else
            {
                gameObject.SetActive(false);
                event_trigger_.TriggerEvent("");
                is_begin_ = false;
            }
        }
    }

    bool WorldToUI(RectTransform rect, Vector3 pos)
    {
        Vector3 view_point = ui_camera_.WorldToViewportPoint(pos);
        if (view_point.x < 0 || view_point.x > 1 || view_point.y < 0 || view_point.y > 1 || view_point.z < 0)
        {
            return false;
        }
        return true;
    }
}