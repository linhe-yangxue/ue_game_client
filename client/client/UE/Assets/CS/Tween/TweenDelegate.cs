using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Tweening
{
    public delegate void TweenCallback();
    public delegate void TweenCallback<in T>(T value);

    public delegate T DOGetter<out T>();
    public delegate void DOSetter<in T>(T value);
}