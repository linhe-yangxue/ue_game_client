using UnityEngine;
using System.Collections;
using System.Collections.Generic;

[DisallowMultipleComponent]
public class UITemplate : MonoBehaviour
{

#if UNITY_EDITOR
    [HideInInspector] public string guid_ = "";
    [HideInInspector] [System.NonSerialized] public List<GameObject> search_prefabs = new List<GameObject>();
    public void InitGUID()
    {
        if (guid_ == "")
        {
            guid_ = System.DateTime.Now.Ticks.ToString();
        }
    }
#endif

}