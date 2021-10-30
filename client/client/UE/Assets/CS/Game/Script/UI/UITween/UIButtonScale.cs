using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
using Tweening;
using UnityEngine.UI;

public class UIButtonScale : MonoBehaviour, IPointerDownHandler, IPointerUpHandler
{

    public float duration_ = 0.2f;
    public Ease ease_type_ = Ease.Linear;
    public Vector3 press_scale_ = new Vector3(1.2f, 1.2f, 1.2f);
    private Transform rect_comp_;
    private Vector3 start_scale_;
    private Tweener tweener_;

    void Awake()
    {
        rect_comp_ = transform;
        start_scale_ = rect_comp_.localScale;
    }

    public void OnPointerDown(PointerEventData event_data)
    {
        Button btn = GetComponent<Button>();
        if (!btn.interactable)
        {
            return;
        }
        CheckTweener();
        tweener_ = rect_comp_.DOScale(press_scale_, duration_).SetEase(ease_type_);
    }

    public void OnPointerUp(PointerEventData event_data)
    {
        Button btn = GetComponent<Button>();
        if (!btn.interactable)
        {
            return;
        }
        CheckTweener();
        tweener_ = rect_comp_.DOScale(start_scale_, duration_).SetEase(ease_type_);
    }

    void CheckTweener()
    {
        if (tweener_ != null)
        {
            tweener_.Kill();
            tweener_ = null;
        }
    }
    void OnDestroy()
    {
        CheckTweener();
    }
}
