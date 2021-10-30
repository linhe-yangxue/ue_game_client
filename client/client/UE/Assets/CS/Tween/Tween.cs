using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Tweening
{
    public abstract class Tween : Sequentiable
    {
        public TweenCallback onPlay;
        public TweenCallback onPause;
        public TweenCallback onRewind;
        public TweenCallback onUpdate;
        public TweenCallback onStepComplete;
        public TweenCallback onComplete;
        public TweenCallback onKill;

        public int active_id_ = -1;
        public int loops_;
        public int complete_loops_;
        public float delay_time_;
        public float cur_delay_time_;
        public float position_;
        public float duration_;
        public float full_duration_;
        public bool is_auto_kill_;
        public bool is_active_;
        public bool is_from_;
        public bool is_playing_;
        public bool is_complete_;
        public bool is_sequenced_;
        public bool is_backward_;
        public bool is_played_once_;
        public bool is_relative_;
        public bool is_startup_;
        public bool is_creat_locked_;
        public bool is_complete_delay_;
        public Ease ease_type_;
        public LoopType loop_type_;
        public UpdateType update_type_;
        public Type type1_;
        public Type type2_;
        public Type type_plug_options_;
        public Sequence sequence_parent_;

        //后偏移缓动值
        public float ease_overshoot_or_amplitude_ = 1.70158f;
        //前偏移缓动值
        public float ease_period_ = 0;

        protected virtual void Reset()
        {
            is_playing_ = is_complete_ = is_backward_ = is_relative_ = is_sequenced_ = is_creat_locked_ = is_from_ = false;
            onStart = onPlay = onRewind = onUpdate = onComplete = onStepComplete = onKill = null;
            delay_time_ = duration_ = position_ = complete_loops_ = 0;
            is_complete_delay_ = true;
            loops_ = 1;
        }

        public virtual float UpdateDelay(float delta_time) { return 0;}
        protected abstract bool ApplyTween(float pre_position, int pre_completedloops, int completed_steps, bool is_inverse);
        public abstract void Startup();
        public bool DoGoto(float target_pos, int target_completed_loops, UpdateMode update_mode = UpdateMode.Update)
        {
            if (!is_startup_)
            {
                Startup();
            }
            if (!is_played_once_ && update_mode == UpdateMode.Update)
            {
                is_played_once_ = true;
                if (onStart != null)
                {
                    OnTweenCallback(onStart);
                    if (!is_active_) return true;
                }
                if (onPlay != null)
                {
                    OnTweenCallback(onPlay);
                    if (!is_active_) return true;
                }
            }

            float pre_posistion = position_;
            int pre_completedloops = complete_loops_;
            complete_loops_ = target_completed_loops;
            bool was_rewinded = pre_posistion <= 0 && pre_completedloops <= 0;
            bool was_complete = is_complete_;
            if (loops_ != -1) is_complete_ = complete_loops_ == loops_;
            int completed_steps = 0;
            if (update_mode == UpdateMode.Update)
            {
                if (is_backward_)
                {
                    completed_steps = complete_loops_ < pre_completedloops ? pre_completedloops - complete_loops_ : (target_pos <= 0 && !was_rewinded ? 1 : 0);
                }
                else
                {
                    completed_steps = complete_loops_ > pre_completedloops ? complete_loops_ - pre_completedloops : 0;
                }
            }
            // else if (t.tweenType == TweenType.Sequence)
            // {
            //     completed_steps = prevCompletedLoops - target_completed_loops;
            //     if (completed_steps < 0) completed_steps = -completed_steps;
            // }
            position_ = target_pos;
            if (position_ > duration_)
            {
                position_ = duration_;
            }
            else if (position_ <= 0)
            {
                if (complete_loops_ > 0 || is_complete_)
                {
                    position_ = duration_;
                }
                else
                {
                    position_ = 0;
                }
            }
            bool was_playing = is_playing_;
            if (is_playing_)
            {
                if(is_backward_)
                {
                    is_playing_ = !(complete_loops_ == 0 && position_ <= 0);
                }
                else
                {
                    is_playing_ = !is_complete_;
                }
            }
            bool is_inverse = loop_type_ == LoopType.Yoyo && (position_ < duration_ ? complete_loops_ % 2 != 0 : complete_loops_ % 2 == 0);
            ApplyTween(pre_posistion, pre_completedloops, completed_steps, is_inverse);
            if(update_mode != UpdateMode.IgnoreOnUpdate)
            {
                OnTweenCallback(onUpdate);
            }
            if(position_ <= 0 && complete_loops_ <= 0 && !was_rewinded){
                OnTweenCallback(onRewind);
            }
            if(completed_steps > 0 && update_mode == UpdateMode.Update){
                OnTweenCallback(onStepComplete);
            }
            if(is_complete_ && ! was_complete && update_mode != UpdateMode.IgnoreOnComplete){
                OnTweenCallback(onComplete);
            }
            if(!is_playing_ && was_playing && (!is_complete_ || !is_auto_kill_)){
                OnTweenCallback(onPause);
            }
            return is_auto_kill_ && is_complete_;
        }

        public static void OnTweenCallback(TweenCallback call_back)
        {
            if (call_back != null)
            {
                call_back();
            }
        }
    }
}
