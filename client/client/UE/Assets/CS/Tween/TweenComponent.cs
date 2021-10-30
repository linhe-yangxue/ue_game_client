using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Tweening
{
    public class TweenComponent : MonoBehaviour
    {
        public float time_scale_ = 1;
        void Update()
        {
            TweenManager.UpdateTweens(UpdateType.Normal, Time.deltaTime * time_scale_);
        }

        void LateUpdate()
        {
            TweenManager.UpdateTweens(UpdateType.Late, Time.deltaTime * time_scale_);
        }

        void FixedUpdate()
        {
            TweenManager.UpdateTweens(UpdateType.Fixed, Time.fixedDeltaTime * time_scale_);
        }

        public static void Create()
        {
            if (TweenManager.tween_comp_ != null) return;
            GameObject go = new GameObject("TweenGo");
            DontDestroyOnLoad(go);
            TweenManager.tween_comp_ = go.AddComponent<TweenComponent>();
        }

        public static void DestroyInstance()
        {
            if (TweenManager.tween_comp_ != null) Destroy(TweenManager.tween_comp_.gameObject);
            TweenManager.tween_comp_ = null;
        }

    }
}