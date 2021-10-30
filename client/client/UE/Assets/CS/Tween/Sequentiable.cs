using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Tweening
{
    public class Sequentiable
    {
        public TweenType tween_type_;
        public float sequenced_pos_;
        public float sequenced_end_pos_;
        public TweenCallback onStart;
    }
}

