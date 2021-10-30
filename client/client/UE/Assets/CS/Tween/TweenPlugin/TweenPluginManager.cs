using System;
using UnityEngine;

namespace Tweening
{
    public static class TweenPluginManager
    {
        private static ITweenPlugin float_plugin_;
        private static ITweenPlugin vector2_plugin_;
        private static ITweenPlugin vector3_plugin_;
        public static TweenPlugin<T1, T2, TPlugOptions> GetDefaultPlugin<T1, T2, TPlugOptions>() where TPlugOptions : struct, IPlugOptions
        {
            Type t1 = typeof(T1);
            Type t2 = typeof(T2);
            ITweenPlugin plugin = null;
            if (t1 == typeof(float) && t1 == t2)
            {
                if(float_plugin_ == null) float_plugin_ = new FloatPlugin();
                plugin = float_plugin_;
            }
            else if (t1 == typeof(Vector3) && t1 == t2)
            {
                if (vector3_plugin_ == null) vector3_plugin_ = new Vector3Plugin();
                plugin = vector3_plugin_;
            }
            else if(t1 == typeof(Vector2) && t1 == t2)
            {
                if (vector2_plugin_ == null) vector2_plugin_ = new Vector2Plugin();
                plugin = vector2_plugin_;
            }
            if(plugin != null)
            {
                return plugin as TweenPlugin<T1, T2, TPlugOptions>;
            }
            else
            {
                return null;
            }
        }
	}
}
