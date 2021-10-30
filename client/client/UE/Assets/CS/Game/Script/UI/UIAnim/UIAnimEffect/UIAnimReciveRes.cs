using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class UIAnimReciveRes : BaseUIAnimEffect
{
    [Rename("x轴位移曲线")]
    public AnimationCurve x_curve_;
    [Rename("y轴位移曲线")]
    public AnimationCurve y_curve_;
    [Rename("生成sprite总时间")]
    public float init_sprite_time_;
    [Rename("开始移动时间")]
    public float start_move_time_;
    [Rename("结束移动需要的时间")]
    public float move_time_;
    [Rename("生成sprite数量")]
    public int init_sprite_num_;
    [Rename("要生成的sprite")]
    public Sprite init_ui_sprite_;
    [Rename("结束位置")]
    public Vector3 target_pos_;
    [Rename("生成范围")]
    public Vector2 init_rect_;

    List<ParticleSprite> _cur_particle_list_;

    private float _start_show_time_;
    private GameObject _templet_;
    private int _cur_create_count_;
    private bool _is_finish_create_;
    private float _start_init_time_;

    private Vector3 _m_pos;
    private Vector3 _actual_target_pos_;

    public void Init(Vector3 target_pos)
    {
        SetActualTargetPos(target_pos);
    }

    public override void OnEnable()
    {
        if (_cur_particle_list_ == null)
        {
            _cur_particle_list_ = new List<ParticleSprite>();
        }
        _templet_ = transform.Find("Temp").gameObject;
        SetActualTargetPos(target_pos_);
        Reset();
    }

    private void SetActualTargetPos(Vector3 target_pos)
    {
        _m_pos = GetComponent<RectTransform>().anchoredPosition3D;
        _actual_target_pos_ = target_pos - _m_pos;
    }

    public override void Update()
    {
        base.Update();
        _start_show_time_ += deltaTime;
        CreateParticle();

        if (_is_finish_create_ && _cur_particle_list_.Count == 0)
        {
            StopEditorRun();
            return;
        }
        for (int i = _cur_particle_list_.Count - 1; i >= 0; i--)
        {
            ParticleSprite move_obj = _cur_particle_list_[i];
            float ui_move_time = _start_show_time_ - move_obj.start_move_time_;
            if (ui_move_time > 0)
            {
                float lerp_x_val = x_curve_.Evaluate(ui_move_time / move_time_);
                float lerp_y_val = y_curve_.Evaluate(ui_move_time / move_time_);
                Vector3 obj_start_pos = _cur_particle_list_[i].start_pos_;
                float x = Mathf.Lerp(obj_start_pos.x, _actual_target_pos_.x, lerp_x_val);
                float y = Mathf.Lerp(obj_start_pos.y, _actual_target_pos_.y, lerp_y_val);
                move_obj.SetPosition(new Vector2(x, y));

                if (lerp_x_val > 0.97f && lerp_y_val > 0.97f)
                {
                    DestroyGo(move_obj.obj_.gameObject);
                    _cur_particle_list_.RemoveAt(i);
                }
            }
        }
    }

    private void CreateParticle()
    {
        if (_start_init_time_ == -1)
        {
            _start_init_time_ = _start_show_time_;
        }
        if (_is_finish_create_)
        {
            return;
        }
        if (_cur_create_count_ < init_sprite_num_)
        {
            int need_create_num;
            float pass_time = _start_show_time_ - _start_init_time_;
            if (init_sprite_time_ <= 0)
            {
                need_create_num = init_sprite_num_;
            }
            else
            {
                float temp = (float)init_sprite_num_ * (pass_time / init_sprite_time_);
                need_create_num = (int)temp;
            }
            need_create_num = need_create_num > init_sprite_num_ ? init_sprite_num_ : need_create_num;
            if (_cur_create_count_ < need_create_num)
            {
                int create_num = need_create_num - _cur_create_count_;
                for (int i = 0; i < create_num; i++)
                {
                    _cur_create_count_++;
                    CreateUIObj();
                }
            }
        }
        else
        {
            _is_finish_create_ = true;
        }
    }

    private RectTransform CreateUIObj()
    {
        RectTransform ret;
        ret = CreateObj<RectTransform>(_templet_);
        ret.GetComponent<Image>().sprite = init_ui_sprite_;
        ret.gameObject.SetActive(true);
        ret.anchoredPosition = new Vector2(Random.Range(-init_rect_.x, init_rect_.x), Random.Range(-init_rect_.y, init_rect_.y));
        ParticleSprite particle = new ParticleSprite(ret, ret.anchoredPosition, _start_show_time_ + start_move_time_);
        _cur_particle_list_.Add(particle);
        return ret;
    }


    public override void OnDisable()
    {
        for (int i = _cur_particle_list_.Count - 1; i >= 0; i--)
        {
            DestroyGo(_cur_particle_list_[i].obj_.gameObject);
        }
        _cur_particle_list_.Clear();
        SetIsRunning(false);
        Reset();
    }

    private void Reset()
    {
        _start_show_time_ = 0;
        _cur_create_count_ = 0;
        _is_finish_create_ = false;
        _start_init_time_ = -1;
    }

    public class ParticleSprite
    {
        public RectTransform obj_;
        public Vector3 start_pos_;
        public float start_move_time_;

        public void SetPosition(Vector3 pos)
        {
            obj_.anchoredPosition = pos;
        }

        public ParticleSprite(RectTransform obj, Vector3 pos, float start_move_time)
        {
            this.obj_ = obj;
            this.start_pos_ = pos;
            this.start_move_time_ = start_move_time;
        }
    }
}