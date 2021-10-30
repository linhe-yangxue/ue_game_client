using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class UICaptureScreen : MonoBehaviour
{

    private Texture2D texture_2d_;
    private Coroutine cur_co_;
    private bool is_shoot_;

    public bool IsShoot()
    {
        return is_shoot_;
    }

    public Texture2D GetTexture()
    {
        return texture_2d_;
    }

    public void StartScreenShoot()
    {
        if (cur_co_ == null)
        {
            texture_2d_ = null;
            is_shoot_ = false;
            cur_co_ = StartCoroutine(ScreenShoot());
        }
    }

    IEnumerator ScreenShoot()
    {
        yield return new WaitForEndOfFrame();
        texture_2d_ = new Texture2D(Screen.width, Screen.height, TextureFormat.RGB24, false);
        texture_2d_.ReadPixels(new Rect(0, 0, Screen.width, Screen.height), 0, 0);
        texture_2d_.Apply();
        is_shoot_ = true;
        cur_co_ = null;
    }
}
