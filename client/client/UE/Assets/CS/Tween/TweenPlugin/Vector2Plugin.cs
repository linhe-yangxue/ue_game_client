using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
namespace Tweening
{
    public class Vector2Plugin : TweenPlugin<Vector2, Vector2, VectorOptions>
    {
        public override void Reset(TweenCore<Vector2, Vector2, VectorOptions> t) { }

        public override void SetFrom(TweenCore<Vector2, Vector2, VectorOptions> t, bool is_relative)
        {
            Vector2 pre_end_value = t.end_value_;
            t.end_value_ = t.Getter();
            t.start_value_ = is_relative ? t.end_value_ + pre_end_value : pre_end_value;
            Vector2 to = t.end_value_;
            switch (t.plug_options_.axis_constraint_)
            {
                case AxisConstraint.X:
                    to.x = t.start_value_.x;
                    break;
                case AxisConstraint.Y:
                    to.y = t.start_value_.y;
                    break;
                default:
                    to = t.start_value_;
                    break;
            }
            if (t.plug_options_.snapping_)
            {
                to.x = (float)Math.Round(to.x);
                to.y = (float)Math.Round(to.y);
            }
            t.Setter(to);
        }

        public override Vector2 ConvertToStartValue(TweenCore<Vector2, Vector2, VectorOptions> t, Vector2 value)
        {
            return value;
        }

        public override void SetRelativeEndValue(TweenCore<Vector2, Vector2, VectorOptions> t)
        {
            t.end_value_ += t.start_value_;
        }

        public override void SetChangeValue(TweenCore<Vector2, Vector2, VectorOptions> t)
        {
            switch (t.plug_options_.axis_constraint_)
            {
                case AxisConstraint.X:
                    t.change_value_ = new Vector2(t.end_value_.x - t.start_value_.x, 0);
                    break;
                case AxisConstraint.Y:
                    t.change_value_ = new Vector2(0, t.end_value_.y - t.start_value_.y);
                    break;
                default:
                    t.change_value_ = t.end_value_ - t.start_value_;
                    break;
            }
        }

        public override void EvaluateAndApply(VectorOptions options, Tween t, bool is_relative, DOGetter<Vector2> getter, DOSetter<Vector2> setter, float elapsed, Vector2 start_value, Vector2 change_value, float duration, bool is_inverse)
        {
            float ease_val = EaseManager.Evaluate(t.ease_type_, elapsed, duration, t.ease_overshoot_or_amplitude_, t.ease_period_);
            switch (options.axis_constraint_)
            {
                case AxisConstraint.X:
                    Vector2 vector_x = getter();
                    vector_x.x = start_value.x + change_value.x * ease_val;
                    if (options.snapping_) vector_x.x = (float)Math.Round(vector_x.x);
                    setter(vector_x);
                    break;
                case AxisConstraint.Y:
                    Vector2 vector_y = getter();
                    vector_y.y = start_value.y + change_value.y * ease_val;
                    if (options.snapping_) vector_y.y = (float)Math.Round(vector_y.y);
                    setter(vector_y);
                    break;
                default:
                    start_value.x += change_value.x * ease_val;
                    start_value.y += change_value.y * ease_val;
                    if (options.snapping_)
                    {
                        start_value.x = (float)Math.Round(start_value.x);
                        start_value.y = (float)Math.Round(start_value.y);
                    }
                    setter(start_value);
                    break;
            }
        }
    }
}