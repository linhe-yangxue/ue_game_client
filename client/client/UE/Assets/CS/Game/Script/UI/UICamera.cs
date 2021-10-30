using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UICamera : MonoBehaviour
{
    bool enable_fog;

    void OnPreRender() {
        enable_fog = RenderSettings.fog;
        RenderSettings.fog = false;
    }

    void OnPostRender() {
        RenderSettings.fog = enable_fog;
    }
}
