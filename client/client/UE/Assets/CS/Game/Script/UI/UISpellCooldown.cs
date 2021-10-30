using UnityEngine;
using UnityEngine.UI;

public class UISpellCooldown : MonoBehaviour {


    GameObject mask_;
    GameObject num_;
    Image cd_img_;
    Image small_cd_img_;
    Text num_text_;
    bool is_init_ = false;
    bool is_start_cd = false;

    float max_count_;
    float cur_count_;
    float cd_;
    float cur_cd_;
    float combo_cd_;

    public bool is_spell = true;
    public bool is_add = false;

    void Awake()
    {
        _Init();

    }

    void _Init()
    {
        if(is_spell){
            mask_ = transform.Find("Mask").gameObject;
            num_ = transform.Find("Num").gameObject;
            num_text_ = transform.Find("Num/Text").GetComponent<Text>();
            small_cd_img_ = transform.Find("Num/CD").GetComponent<Image>();
        }
        cd_img_ = transform.Find("CD").GetComponent<Image>();
        is_init_ = true;
    }


    void Update()
    {
        if (is_spell)
        {
            if (cur_count_ >= max_count_ && combo_cd_ <= 0) return;
            if (cur_cd_ > 0)
            {
                cur_cd_ -= Time.deltaTime;
                if (cur_cd_ <= 0)
                {
                    cur_count_++;
                    if (cur_count_ == max_count_)
                    {
                        cur_cd_ = 0;
                    }
                }
            }
            if (combo_cd_ > 0)
            {
                combo_cd_ -= Time.deltaTime;
                if (combo_cd_ <= 0)
                {
                    combo_cd_ = 0;
                }
            }
        }
        else
        {
            if (!is_start_cd)
            {
                return;
            }
            if (!is_add)
            {
                if (cur_cd_ > 0)
                {
                    cur_cd_ -= Time.deltaTime;
                    if (cur_cd_ <= 0)
                    {
                        cur_cd_ = 0;
                        is_start_cd = false;
                    }
                }
            }
            else {
                if (cur_cd_ < cd_)
                {
                    cur_cd_ += Time.deltaTime;
                    if (cur_cd_ >= cd_)
                    {
                        is_start_cd = false;
                        cur_cd_ = cd_;
                    }
                }
            }
        }
        
        UpdateCooldown();
	}

    void UpdateCooldown()
    {
        if (is_spell)
        {
            num_.SetActive(max_count_ > 1);
            num_text_.text = cur_count_.ToString();
            mask_.SetActive(combo_cd_ != 0);
            small_cd_img_.fillAmount = cur_cd_ > 0 && cur_count_ > 0 ? cur_cd_/cd_ : 0 ;
        }
        cd_img_.fillAmount = cur_cd_ > 0 && cur_count_ == 0 ? cur_cd_ / cd_ : 0;
    }

    public void SetCooldown(int max_count, int cur_count, float cd, float cur_cd, float combo_cd)
    {
        if (!is_init_) _Init();
        this.max_count_ = max_count;
        this.cur_count_ = cur_count;
        this.cd_ = cd;
        this.cur_cd_ = cur_cd;
        this.combo_cd_ = combo_cd;
        this.is_start_cd = true;
        UpdateCooldown();
    }

    public void SetCooldown(float cd, float cur_cd)
    {
        if (!is_init_) _Init();
        this.is_start_cd = true;
        this.cd_ = cd; 
        this.cur_cd_ = cur_cd;
        if (is_add)
        {
            this.cur_cd_ = cd_ - cur_cd_;
        }
        UpdateCooldown();
    }
}
