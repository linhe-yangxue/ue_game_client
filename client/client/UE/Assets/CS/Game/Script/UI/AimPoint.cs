using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
public class AimPoint : MonoBehaviour {
    public float move_speed_rate = 1f;
    public float shoot_anim_time = 1f;
    public float max_radius_rate = 1.5f;
    private float crit_radius;
    private float hit_radius;
    private float max_radius;// 最大移动范围倍率
    private float move_speed;
    public RectTransform aim;
    private float sqr_distance;
    float sqr_crit_radius;
    float sqr_hit_radius;
    float sqr_max_radius;
    public GameObject hit_circle;
    public GameObject crit_circle;
    private Vector2 move_dir;
    private bool is_shooting = false;
    public bool is_reload = false;
    public bool is_auto_shoot = false;
    public float max_shoot_cool_time = 2;
    private float next_shoot_remain_time = 0;
    public Button shoot_btn;
    public Image cool_down_image;
    public GameObject reload_tip;
    public GameObject shoot_gun;
    public GameObject shoot_ready;
    public GameObject shoot_hide_go;
    private bool Is_shooting
    {
        get
        {
            return is_shooting;
        }
        set
        {

            is_shooting = value;
            shoot_hide_go.SetActive(!value);
            shoot_gun.SetActive(value);
            aim.gameObject.SetActive(!value);
        }
    }
    public UIAnimScrollBg[] scroll_bgs;
    private bool is_scroll_bg_runing;
    private bool is_stop_bg = false;
    public float stop_bg_time = 0.8f;
    private float stop_bg_timer = 0;
    public bool Is_scroll_bg_runing
    {
        get
        {
            return is_scroll_bg_runing;
        }

        set
        {
            is_scroll_bg_runing = value;
            if (!value)
            {
                stop_bg_timer = stop_bg_time;
            }
            for (int i = 0;i< scroll_bgs.Length;i++)
            {
                scroll_bgs[i].enabled = value;
            }
        }
    }

    enum ShootType{
        Miss = 1,
        Hit = 2,
        Crit = 3,
        Reload = 4,
    }
	void Start () {
        aim.anchoredPosition = RandomVector2InRadius(max_radius);
        move_dir = RandomVector2();
        crit_radius = crit_circle.GetComponent<RectTransform>().rect.width / 2;
        hit_radius = hit_circle.GetComponent<RectTransform>().rect.width / 2;
        max_radius = hit_radius * 1.5f;
        move_speed = max_radius * move_speed_rate;
        UpdateSqrValue();
        Reset();
    }
	void UpdateSqrValue()
    {
        sqr_crit_radius = crit_radius * crit_radius;
        sqr_hit_radius = hit_radius * hit_radius;
        sqr_max_radius = max_radius * max_radius;
    }
	void Update () {
        if (!is_shooting)
        {
            aim.anchoredPosition = aim.anchoredPosition + move_dir * Time.deltaTime * move_speed;
            sqr_distance = Vector2.SqrMagnitude(aim.anchoredPosition);
            if (sqr_distance >= sqr_max_radius)
            {
                float x = Random.Range(0f, 1f);
                float y = Random.Range(0f, 1f);
                if (aim.anchoredPosition.x > 0)
                    x = -x;
                if (aim.anchoredPosition.y > 0)
                    y = -y;
                move_dir.x = x;
                move_dir.y = y;
                move_dir = move_dir.normalized;
            }
            if (sqr_distance <= sqr_hit_radius)
            {
                hit_circle.SetActive(true);
                if (sqr_distance <= sqr_crit_radius)
                    crit_circle.SetActive(true);
                else
                    crit_circle.SetActive(false);
            }
            else
                hit_circle.SetActive(false);
            if (is_reload)
            {
                next_shoot_remain_time = next_shoot_remain_time - Time.deltaTime;
                if (next_shoot_remain_time <= 0)
                {
                    is_reload = false;
                    cool_down_image.fillAmount = 0;
                    reload_tip.SetActive(false);
                    shoot_ready.SetActive(true);
                }
                else
                    cool_down_image.fillAmount = next_shoot_remain_time / (max_shoot_cool_time - shoot_anim_time);

            }
            if (!is_reload &&is_auto_shoot)
            {
                if (sqr_distance < sqr_hit_radius)
                {
                    shoot_btn.onClick.Invoke();
                    next_shoot_remain_time = max_shoot_cool_time;
                }
            }
            if (!is_scroll_bg_runing)
            {
                stop_bg_timer -= Time.deltaTime;
                if (stop_bg_timer <= 0)
                    Is_scroll_bg_runing = true;
            }
        }
    }
    Vector2 RandomVector2()
    {
        return RandomVector2InRadius(1).normalized;
    }
    Vector2 RandomVector2InRadius(float radius)
    {
        return new Vector2(Random.Range(-radius, radius), Random.Range(-radius, radius));
    }
    public int Shoot()
    {
        if (is_reload)
            return (int)ShootType.Reload;
        PlayShootAnim();
        sqr_distance = Vector2.SqrMagnitude(aim.anchoredPosition);
        is_reload = true;
        next_shoot_remain_time = max_shoot_cool_time;
        reload_tip.SetActive(true);
        if (sqr_distance <= sqr_hit_radius)
        {
            is_stop_bg = true;
            if (sqr_distance <= sqr_crit_radius)
                return (int)ShootType.Crit;
            else
                return (int)ShootType.Hit;
        }
        else
        {
            is_stop_bg = false;
            return (int)ShootType.Miss;
        }
    }
    void PlayShootAnim()
    {
        Is_shooting = true;
        shoot_ready.SetActive(false);
        Invoke("CanShoot", shoot_anim_time);
    }
    public void CanShoot()
    {
        Is_shooting = false;
        if(is_stop_bg == true)
            Is_scroll_bg_runing = false;
    }
    public void Reset()
    {
        cool_down_image.fillAmount = 0;
        Is_scroll_bg_runing = true;
        is_reload = false;
        is_shooting = false;
        shoot_hide_go.SetActive(true);
        shoot_gun.SetActive(false);
        shoot_ready.SetActive(true);
        reload_tip.SetActive(false);
    }
}
