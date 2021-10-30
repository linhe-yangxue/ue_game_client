using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Tweening
{
    public static class EaseManager
    {
        private const float half_pi_ = Mathf.PI * 0.5f;
        private const float two_pi_ = Mathf.PI * 2;
        public static float Evaluate(Ease easeType, float time, float duration, float overshoot_or_amplitude, float period)
        {
            switch (easeType) {
            case Ease.Linear:
                return time / duration;
            case Ease.InSine:
                return -(float)Math.Cos(time / duration * half_pi_) + 1;
            case Ease.OutSine:
                return (float)Math.Sin(time / duration * half_pi_);
            case Ease.InOutSine:
                return -0.5f * ((float)Math.Cos(Mathf.PI * time / duration) - 1);
            case Ease.InQuad:
                return (time /= duration) * time;
            case Ease.OutQuad:
                return -(time /= duration) * (time - 2);
            case Ease.InOutQuad:
                if ((time /= duration * 0.5f) < 1) return 0.5f * time * time;
                return -0.5f * ((--time) * (time - 2) - 1);
            case Ease.InCubic:
                return (time /= duration) * time * time;
            case Ease.OutCubic:
                return ((time = time / duration - 1) * time * time + 1);
            case Ease.InOutCubic:
                if ((time /= duration * 0.5f) < 1) return 0.5f * time * time * time;
                return 0.5f * ((time -= 2) * time * time + 2);
            case Ease.InQuart:
                return (time /= duration) * time * time * time;
            case Ease.OutQuart:
                return -((time = time / duration - 1) * time * time * time - 1);
            case Ease.InOutQuart:
                if ((time /= duration * 0.5f) < 1) return 0.5f * time * time * time * time;
                return -0.5f * ((time -= 2) * time * time * time - 2);
            case Ease.InQuint:
                return (time /= duration) * time * time * time * time;
            case Ease.OutQuint:
                return ((time = time / duration - 1) * time * time * time * time + 1);
            case Ease.InOutQuint:
                if ((time /= duration * 0.5f) < 1) return 0.5f * time * time * time * time * time;
                return 0.5f * ((time -= 2) * time * time * time * time + 2);
            case Ease.InExpo:
                return (time == 0) ? 0 : (float)Math.Pow(2, 10 * (time / duration - 1));
            case Ease.OutExpo:
                if (time == duration) return 1;
                return (-(float)Math.Pow(2, -10 * time / duration) + 1);
            case Ease.InOutExpo:
                if (time == 0) return 0;
                if (time == duration) return 1;
                if ((time /= duration * 0.5f) < 1) return 0.5f * (float)Math.Pow(2, 10 * (time - 1));
                return 0.5f * (-(float)Math.Pow(2, -10 * --time) + 2);
            case Ease.InCirc:
                return -((float)Math.Sqrt(1 - (time /= duration) * time) - 1);
            case Ease.OutCirc:
                return (float)Math.Sqrt(1 - (time = time / duration - 1) * time);
            case Ease.InOutCirc:
                if ((time /= duration * 0.5f) < 1) return -0.5f * ((float)Math.Sqrt(1 - time * time) - 1);
                return 0.5f * ((float)Math.Sqrt(1 - (time -= 2) * time) + 1);
            case Ease.InElastic:
                float s0;
                if (time == 0) return 0;
                if ((time /= duration) == 1) return 1;
                if (period == 0) period = duration * 0.3f;
                if (overshoot_or_amplitude < 1) {
                    overshoot_or_amplitude = 1;
                    s0 = period / 4;
                } else s0 = period / two_pi_ * (float)Math.Asin(1 / overshoot_or_amplitude);
                return -(overshoot_or_amplitude * (float)Math.Pow(2, 10 * (time -= 1)) * (float)Math.Sin((time * duration - s0) * two_pi_ / period));
            case Ease.OutElastic:
                float s1;
                if (time == 0) return 0;
                if ((time /= duration) == 1) return 1;
                if (period == 0) period = duration * 0.3f;
                if (overshoot_or_amplitude < 1) {
                    overshoot_or_amplitude = 1;
                    s1 = period / 4;
                } else s1 = period / two_pi_ * (float)Math.Asin(1 / overshoot_or_amplitude);
                return (overshoot_or_amplitude * (float)Math.Pow(2, -10 * time) * (float)Math.Sin((time * duration - s1) * two_pi_ / period) + 1);
            case Ease.InOutElastic:
                float s;
                if (time == 0) return 0;
                if ((time /= duration * 0.5f) == 2) return 1;
                if (period == 0) period = duration * (0.3f * 1.5f);
                if (overshoot_or_amplitude < 1) {
                    overshoot_or_amplitude = 1;
                    s = period / 4;
                } else s = period / two_pi_ * (float)Math.Asin(1 / overshoot_or_amplitude);
                if (time < 1) return -0.5f * (overshoot_or_amplitude * (float)Math.Pow(2, 10 * (time -= 1)) * (float)Math.Sin((time * duration - s) * two_pi_ / period));
                return overshoot_or_amplitude * (float)Math.Pow(2, -10 * (time -= 1)) * (float)Math.Sin((time * duration - s) * two_pi_ / period) * 0.5f + 1;
            case Ease.InBack:
                return (time /= duration) * time * ((overshoot_or_amplitude + 1) * time - overshoot_or_amplitude);
            case Ease.OutBack:
                return ((time = time / duration - 1) * time * ((overshoot_or_amplitude + 1) * time + overshoot_or_amplitude) + 1);
            case Ease.InOutBack:
                if ((time /= duration * 0.5f) < 1) return 0.5f * (time * time * (((overshoot_or_amplitude *= (1.525f)) + 1) * time - overshoot_or_amplitude));
                return 0.5f * ((time -= 2) * time * (((overshoot_or_amplitude *= (1.525f)) + 1) * time + overshoot_or_amplitude) + 2);
            case Ease.InBounce:
                return InBounce(time, duration);
            case Ease.OutBounce:
                return OutBounce(time, duration);
            case Ease.InOutBounce:
                return InOutBounce(time, duration);


            // case Ease.Flash:
            //     return Flash.Ease(time, duration, overshoot_or_amplitude, period);
            // case Ease.InFlash:
            //     return Flash.EaseIn(time, duration, overshoot_or_amplitude, period);
            // case Ease.OutFlash:
            //     return Flash.EaseOut(time, duration, overshoot_or_amplitude, period);
            // case Ease.InOutFlash:
            //     return Flash.EaseInOut(time, duration, overshoot_or_amplitude, period);
            default:
                return time / duration;
            }
        }

        public static float InBounce(float time, float duration)
        {
            return 1 - OutBounce(duration - time, duration);
        }


        public static float OutBounce(float time, float duration)
        {
            if ((time /= duration) < (1 / 2.75f))
            {
                return (7.5625f * time * time);
            }
            if (time < (2 / 2.75f))
            {
                return (7.5625f * (time -= (1.5f / 2.75f)) * time + 0.75f);
            }
            if (time < (2.5f / 2.75f))
            {
                return (7.5625f * (time -= (2.25f / 2.75f)) * time + 0.9375f);
            }
            return (7.5625f * (time -= (2.625f / 2.75f)) * time + 0.984375f);
        }

        public static float InOutBounce(float time, float duration)
        {
            if (time < duration * 0.5f)
            {
                return InBounce(time * 2, duration) * 0.5f;
            }
            return OutBounce(time * 2 - duration, duration) * 0.5f + 0.5f;
        }
    }
}

