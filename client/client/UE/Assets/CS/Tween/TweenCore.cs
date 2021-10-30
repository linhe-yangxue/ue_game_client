using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Tweening
{
    public class TweenCore<T1, T2, TPlugOptions> : Tweener where TPlugOptions : struct, IPlugOptions{
        public T2 start_value_, end_value_, change_value_;
        public TPlugOptions plug_options_;
        public TweenPlugin<T1, T2, TPlugOptions> tween_plugin_;
        public DOGetter<T1> Getter;
        public DOSetter<T1> Setter;

        public TweenCore()
        {
            type1_ = typeof(T1);
            type2_ = typeof(T2);
            type_plug_options_ = typeof(TPlugOptions);
            tween_type_ = TweenType.Tweener;
            Reset();
        }

        protected override void Reset()
        {
            base.Reset();
            if (tween_plugin_ != null) tween_plugin_.Reset(this);
            plug_options_.Reset();
            Getter = null;
            Setter = null;
            has_manually_set_value = false;
        }

        public override void Startup()
        {
            DoStartup(this);
        }

        public override float UpdateDelay(float delta_time)
        {
            return DoUpdateDelay(this, delta_time);
        }

        protected override bool ApplyTween(float pre_postion, int pre_completed_loops, int completed_steps, bool is_inverse)
        {
            float update_pos = is_inverse ? duration_ - position_ : position_;
            tween_plugin_.EvaluateAndApply(plug_options_, this, is_relative_, Getter, Setter, update_pos, start_value_, change_value_, duration_, is_inverse);
            return false;
        }

        public override Tweener SetFrom(bool is_relative)
        {
            is_from_ = true;
            tween_plugin_.SetFrom(this, is_relative);
            has_manually_set_value = true;
            return this;
        }
    }
}