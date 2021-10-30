using System.Collections;
using System.Collections.Generic;
using UnityEngine;
[RequireComponent(typeof(Animator))]
public class UIControlAnim : MonoBehaviour
{
    public float runing_time_ = 0;
    public float anim_speed_ = 1;
    private Animator _animator_ = null;
    private float _pass_time_ = 0;
    private bool _is_anim_end_ = false; 
    // Use this for initialization
    void Start()
    {
        _animator_ = GetComponent<Animator>();
        if (_animator_ == null)
        {
            Debug.LogError(gameObject.name + " don't have Animator component");
            Destroy(this);
            return;
        }
        _animator_.enabled = true;
        _is_anim_end_ = false;
        _pass_time_ = 0;
    }
    void Update()
    {
        if (_is_anim_end_) return;
        _animator_.speed = anim_speed_;
        _pass_time_ += Time.deltaTime;
        if (_pass_time_ >= runing_time_)
        {
            _animator_.enabled = false;
            _is_anim_end_ = true;
            return;
        }
    }
}
