using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Tweening
{
    public enum UpdateType
    {
        Normal,
        Late,
        Fixed,
    }

    public enum TweenType
    {
        Tweener,
        Sequence,
        Callback,
    }

    public enum LoopType
    {
        Restart,
        Yoyo,
    }

    public enum Ease
    {
        Linear,
        InSine,
        OutSine,
        InOutSine,
        InQuad,
        OutQuad,
        InOutQuad,
        InCubic,
        OutCubic,
        InOutCubic,
        InQuart,
        OutQuart,
        InOutQuart,
        InQuint,
        OutQuint,
        InOutQuint,
        InExpo,
        OutExpo,
        InOutExpo,
        InCirc,
        OutCirc,
        InOutCirc,
        InElastic,
        OutElastic,
        InOutElastic,
        InBack,
        OutBack,
        InOutBack,
        InBounce,
        OutBounce,
        InOutBounce,

        // Flash, 
        // InFlash, 
        // OutFlash, 
        // InOutFlash,
    }

    public enum AxisConstraint
    {
        None,
        X,
        Y,
        Z,
        W,
    }

    public enum UpdateMode
    {
        Update,
        Goto,
        IgnoreOnUpdate,
        IgnoreOnComplete
    }
}