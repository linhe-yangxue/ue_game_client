using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Tweening
{
    public static class TweenManager
    {
        public static TweenComponent tween_comp_;
        private static bool is_init_ = false;

        private static int MAX_TWEENERS = 50;
        private static int MAX_SEQUENCES = 10;
        private static int total_active_tween_ = 0;
        private static int total_active_tweener_ = 0;
        private static int total_active_sequence_ = 0;

        private static int normal_tween_count_ = 0;
        private static int late_tween_count_ = 0;
        private static int fixed_tween_count_ = 0;
        private static bool is_update_tweens_;

        private static int max_active_id_ = -1;
        private static int reorganize_active_id_ = -1;
        private static bool is_need_reorganize_;

        private static List<Tween> kill_tweens_ = new List<Tween>();

        private static Tween[] active_tweens_ = new Tween[MAX_TWEENERS + MAX_SEQUENCES];

        public static void UpdateTweens(UpdateType update_type, float delta_time)
        {
            if (update_type == UpdateType.Normal && normal_tween_count_ == 0) return;
            else if (update_type == UpdateType.Fixed && fixed_tween_count_ == 0) return;
            else if (update_type == UpdateType.Late && late_tween_count_ == 0) return;
            is_update_tweens_ = true;
            if (is_need_reorganize_) ReorganizeActiveTween();
            bool will_kill = false;
            int count = total_active_tween_;
            for (int i = 0; i < count; i++)
            {
                Tween tween = active_tweens_[i];
                float d_time = delta_time;
                if (tween == null || tween.update_type_ != update_type) continue;
                if (!tween.is_active_)
                {
                    will_kill = true;
                    MarkForKilling(tween);
                    continue;
                }
                if (!tween.is_playing_ || d_time <= 0) continue;
                tween.is_creat_locked_ = true;
                if (!tween.is_complete_delay_)
                {
                    d_time = tween.UpdateDelay(d_time);
                    if (d_time <= 0) continue;
                }
                if (!tween.is_startup_)
                {
                    tween.Startup();
                }
                float target_position = tween.position_;
                bool is_end = target_position >= tween.duration_;
                int target_complete_loops = tween.complete_loops_;
                if (tween.duration_ <= 0)
                {
                    target_position = 0;
                    target_complete_loops = tween.loops_ == -1 ? tween.complete_loops_ + 1 : tween.loops_;
                }
                else
                {
                    if (tween.is_backward_)
                    {
                        target_position -= d_time;
                        while (target_position < 0 && target_complete_loops > -1)
                        {
                            target_position += tween.duration_;
                            target_complete_loops--;
                        }
                        if (target_complete_loops < 0 || is_end && target_complete_loops < 1)
                        {
                            target_position = 0;
                            target_complete_loops = is_end ? 1 : 0;
                        }
                    }
                    else
                    {
                        target_position += d_time;
                        while (target_position >= tween.duration_ && (tween.loops_ == -1 || target_complete_loops < tween.loops_))
                        {
                            target_position -= tween.duration_;
                            target_complete_loops++;
                        }
                    }
                    if (is_end) target_complete_loops--;
                    if (tween.loops_ != -1 && target_complete_loops >= tween.loops_) target_position = tween.duration_;
                }
                bool is_kill = tween.DoGoto(target_position, target_complete_loops);
                if (is_kill)
                {
                    will_kill = true;
                    MarkForKilling(tween);
                }

            }
            if (will_kill)
            {
                foreach (var item in kill_tweens_)
                {
                    Despawn(item);
                }
                kill_tweens_.Clear();
            }
            is_update_tweens_ = false;
        }

        static void MarkForKilling(Tween tween)
        {
            tween.is_active_ = false;
            kill_tweens_.Add(tween);
        }


        static void CheckIncreaseCapacities(bool is_increase_tweener)
        {
            if (total_active_tween_ < MAX_SEQUENCES + MAX_TWEENERS)
            {
                return;
            }
            if (is_increase_tweener)
            {
                MAX_TWEENERS = MAX_TWEENERS * 2;
            }
            else
            {
                MAX_SEQUENCES = MAX_SEQUENCES * 2;
            }
            //Debug.LogError("MAX_TWEENERS:" + MAX_TWEENERS + " MAX_SEQUENCES:" + MAX_SEQUENCES);
            Array.Resize(ref active_tweens_, MAX_TWEENERS + MAX_SEQUENCES);
        }

        public static bool IsUpdateTweens()
        {
            return is_update_tweens_;
        }
        public static TweenCore<T1, T2, TPlugOptions> GetTweener<T1, T2, TPlugOptions>() where TPlugOptions : struct, IPlugOptions
        {
            TweenCore<T1, T2, TPlugOptions> tweener = new TweenCore<T1, T2, TPlugOptions>();
            AddActiveTween(tweener);
            CheckIncreaseCapacities(true);
            return tweener;
        }

        public static Sequence GetSequence()
        {
            Sequence sequence = new Sequence();
            AddActiveTween(sequence);
            CheckIncreaseCapacities(false);
            return sequence;
        }

        public static void Despawn(Tween tween)
        {
            Tween.OnTweenCallback(tween.onKill);
            DelActiveTween(tween);
        }


        static void AddActiveTween(Tween tween)
        {
            if (is_need_reorganize_) ReorganizeActiveTween();
            tween.is_active_ = true;
            tween.update_type_ = UpdateType.Normal;
            tween.active_id_ = max_active_id_ = total_active_tween_;
            active_tweens_[total_active_tween_] = tween;
            switch (tween.update_type_)
            {
                case UpdateType.Normal:
                    normal_tween_count_++;
                    break;
                case UpdateType.Fixed:
                    fixed_tween_count_++;
                    break;
                case UpdateType.Late:
                    late_tween_count_++;
                    break;
                default:
                    normal_tween_count_++;
                    break;
            }
            total_active_tween_++;
            if (tween.tween_type_ == TweenType.Tweener)
            {
                total_active_tweener_++;
            }
            else if (tween.tween_type_ == TweenType.Sequence)
            {
                total_active_sequence_++;
            }

        }

        static void DelActiveTween(Tween tween)
        {
            int index = tween.active_id_;
            switch (tween.update_type_)
            {
                case UpdateType.Normal:
                    normal_tween_count_--;
                    break;
                case UpdateType.Fixed:
                    fixed_tween_count_--;
                    break;
                case UpdateType.Late:
                    late_tween_count_--;
                    break;
                default:
                    normal_tween_count_--;
                    break;
            }
            active_tweens_[index] = null;
            is_need_reorganize_ = true;
            if (reorganize_active_id_ == -1 || reorganize_active_id_ > index)
            {
                reorganize_active_id_ = index;
            }
            if (tween.tween_type_ == TweenType.Tweener)
            {
                total_active_tweener_--;
            }
            else if (tween.tween_type_ == TweenType.Sequence)
            {
                total_active_sequence_--;
            }
            total_active_tween_--;
        }

        static void ReorganizeActiveTween()
        {
            if (total_active_tween_ <= 0)
            {
                max_active_id_ = -1;
                reorganize_active_id_ = -1;
                is_need_reorganize_ = false;
                return;
            }
            else if (reorganize_active_id_ == max_active_id_)
            {
                max_active_id_--;
                reorganize_active_id_ = -1;
                is_need_reorganize_ = false;
                return;
            }
            int shift = 1;
            int len = max_active_id_ + 1;
            max_active_id_ = reorganize_active_id_ - 1;
            for (int i = reorganize_active_id_ + 1; i < len; ++i)
            {
                Tween t = active_tweens_[i];
                if (t == null)
                {
                    shift++;
                    continue;
                }
                t.active_id_ = max_active_id_ = i - shift;
                active_tweens_[i - shift] = t;
                active_tweens_[i] = null;
            }
            reorganize_active_id_ = -1;
            is_need_reorganize_ = false;
        }

        static TweenCore<T1, T2, TPlugOptions> ApplyTo<T1, T2, TPlugOptions>(DOGetter<T1> getter, DOSetter<T1> setter,
                T2 end_value, float duration, TweenPlugin<T1, T2, TPlugOptions> plugin = null) where TPlugOptions : struct, IPlugOptions
        {
            CheckTweenComp();
            TweenCore<T1, T2, TPlugOptions> t = GetTweener<T1, T2, TPlugOptions>();
            Tweener.Init(t, getter, setter, end_value, duration, plugin);
            return t;
        }

        #region Tween TO
        public static TweenCore<Vector2, Vector2, VectorOptions> To(DOGetter<Vector2> getter, DOSetter<Vector2> setter, Vector2 end_value, float duration)
        {
            return ApplyTo<Vector2, Vector2, VectorOptions>(getter, setter, end_value, duration);
        }

        public static TweenCore<Vector3, Vector3, VectorOptions> To(DOGetter<Vector3> getter, DOSetter<Vector3> setter, Vector3 end_value, float duration)
        {
            return ApplyTo<Vector3, Vector3, VectorOptions>(getter, setter, end_value, duration);
        }

        public static TweenCore<float, float, FloatOptions> To(DOGetter<float> getter, DOSetter<float> setter, float end_value, float duration)
        {
            return ApplyTo<float, float, FloatOptions>(getter, setter, end_value, duration);
        }
        #endregion

        #region Play Operations
        public static bool Pause(Tween t)
        {
            if (t.is_playing_)
            {
                t.is_playing_ = false;
                Tween.OnTweenCallback(t.onPause);
                return true;
            }
            return false;
        }

        public static bool Play(Tween t)
        {
            if (!t.is_playing_ && (!t.is_backward_ && !t.is_complete_ || t.is_backward_ && (t.complete_loops_ > 0 || t.position_ > 0)))
            {
                t.is_playing_ = true;
                if (t.is_played_once_ && t.is_complete_delay_)
                {
                    Tween.OnTweenCallback(t.onPlay);
                }
                return true;
            }
            return false;
        }

        public static bool Restart(Tween t, bool include_delay = true, float new_delay_time = -1)
        {
            bool was_paused = !t.is_playing_;
            t.is_backward_ = false;
            if (new_delay_time >= 0) t.delay_time_ = new_delay_time;
            Rewind(t, include_delay);
            t.is_playing_ = true;
            if (was_paused && t.is_played_once_ && t.is_complete_delay_)
            {
                Tween.OnTweenCallback(t.onPlay);
            }
            return true;
        }

        public static bool Rewind(Tween t, bool include_delay = true)
        {
            bool was_playing = t.is_playing_;
            t.is_playing_ = false;
            bool is_rewind = false;
            if (t.delay_time_ > 0)
            {
                if (include_delay)
                {
                    is_rewind = t.delay_time_ > 0 && t.cur_delay_time_ > 0;
                    t.cur_delay_time_ = 0;
                    t.is_complete_delay_ = false;
                }
                else
                {
                    is_rewind = t.cur_delay_time_ < t.delay_time_;
                    t.cur_delay_time_ = t.delay_time_;
                    t.is_complete_delay_ = true;
                }
            }
            if (t.position_ > 0 || t.complete_loops_ > 0 || !t.is_startup_)
            {
                is_rewind = true;
                bool need_kill = t.DoGoto(0, 0, UpdateMode.Goto);
                if (!need_kill && was_playing) Tween.OnTweenCallback(t.onPause);
            }
            return is_rewind;
        }
        #endregion

        static void CheckTweenComp()
        {
            if (is_init_) return;
            TweenComponent.Create();
            is_init_ = true;
        }

        public static void ClearAll()
        {
            for (int i = 0; i < total_active_tweener_; ++i)
            {
                Tween t = active_tweens_[i];
                if (t != null)
                {
                    Despawn(t);
                }
            }
            kill_tweens_.Clear();
            normal_tween_count_ = late_tween_count_ = fixed_tween_count_ = total_active_tween_ = total_active_tweener_ = total_active_sequence_ = 0;
            max_active_id_ = reorganize_active_id_ = -1;
            is_init_ = false;
            TweenComponent.DestroyInstance();
        }

    }
}