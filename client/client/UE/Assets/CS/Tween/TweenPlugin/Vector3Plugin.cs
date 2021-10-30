using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
namespace Tweening
{
    public struct VectorOptions : IPlugOptions
    {
        public AxisConstraint axis_constraint_;
        public bool snapping_;

        public void Reset()
        {
            axis_constraint_ = AxisConstraint.None;
            snapping_ = false;
        }
    }

    public class Vector3Plugin : TweenPlugin<Vector3, Vector3, VectorOptions>
    {
        public override void Reset(TweenCore<Vector3, Vector3, VectorOptions> t) { }

        public override void SetFrom(TweenCore<Vector3, Vector3, VectorOptions> t, bool is_relative)
        {
            Vector3 pre_end_value = t.end_value_;
            t.end_value_ = t.Getter();
            t.start_value_ = is_relative ? t.end_value_ + pre_end_value : pre_end_value;
            Vector3 to = t.end_value_;
            switch (t.plug_options_.axis_constraint_)
            {
                case AxisConstraint.X:
                    to.x = t.start_value_.x;
                    break;
                case AxisConstraint.Y:
                    to.y = t.start_value_.y;
                    break;
                case AxisConstraint.Z:
                    to.z = t.start_value_.z;
                    break;
                default:
                    to = t.start_value_;
                    break;
            }
            if (t.plug_options_.snapping_)
            {
                to.x = (float)Math.Round(to.x);
                to.y = (float)Math.Round(to.y);
                to.z = (float)Math.Round(to.z);
            }
            t.Setter(to);
        }

        public override Vector3 ConvertToStartValue(TweenCore<Vector3, Vector3, VectorOptions> t, Vector3 value)
        {
            return value;
        }

        public override void SetRelativeEndValue(TweenCore<Vector3, Vector3, VectorOptions> t)
        {
            t.end_value_ += t.start_value_;
        }

        public override void SetChangeValue(TweenCore<Vector3, Vector3, VectorOptions> t)
        {
            switch (t.plug_options_.axis_constraint_)
            {
                case AxisConstraint.X:
                    t.change_value_ = new Vector3(t.end_value_.x - t.start_value_.x, 0, 0);
                    break;
                case AxisConstraint.Y:
                    t.change_value_ = new Vector3(0, t.end_value_.y - t.start_value_.y, 0);
                    break;
                case AxisConstraint.Z:
                    t.change_value_ = new Vector3(0, 0, t.end_value_.z - t.start_value_.z);
                    break;
                default:
                    t.change_value_ = t.end_value_ - t.start_value_;
                    break;
            }
        }

        public override void EvaluateAndApply(VectorOptions options, Tween t, bool is_relative, DOGetter<Vector3> getter, DOSetter<Vector3> setter, float elapsed, Vector3 start_value, Vector3 change_value, float duration, bool is_inverse)
        {
            float ease_val = EaseManager.Evaluate(t.ease_type_, elapsed, duration, t.ease_overshoot_or_amplitude_, t.ease_period_);
            switch (options.axis_constraint_)
            {
                case AxisConstraint.X:
                    Vector3 vector_x = getter();
                    vector_x.x = start_value.x + change_value.x * ease_val;
                    if (options.snapping_) vector_x.x = (float)Math.Round(vector_x.x);
                    setter(vector_x);
                    break;
                case AxisConstraint.Y:
                    Vector3 vector_y = getter();
                    vector_y.y = start_value.y + change_value.y * ease_val;
                    if (options.snapping_) vector_y.y = (float)Math.Round(vector_y.y);
                    setter(vector_y);
                    break;
                case AxisConstraint.Z:
                    Vector3 vector_z = getter();
                    vector_z.z = start_value.z + change_value.z * ease_val;
                    if (options.snapping_) vector_z.z = (float)Math.Round(vector_z.z);
                    setter(vector_z);
                    break;
                default:
                    start_value.x += change_value.x * ease_val;
                    start_value.y += change_value.y * ease_val;
                    start_value.z += change_value.z * ease_val;
                    if (options.snapping_)
                    {
                        start_value.x = (float)Math.Round(start_value.x);
                        start_value.y = (float)Math.Round(start_value.y);
                        start_value.z = (float)Math.Round(start_value.z);
                    }
                    setter(start_value);
                    break;
            }
        }
    }
}