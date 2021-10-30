using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UIAnimScrollBg : MonoBehaviour
{

    public RectTransform bg1;
    public RectTransform bg2;
    public float speed = 0.5f;
    private float move_delta;
    float bg1PosX;//bg1初始位置X轴的值
    float bg2PosX;//bg2初始位置X轴的值
    void Start()
    {
        bg1PosX = bg1.anchoredPosition.x;
        bg2PosX = bg2.anchoredPosition.x;
    }
    void Update()
    {
        move_delta = -1 * Time.deltaTime * Screen.width * speed;
        bg1.anchoredPosition += new Vector2(move_delta, 0);
        bg2.anchoredPosition += new Vector2(move_delta, 0);
        if (bg2.anchoredPosition.x - bg1PosX < 0)
        {
            bg1.anchoredPosition += new Vector2(bg2PosX - bg1PosX, 0);
            bg2.anchoredPosition += new Vector2(bg2PosX - bg1PosX, 0);
        }
    }
}
