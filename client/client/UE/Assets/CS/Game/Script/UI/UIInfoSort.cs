using UnityEngine;
using System.Collections.Generic;

public class UIInfoSort : MonoBehaviour
{
    private float interval_time_ = 0.5f;
    private float cur_time_;
    private List<Transform> trans_list = new List<Transform>();
    private Dictionary<Transform, Vector3> pos_dic_ = new Dictionary<Transform, Vector3>();

    void Awake()
    {
        cur_time_ = interval_time_;
    }

    void Update()
    {
        if (cur_time_ <= 0)
        {
            cur_time_ = interval_time_;
            var cam = Camera.main;
            if (cam == null)
            {
                return;
            }
            for (int i = 0; i < transform.childCount; i++)
            {
                Transform tran = transform.GetChild(i);
                if (!tran.gameObject.activeSelf) continue;
                trans_list.Add(tran);
                pos_dic_.Add(tran, cam.WorldToScreenPoint(tran.position));
            }
            trans_list.Sort(delegate (Transform t1, Transform t2)
            {
                Vector3 v1 = pos_dic_[t1];
                Vector3 v2 = pos_dic_[t2];
                return v2.z.CompareTo(v1.z);
            });
            foreach (var tran in trans_list)
            {
                tran.SetAsLastSibling();
            }
            trans_list.Clear();
            pos_dic_.Clear();
        }
        else
        {
            cur_time_ -= Time.deltaTime;
        }
    }
}
