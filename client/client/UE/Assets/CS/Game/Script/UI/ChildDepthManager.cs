using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ChildDepthManager : MonoBehaviour {
    public float update_inteval_ = 0.2f;

    private Transform[] child_transform_list_;
	// Use this for initialization
	void Start () {
        InvokeRepeating("UpdateChildDepth", 0, update_inteval_);
	}

    void Swap(int index1, int index2)
    {
        Transform tf = child_transform_list_[index1];
        child_transform_list_[index1] = child_transform_list_[index2];
        child_transform_list_[index2] = tf;
    }

    void UpdateChildDepth()
    {
        child_transform_list_ = new Transform[transform.childCount];
        for (int i = 0; i < transform.childCount; i++)
        {
            child_transform_list_[i] = transform.GetChild(i).GetComponent<Transform>();
        }
        int flag = 0;
        for (int i = 1; i < child_transform_list_.Length; i++)
        {
            if (child_transform_list_[i].position.y <= child_transform_list_[flag].position.y)
            {
                flag++;
                continue;
            }
            Swap(i, flag);
            flag++;
            for (int j = flag - 1; j >= 0; j--)
            {
                if (j == 0)
                {
                    child_transform_list_[j].SetSiblingIndex(j);
                    break;
                }
                if (child_transform_list_[j].position.y > child_transform_list_[j - 1].position.y)
                {
                    Swap(j - 1, j);
                    continue;
                }
                child_transform_list_[j].SetSiblingIndex(j);
                break;
            }
        }
    }
}
