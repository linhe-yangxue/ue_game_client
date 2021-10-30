using UnityEngine;

namespace Tweening
{
    public static class TweenExtensions
    {
        //COMMON BEGIN
        public static Tweener DOMove(this Transform target, Vector3 end_value, float duration)
        {
            return TweenManager.To(() => target != null ? target.position : end_value, x => { if (target != null) target.position = x; }, end_value, duration);
        }

        public static Tweener DOMoveX(this Transform target, float end_value, float duration)
        {
            return TweenManager.To(() => target != null ? target.position : new Vector3(end_value, 0, 0), x => { if (target != null) target.position = x; }, new Vector3(end_value, 0, 0), duration).SetOptions(AxisConstraint.X, false);
        }

        public static Tweener DOMoveY(this Transform target, float end_value, float duration)
        {
            return TweenManager.To(() => target != null ? target.position : new Vector3(0, end_value, 0), x => { if (target != null) target.position = x; }, new Vector3(0, end_value, 0), duration).SetOptions(AxisConstraint.Y, false);
        }

        public static Tweener DOMoveZ(this Transform target, float end_value, float duration)
        {
            return TweenManager.To(() => target != null ? target.position : new Vector3(0, 0, end_value), x => { if (target != null) target.position = x; }, new Vector3(0, 0, end_value), duration).SetOptions(AxisConstraint.Z, false);
        }

        public static Tweener DOScale(this Transform target, Vector3 end_value, float duration)
        {
            return TweenManager.To(() => target != null ? target.localScale : end_value, x => { if (target != null) target.localScale = x; }, end_value, duration);
        }

        public static Tweener DOScale(this Transform target, float end_value, float duration)
        {
            return TweenManager.To(() => target != null ? target.localScale : end_value * Vector3.one, x => { if (target != null) target.localScale = x; }, end_value * Vector3.one, duration);
        }
        //COMMON END


        // UGUI BEGIN
        public static Tweener DOAnchorPos(this RectTransform target, Vector2 end_value, float duration)
        {
            return TweenManager.To(() => target != null ? target.anchoredPosition : end_value, x => { if (target != null) target.anchoredPosition = x; }, end_value, duration);
        }

        public static Tweener DOAnchorPosX(this RectTransform target, float end_value, float duration)
        {
            return TweenManager.To(() => target != null ? target.anchoredPosition : new Vector2(end_value, 0), x => { if (target != null) target.anchoredPosition = x; }, new Vector2(end_value, 0), duration).SetOptions(AxisConstraint.X, false);
        }

        public static Tweener DOAnchorPosY(this RectTransform target, float end_value, float duration)
        {
            return TweenManager.To(() => target != null ? target.anchoredPosition : new Vector2(0, end_value), x => { if (target != null) target.anchoredPosition = x; }, new Vector2(0, end_value), duration).SetOptions(AxisConstraint.Y, false);
        }

        public static Tweener DOAnchorPos3D(this RectTransform target, Vector3 end_value, float duration)
        {
            return TweenManager.To(() => target != null ? target.anchoredPosition3D : end_value, x => { if (target != null) target.anchoredPosition3D = x; }, end_value, duration);
        }

        public static Tweener DOFade(this CanvasGroup target, float end_value, float duration)
        {
            return TweenManager.To(() => target != null ? target.alpha : end_value, x => { if (target != null) target.alpha = x; }, end_value, duration);
        }
        // UGUI END
    }
}