using UnityEngine;

namespace Tweening
{
    public static class TweenSettingExtensions
    {
        public static T OnStart<T>(this T t, TweenCallback action) where T : Tween
        {
            if (t == null || !t.is_active_) return t;

            t.onStart = action;
            return t;
        }

        public static T OnPlay<T>(this T t, TweenCallback action) where T : Tween
        {
            if (t == null || !t.is_active_) return t;

            t.onPlay = action;
            return t;
        }

        public static T OnPause<T>(this T t, TweenCallback action) where T : Tween
        {
            if (t == null || !t.is_active_) return t;

            t.onPause = action;
            return t;
        }

        public static T OnRewind<T>(this T t, TweenCallback action) where T : Tween
        {
            if (t == null || !t.is_active_) return t;

            t.onRewind = action;
            return t;
        }

        public static T OnUpdate<T>(this T t, TweenCallback action) where T : Tween
        {
            if (t == null || !t.is_active_) return t;

            t.onUpdate = action;
            return t;
        }

        public static T OnStepComplete<T>(this T t, TweenCallback action) where T : Tween
        {
            if (t == null || !t.is_active_) return t;

            t.onStepComplete = action;
            return t;
        }

        public static T OnComplete<T>(this T t, TweenCallback action) where T : Tween
        {
            if (t == null || !t.is_active_) return t;

            t.onComplete = action;
            return t;
        }

        public static T OnKill<T>(this T t, TweenCallback action) where T : Tween
        {
            if (t == null || !t.is_active_) return t;

            t.onKill = action;
            return t;
        }

        public static T Pause<T>(this T t) where T : Tween
        {
            if (t == null || !t.is_active_ || t.is_sequenced_)
            {
                return t;
            }
            TweenManager.Pause(t);
            return t;
        }

        public static T Play<T>(this T t) where T : Tween
        {
            if (t == null || !t.is_active_ || t.is_sequenced_)
            {
                return t;
            }
            TweenManager.Play(t);
            return t;
        }

        public static void Restart(this Tween t, bool include_delay = true, float new_delay_time = -1)
        {
            if (t == null || !t.is_active_ || t.is_sequenced_)
            {
                return;
            }
            TweenManager.Restart(t, include_delay, new_delay_time);
        }

        public static void Kill(this Tween t)
        {
            if (t == null || !t.is_active_ || t.is_sequenced_ )
            {
                return;
            }
            if (TweenManager.IsUpdateTweens())
            {
                t.is_active_ = false;
            }
            else
            {
                TweenManager.Despawn(t);
            }
        }

        public static T SetAutoKill<T>(this T t) where T : Tween
        {
            if (t == null || !t.is_active_ || t.is_creat_locked_) return t;

            t.is_auto_kill_ = true;
            return t;
        }

        public static T SetAutoKill<T>(this T t, bool is_auto_kill) where T : Tween
        {
            if (t == null || !t.is_active_ || t.is_creat_locked_) return t;

            t.is_auto_kill_ = is_auto_kill;
            return t;
        }

        public static Tweener SetOptions(this TweenCore<Vector2, Vector2, VectorOptions> t, bool snapping)
        {
            if (t == null || !t.is_active_) return t;
            t.plug_options_.snapping_ = snapping;
            return t;
        }

        public static Tweener SetOptions(this TweenCore<Vector2, Vector2, VectorOptions> t, AxisConstraint axis_constraint, bool snapping)
        {
            if (t == null || !t.is_active_) return t;
            t.plug_options_.snapping_ = snapping;
            t.plug_options_.axis_constraint_ = axis_constraint;
            return t;
        }

        public static Tweener SetOptions(this TweenCore<Vector3, Vector3, VectorOptions> t, bool snapping)
        {
            if (t == null || !t.is_active_) return t;
            t.plug_options_.snapping_ = snapping;
            return t;
        }

        public static Tweener SetOptions(this TweenCore<Vector3, Vector3, VectorOptions> t, AxisConstraint axis_constraint, bool snapping)
        {
            if (t == null || !t.is_active_) return t;
            t.plug_options_.snapping_ = snapping;
            t.plug_options_.axis_constraint_ = axis_constraint;
            return t;
        }

        public static T SetRelative<T>(this T t) where T : Tween
        {
            if (t == null || !t.is_active_ || t.is_creat_locked_ || t.is_from_) return t;
            t.is_relative_ = true;
            return t;
        }

        public static T SetRelative<T>(this T t, bool is_relative) where T : Tween
        {
            if (t == null || !t.is_active_ || t.is_creat_locked_ || t.is_from_) return t;
            t.is_relative_ = is_relative;
            return t;
        }

        public static T From<T>(this T t) where T : Tweener
        {
            if (t == null || !t.is_active_ || t.is_creat_locked_) return t;
            t.SetFrom(false);
            return t;
        }

        public static T From<T>(this T t, bool is_relative) where T : Tweener
        {
            if (t == null || !t.is_active_ || t.is_creat_locked_) return t;
            t.SetFrom(is_relative);
            return t;
        }

        public static T SetEase<T>(this T t, Ease ease) where T : Tween
        {
            if (t == null || !t.is_active_) return t;
            t.ease_type_ = ease;
            return t;
        }

        public static T SetDelay<T>(this T t, float delay) where T : Tween
        {
            if (t == null || !t.is_active_ || t.is_creat_locked_) return t;
            if (t.tween_type_ == TweenType.Sequence)
            {

            }
            else
            {
                t.delay_time_ = delay;
                t.is_complete_delay_ = delay <= 0;
            }
            return t;
        }

        public static T SetLoops<T>(this T t, int loops) where T : Tween
        {
            if (t == null || !t.is_active_ || t.is_creat_locked_) return t;
            if (loops < -1) loops = -1;
            else if (loops == 0) loops = 1;
            t.loops_ = loops;
            if (t.tween_type_ == TweenType.Tweener)
            {
                if (loops > -1)
                {
                    t.full_duration_ = t.duration_ * loops;
                }else{
                    t.full_duration_ = Mathf.Infinity;
                }
            }
            return t;
        }

        public static T SetLoops<T>(this T t, int loops, LoopType loop_type) where T : Tween
        {
            if (t == null || !t.is_active_ || t.is_creat_locked_) return t;

            if (loops < -1) loops = -1;
            else if (loops == 0) loops = 1;
            t.loops_ = loops;
            t.loop_type_ = loop_type;
            if (t.tween_type_ == TweenType.Tweener)
            {
                if (loops > -1)
                {
                    t.full_duration_ = t.duration_ * loops;
                }
                else
                {
                    t.full_duration_ = Mathf.Infinity;
                }
            }
            return t;
        }
    }
}