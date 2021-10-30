using System;
using UnityEngine;
using SLua;
using System.Reflection;

[ExtendLuaClass(typeof(Physics))]
public class PhysicsManualWrap : LuaObject {
    [UnityEngine.Scripting.Preserve]
    public static void reg(IntPtr l) {
		addMember(l, TraceDown_s);
        addMember(l, GetGoListByRay_s);
		addMember(l, MoveNewPos_s);
		addMember(l, CheckFallDown_s);
        addMember(l, FallDownOffset_s);
		addMember(l, CheckBlock_s);
    }

    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int FallDownOffset_s(IntPtr l) {
        try {
            Vector3 cur_pos;
            checkType(l, 1, out cur_pos);
            Vector3 new_pos;
            checkType(l, 2, out new_pos);
            float radius;
            checkType(l, 3, out radius);
            float height;
            checkType(l, 4, out height);
            int param_layer_mask;
            checkType(l, 5, out param_layer_mask);

            Vector3 dir = new_pos - cur_pos;
            dir.y = 0;
            dir.Normalize();

            bool ret = false;
            RaycastHit hit;
            if (Physics.Raycast(cur_pos - dir * radius, dir, out hit, radius * 2, param_layer_mask)) {
                Vector3 h_pos = hit.point - dir * radius;
                new_pos.x = h_pos.x;
                new_pos.y = h_pos.y;
            }
            float hit_y = new_pos.y;
            if (Physics.Raycast(new_pos + new Vector3(0, height, 0), Vector3.down, out hit, height * 2, param_layer_mask)) {
                ret = true;
                hit_y = hit.point.y;
            }
            pushValue(l, true);
            pushValue(l, ret);
            pushValue(l, new_pos);
            pushValue(l, hit_y);
            return 4;
        } catch(Exception e) {
            return error(l, e);
        }
    }


	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int CheckFallDown_s(IntPtr l) {
		try {
			Vector3 cur_pos;
    		checkType(l, 1, out cur_pos);
    		Vector3 new_pos;
    		checkType(l, 2, out new_pos);
    		float radius;
    		checkType(l, 3, out radius);
    		float height;
			checkType(l, 4, out height);
			int param_layer_mask;
            checkType(l, 5, out param_layer_mask);

			pushValue(l, true);

			Vector3 c_pos1 = new_pos;
			c_pos1.y += height - radius + height;
			Vector3 c_pos2 = new_pos;
			c_pos2.y += radius + height;
			RaycastHit hit;
			float max_trace_len = height * 2;
			Vector3 dir = new_pos - cur_pos;
			if (Physics.CapsuleCast(c_pos2, c_pos1, radius, Vector3.down, out hit, max_trace_len, param_layer_mask)) {
				float down_y = hit.point.y;
				Vector3 up_add = new Vector3(0, height * 2, 0);
				max_trace_len *= 2;
				var quat = Quaternion.LookRotation(hit.normal);
				var n_right = quat * Vector3.right;
				var n_front = Vector3.Cross(n_right, Vector3.up);
				float y1 = down_y;
				float half_radius = radius * 0.5f;
				Vector3 pos1 = n_front * half_radius;
				bool t_ret1 = Physics.CapsuleCast(c_pos2 + pos1 + up_add, c_pos1 + pos1 + up_add, half_radius, Vector3.down, out hit, max_trace_len, param_layer_mask);
				if (!t_ret1) {
					pushValue(l, true);
					pushValue(l, down_y);
					pushValue(l, dir);
					return 4;
				}
				float y2 = hit.point.y;
				float cmp_y = half_radius;
				if (Physics.CapsuleCast(c_pos2 - pos1 + up_add, c_pos1 - pos1 + up_add, half_radius, Vector3.down, out hit, max_trace_len, param_layer_mask)) {
					y1 = hit.point.y;
					cmp_y = radius;
				}
				float delta_y = y1 - y2;
				if (delta_y > cmp_y) {  // > 45 degree
					pushValue(l, true);
					pushValue(l, down_y);
					pushValue(l, n_front);
					pushValue(l, Vector3.Dot(n_front, dir) <= 0);
					return 5;
				}
				pushValue(l, false);
				pushValue(l, down_y);
	            return 3;
            } else {
            	pushValue(l, true);
				pushValue(l, cur_pos.y);
				pushValue(l, dir);
            	return 4;
            }
			/*
			if (Physics.CapsuleCast(c_pos2, c_pos1, radius, Vector3.down, out hit, max_trace_len, param_layer_mask)) {
				float down_y = hit.point.y;
				Vector3 up_add = new Vector3(0, height * 20, 0);
				max_trace_len *= 20;
				var quat = Quaternion.LookRotation(hit.normal);
				var n_right = quat * Vector3.right;
				var n_front = Vector3.Cross(n_right, Vector3.up);
				float y1 = down_y;
                Vector3 pos1 = new_pos + n_front * radius;
				bool t_ret1 = Physics.Raycast(pos1 + up_add, Vector3.down, out hit, max_trace_len, param_layer_mask);
				if (!t_ret1) {
					pushValue(l, true);
					pushValue(l, down_y);
					pushValue(l, dir);
					return 4;
				}
				float y2 = hit.point.y;
				Vector3 pos2 = new_pos - n_front * radius;
				if (Physics.Raycast(pos2 + up_add, Vector3.down, out hit, max_trace_len, param_layer_mask)) {
					y1 = hit.point.y;
				}
				float delta_y = y1 - y2;
				if (delta_y > 2 * radius) {  // > 45 degree
					pushValue(l, true);
					pushValue(l, down_y);
					pushValue(l, n_front);
					pushValue(l, Vector3.Dot(n_front, dir) <= 0);
					return 5;
				}
				pushValue(l, false);
				pushValue(l, down_y);
	            return 3;
            } else {
            	pushValue(l, true);
				pushValue(l, cur_pos.y);
				pushValue(l, dir);
            	return 4;
            }*/

		} catch(Exception e) {
			return error(l, e);
    	}
    }

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int MoveNewPos_s(IntPtr l) {
    	try {
    		Vector3 cur_pos;
    		checkType(l, 1, out cur_pos);
    		Vector3 new_pos;
    		checkType(l, 2, out new_pos);
    		float radius;
    		checkType(l, 3, out radius);
    		float height;
			checkType(l, 4, out height);
			int param_layer_mask;
            checkType(l, 5, out param_layer_mask);
			Vector3 dir = new_pos - cur_pos;
			float dist = dir.magnitude;
			dir.y = 0;
			dir.Normalize();
			Vector3 pos1 = cur_pos;
			pos1.y += height - radius + 0.3f;
			Vector3 pos2 = cur_pos;
			pos2.y += radius + 0.3f;
			RaycastHit hit;
			bool is_block = false;
			if (Physics.CapsuleCast(pos2, pos1, radius, dir, out hit, dist + radius, param_layer_mask)) {
				float slope_cos = Vector3.Dot(Vector3.up, hit.normal);
				Vector3 hit_normal = hit.normal;
				Vector3 hit_point = hit.point;
				Vector3 up_add = new Vector3(0, height * 10, 0);
				float max_trace_len = height * 20;
				var quat = Quaternion.LookRotation(hit.normal);
				var n_right = quat * Vector3.right;
				var n_front = Vector3.Cross(n_right, Vector3.up);
				Vector3 h_pos1 = hit.point - n_front * radius;
				bool t_ret1 = Physics.Raycast(h_pos1 + up_add, Vector3.down, out hit, max_trace_len, param_layer_mask);
				if (t_ret1) {
					slope_cos = (hit.point.y - hit_point.y) > radius ? 0.6f : 0.708f;
				}
				if (slope_cos < 0.7071) {
					Vector3 c_dist = hit_point - cur_pos;
					c_dist.y = 0;
					float df_dot = Vector3.Dot(dir * -1, n_front);
					float cmp_dist = c_dist.magnitude * df_dot;

					Vector3 h_p = hit_point;
					Vector3 c_p = cur_pos;
					h_p.y = 0;
					c_p.y = 0;
					float keep_dist = radius + 0.01f;
					if (cmp_dist < keep_dist) {
						Vector3 b_k = n_front * (keep_dist - cmp_dist);
						cur_pos += b_k;
						pos1 += b_k;
						pos2 += b_k;
					}
					is_block = true;
					// slide calc
					Vector3 slider_dir = new Vector3(hit_normal.z * -1, 0, hit_normal.x);
					if (Vector3.Dot(slider_dir, dir) < 0) {
						slider_dir *= -1;
					}
					slider_dir.y = 0;
					slider_dir.Normalize();
					if (Physics.CapsuleCast(pos2, pos1, radius, slider_dir, out hit, dist + radius, param_layer_mask)) {
						new_pos = cur_pos;
					} else {
						new_pos = cur_pos + slider_dir * Vector3.Dot(slider_dir, dir) * dist;
					}
				}
			}
			pushValue(l, true);
			pushValue(l, is_block);
			pushValue(l, new_pos);
			return 3;
    	} catch(Exception e) {
			return error(l, e);
    	}
    }

    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
	static public int TraceDown_s(IntPtr l) {
        try {
            Vector3 param_pos;
            checkType(l, 1, out param_pos);
            float up_offset = 0;
            checkType(l, 2, out up_offset);
            float down_len = 0;
            checkType(l, 3, out down_len);
            int param_layer_mask;
            checkType(l, 4, out param_layer_mask);
			RaycastHit hit;
			bool ret = false;
			if (Physics.Raycast(param_pos + new Vector3(0, up_offset, 0), Vector3.down, out hit, down_len, param_layer_mask)) {
				ret = true;
                param_pos.y = hit.point.y;
            }
            pushValue(l, true);
			pushValue(l, ret);
			pushValue(l, param_pos.y);
            return 3;
        } catch(Exception e) {
            return error(l, e);
        }
    }

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int CheckBlock_s(IntPtr l)
    {
        try
        {
            Vector3 start_pos;
            checkType(l, 1, out start_pos);
            Vector3 end_pos;
            checkType(l, 2, out end_pos);
            int param_layer_mask;
            checkType(l, 3, out param_layer_mask);
            bool ret = Physics.Linecast(start_pos, end_pos, param_layer_mask);
            pushValue(l, true);
            pushValue(l, ret);
            return 2;
        }
        catch (Exception e)
        {
            return error(l, e);
        }
    }

    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int GetGoListByRay_s(IntPtr l)
    {
        try
        {
            Vector3 param_pos;
            checkType(l, 1, out param_pos);
            pushValue(l, true);
            LuaDLL.lua_newtable(l);
			int param_pay_length;
            checkType(l, 2, out param_pay_length);
            int param_layer_mask;
            checkType(l, 3, out param_layer_mask);
            Ray ray = Camera.main.ScreenPointToRay(param_pos);
            RaycastHit[] hits = Physics.RaycastAll(ray, param_pay_length, param_layer_mask);
            if (hits.Length > 0)
            {
                for (int i = 0; i < hits.Length; ++i)
                {
                    pushValue(l, i + 1);
                    pushValue(l, hits[i].transform.gameObject.GetInstanceID());
                    LuaDLL.lua_settable(l, -3);
                }
            }
            return 2;
	    } catch (Exception e) {
	            return error(l, e);
		}
    }
}
