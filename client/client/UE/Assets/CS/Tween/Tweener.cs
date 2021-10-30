using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Tweening
{
    public abstract class Tweener : Tween
    {
        public bool has_manually_set_value;

        public abstract Tweener SetFrom(bool is_relative);

        public static void Init<T1, T2, TPlugOptions>(TweenCore<T1, T2, TPlugOptions> t, DOGetter<T1> getter, DOSetter<T1> setter, T2 end_value, float duration, TweenPlugin<T1, T2, TPlugOptions> plugin = null) where TPlugOptions : struct, IPlugOptions
        {
            t.Getter = getter;
            t.Setter = setter;
            t.end_value_ = end_value;
            t.duration_ = duration;
            if(plugin==null){
                plugin = TweenPluginManager.GetDefaultPlugin<T1,T2,TPlugOptions>();
            }
            t.tween_plugin_ = plugin;
            t.ease_type_ = Ease.Linear;
            t.loop_type_ = LoopType.Restart;
            t.is_auto_kill_ = true;
            t.is_playing_ = true;
        }

        protected void DoStartup<T1, T2, TPlugOptions>(TweenCore<T1, T2, TPlugOptions> t) where TPlugOptions : struct, IPlugOptions
        {
            t.is_startup_ = true;
            if (!t.has_manually_set_value)
            {
                t.start_value_ = t.tween_plugin_.ConvertToStartValue(t, t.Getter());
            }
            if(t.is_relative_){
                t.tween_plugin_.SetRelativeEndValue(t);
            }
            t.tween_plugin_.SetChangeValue(t);
            // Debug.LogError("start " + t.start_value_);
            // Debug.LogError("change " + t.change_value_);
            // Debug.LogError("end " + t.end_value_);
        }

        protected float DoUpdateDelay<T1, T2, TPlugOptions>(TweenCore<T1, T2, TPlugOptions> t, float delta_time) where TPlugOptions : struct, IPlugOptions
        {
            float delay_time = t.cur_delay_time_ + delta_time;
            if (delay_time > t.delay_time_)
            {
                t.cur_delay_time_ = t.delay_time_;
                t.is_complete_delay_ = true;
                return delay_time - t.delay_time_;
            }
            t.cur_delay_time_ = delay_time;
            return 0;
        }
    }
}