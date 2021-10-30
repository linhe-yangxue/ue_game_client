using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Tweening
{
	public abstract class TweenPlugin<T1, T2, TPlugOptions>: ITweenPlugin where TPlugOptions : struct, IPlugOptions
	{
		public abstract void Reset(TweenCore<T1, T2, TPlugOptions> t);
		public abstract void SetFrom(TweenCore<T1, T2, TPlugOptions> t, bool is_relative);
		public abstract T2 ConvertToStartValue(TweenCore<T1, T2, TPlugOptions> t, T1 value);
		public abstract void SetRelativeEndValue(TweenCore<T1, T2, TPlugOptions> t);
		public abstract void SetChangeValue(TweenCore<T1, T2, TPlugOptions> t);
		public abstract void EvaluateAndApply(TPlugOptions options, Tween t, bool is_relative, DOGetter<T1> getter, DOSetter<T1> setter, float elapsed, T2 startValue, T2 changeValue, float duration, bool is_inverse);
	}
}