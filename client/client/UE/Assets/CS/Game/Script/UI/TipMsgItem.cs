using UnityEngine;
using System.Collections;
using UnityEngine.UI;

public class TipMsgItem : MonoBehaviour
{

    public float total_time;
    public AnimationCurve speed;
    public AnimationCurve scale;
    public AnimationCurve alpha;

    private CanvasGroup canvas_group;
    private float cur_time = 0;
    private bool is_begin = false;
    private Vector3 start_scale;
    private CustomEventTrigger eventTrigger;
    private RectTransform rect_comp;
    private RectTransform content;
    private float move_speed = 0;
    private float cur_offset = 0;
    private float target_offset = 0;

    public void Show(float speed)
    {
        eventTrigger = GetComponent<CustomEventTrigger>();
        canvas_group = GetComponent<CanvasGroup>();
        if (canvas_group == null)
        {
            canvas_group = gameObject.AddComponent<CanvasGroup>();
            canvas_group.blocksRaycasts = false;
            canvas_group.interactable = false;
        }
        canvas_group.alpha = 0;
        rect_comp = GetComponent<RectTransform>();
        content = rect_comp.Find("Content").GetComponent<RectTransform>();
        content.anchoredPosition = Vector2.zero;
        start_scale = transform.localScale;
        cur_time = 0;
        target_offset = 0;
        cur_offset = 0;
        is_begin = true;
        move_speed = speed;
    }

    public void SetTargetOffset(float offset)
    {
        target_offset = target_offset + offset;
    }

    void FixedUpdate()
    {
        if (is_begin)
        {
            if (cur_offset < target_offset)
            {
                float delta = move_speed * Time.deltaTime;
                cur_offset = cur_offset + delta;
                if (cur_offset >= target_offset)
                {
                    rect_comp.anchoredPosition3D = new Vector3(0, target_offset, 0);
                }
                else
                {
                    rect_comp.anchoredPosition3D = new Vector3(0, cur_offset, 0);
                }
            }
            float time = cur_time / total_time;
            content.anchoredPosition3D += new Vector3(0, speed.Evaluate(time), 0);
            rect_comp.localScale = start_scale * scale.Evaluate(time);
            canvas_group.alpha = alpha.Evaluate(time);
            cur_time += Time.deltaTime;
            if (cur_time >= total_time)
            {
                eventTrigger.TriggerEvent("");
                is_begin = false;
                return;
            }
        }
    }
}
