using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Tweening
{
    public class Sequence : Tween
    {

        private List<Tween> tweens_list_ = new List<Tween>();
        private List<Sequentiable> sequentiable_list_ = new List<Sequentiable>();
        private float last_tween_insert_time_;

        public Sequence(){
            tween_type_ = TweenType.Sequence;
            Reset();
        }

        protected override void Reset()
        {
            base.Reset();
            tweens_list_.Clear();
            sequentiable_list_.Clear();
            last_tween_insert_time_ = 0;
        }

        public override void Startup()
        {
            DoStartup(this);
        }

        private bool DoStartup(Sequence s)
        {
            s.is_startup_ = true;
            s.full_duration_ = s.loops_ > - 1 ? s.duration_ * s.loops_ : Mathf.Infinity;
            s.sequentiable_list_.Sort(SortSequentiable);
            if (s.is_relative_)
            {
                int len = s.tweens_list_.Count;
                for (int i = 0; i < len; i++)
                {
                    s.tweens_list_[i].is_relative_ = true;
                }
            }
            return true;
        }


        protected override bool ApplyTween(float pre_postion, int pre_completed_loops, int completed_steps, bool is_inverse)
        {
            return false;
        }

        static int SortSequentiable(Sequentiable a, Sequentiable b)
        {
            if (a.sequenced_pos_ > b.sequenced_pos_) return 1;
            if (a.sequenced_pos_ < b.sequenced_pos_) return -1;
            return 0;
        }

    }

}
