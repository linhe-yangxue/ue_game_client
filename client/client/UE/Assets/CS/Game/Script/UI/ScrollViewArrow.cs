using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
public class ScrollViewArrow : MonoBehaviour
{
    ScrollRect scrollrect;
    public Image left_arrow;
    public Image right_arrow;
    public float chang_time = 1f;
    private float position;
    private float timer = 0;
    private bool is_show_arrow = true;
    private bool is_show_left = true;
    private bool is_show_right = true;
    public Color original_color = Color.white;
    public Color target_color = new Color(Color.white.r, Color.white.g, Color.white.b, Color.white.a * 0.6f);
    private bool is_content_smaller;
    private bool is_fade = true;

    public bool Is_show_arrow
    {
        get
        {
            return is_show_arrow;
        }

        set
        {
            if (is_show_arrow != value)
            {
                is_show_arrow = value;
                SetArrowActive(left_arrow, value);
                SetArrowActive(right_arrow, value);
            }
        }
    }
    // Use this for initialization
    void Start () {
        scrollrect = GetComponent<ScrollRect>();
        SetArrowActive(left_arrow, false);
        SetArrowActive(right_arrow, false);
    }
    private void Update()
    {
        if(scrollrect.vertical)
            Is_show_arrow = scrollrect.viewport.rect.height < scrollrect.content.rect.height;
        else
            Is_show_arrow = scrollrect.viewport.rect.width < scrollrect.content.rect.width;
        if (!Is_show_arrow)
            return;
        WrapContent();
        if (is_fade)
            timer = timer + Time.deltaTime;
        else
            timer = timer - Time.deltaTime;
        if (timer >= chang_time)
            is_fade = false;
        if (timer <= 0)
            is_fade = true;
        Color color = Color.Lerp(original_color, target_color, timer / chang_time);
        SetArrowColor(left_arrow, color);
        SetArrowColor(right_arrow, color);
    }
    void WrapContent()
    {
        position = scrollrect.vertical ? scrollrect.verticalNormalizedPosition : scrollrect.horizontalNormalizedPosition;
        is_show_left = position > 0.01 ? true : false;
        SetArrowActive(left_arrow, is_show_left);
        is_show_right = position < 0.99 ? true : false;
        SetArrowActive(right_arrow, is_show_right);
    }
    void SetArrowColor(Image image, Color color)
    {
        if (image != null && image.gameObject.activeSelf)
            image.color = color;
    }
    void SetArrowActive(Image image, bool is_show)
    {
        if (image != null)
            image.gameObject.SetActive(is_show);
    }
}
