using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
namespace Tweening
{
    public struct FloatOptions : IPlugOptions
    {
        public bool snapping;

        public void Reset()
        {
            snapping = false;
        }
    }

    public class FloatPlugin : TweenPlugin<float, float, FloatOptions>
    {
        public override void Reset(TweenCore<float, float, FloatOptions> t) { }

        public override void SetFrom(TweenCore<float, float, FloatOptions> t, bool is_relative)
        {
            float pre_end_val = t.end_value_;
            t.end_value_ = t.Getter();
            t.start_value_ = is_relative ? t.end_value_ + pre_end_val : pre_end_val;
            t.Setter(!t.plug_options_.snapping ? t.start_value_ : (float)Math.Round(t.start_value_));
        }

        public override float ConvertToStartValue(TweenCore<float, float, FloatOptions> t, float value)
        {
            return value;
        }

        public override void SetRelativeEndValue(TweenCore<float, float, FloatOptions> t)
        {
            t.end_value_ += t.start_value_;
        }

        public override void SetChangeValue(TweenCore<float, float, FloatOptions> t)
        {
            t.change_value_ = t.end_value_ - t.start_value_;
        }

        public override void EvaluateAndApply(FloatOptions options, Tween t, bool is_relative, DOGetter<float> getter, DOSetter<float> setter, float elapsed, float start_value, float change_value, float duration, bool is_inverse)
        {
            float value = 0;
            if(options.snapping)
            {
                value = (float)Math.Round(start_value + change_value * EaseManager.Evaluate(t.ease_type_, elapsed, duration, t.ease_overshoot_or_amplitude_, t.ease_period_));
            }
            else
            {
                value = start_value + change_value * EaseManager.Evaluate(t.ease_type_, elapsed, duration, t.ease_overshoot_or_amplitude_, t.ease_period_);
            }
            setter(value);
        }
    }
}