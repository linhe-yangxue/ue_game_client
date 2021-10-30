using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using SLua;
public class UITaskScrub : MonoBehaviour  {
    [DoNotToLua]
    public Canvas canvas;
    [DoNotToLua]
    public RawImage mask_pic_image;
    [DoNotToLua]
    public RawImage brush_image;
    
    private RectTransform brush_rect;
    private RectTransform mask_pic_rect;
    private float[] brush_alpha;
    private Color32[] all_color;
    private Color32[] default_all_color;
    private float scrub_pixel_count = 0;
    private int total_pixel_count = 0;
    private Texture2D new_mask_pic = null;
    void Awake()
    {
        if (new_mask_pic == null)
        {
            new_mask_pic = new Texture2D(mask_pic_image.texture.width, mask_pic_image.texture.height);
            default_all_color = (mask_pic_image.texture as Texture2D).GetPixels32();
            for(int i = 0;i< default_all_color.Length; ++i)
            {
                if (default_all_color[i].a > 0) ++total_pixel_count;
            }
            new_mask_pic.SetPixels32(default_all_color);
            new_mask_pic.Apply();
            mask_pic_image.texture = new_mask_pic;
        }
        mask_pic_rect = mask_pic_image.GetComponent<RectTransform>();
        brush_rect = brush_image.GetComponent<RectTransform>();
        Texture2D brush_t = brush_image.texture as Texture2D;
        int brush_width =(int) brush_rect.sizeDelta.x;
        int brush_height = (int)brush_rect.sizeDelta.y;
        brush_alpha = new float[brush_width * brush_height];
        for (int x =0;x< brush_width; ++x)
        {
            for(int y = 0; y < brush_height; ++y)
            {
                Vector2 pixel_pos = GetPixelPos(brush_t, brush_rect, x, y);
                int index = y * brush_width + x;
                brush_alpha[index] = brush_t.GetPixel((int)pixel_pos.x, (int)pixel_pos.y).a;
            }
        }
        // Texture2D mask_t = mask_pic_image.texture as Texture2D;
        all_color = new Color32[default_all_color.Length];
    }
    private void RecoverMask()
    {
        Texture2D mask_t = mask_pic_image.texture as Texture2D;
        default_all_color.CopyTo(all_color, 0);
        mask_t.SetPixels32(all_color);
        mask_t.Apply();
    }
    private Vector2 GetPixelPos(Texture2D t,RectTransform rect,float ui_x,float ui_y)
    {
        Vector2 pixel_v = new Vector2();
        pixel_v.x = ui_x * (t.width / rect.sizeDelta.x);
        pixel_v.y = ui_y * (t.height / rect.sizeDelta.y);
        pixel_v.x = Mathf.Clamp(pixel_v.x, 0, t.width -1);
        pixel_v.y = Mathf.Clamp(pixel_v.y, 0, t.height-1);
        return pixel_v;
    }
    public void Init()
    {
        RecoverMask();
        scrub_pixel_count = 0;
    }
    public void UpdateMaskPic(Vector2 touch_point)
    {
        Vector2 local_pos;
        if(RectTransformUtility.ScreenPointToLocalPointInRectangle(mask_pic_rect,touch_point, canvas.worldCamera, out local_pos))
        {
            int brush_width =(int) brush_rect.sizeDelta.x;
            int brush_height =(int) brush_rect.sizeDelta.y;
            Vector2 start_pos = new Vector2(local_pos.x - brush_width / 2 , local_pos.y - brush_height / 2 );
            //debug
            //Vector3 world_pos = canvas.worldCamera.ScreenToWorldPoint(touch_point);
            //brush_rect.position = new Vector3(world_pos.x, world_pos.y, canvas.transform.position.z);
            Vector2 mask_v = new Vector2();
            Texture2D texture2d = mask_pic_image.texture as Texture2D;
            Vector2 pixel_pos = new Vector2();
            int color_index = 0;
            int alpha_index = 0;
            for(int x = 0;x < brush_width; ++x)
            {
                for(int y = 0; y < brush_height; ++y)
                {
                    mask_v.x = x + start_pos.x;
                    mask_v.y = y + start_pos.y;
                    pixel_pos = GetPixelPos(texture2d, mask_pic_rect, mask_v.x, mask_v.y);
                    color_index = (int)pixel_pos.x + (int)pixel_pos.y * texture2d.width;
                    Color mask_color = all_color[color_index];
                    alpha_index = y * brush_width + x;
                    float alpha = brush_alpha[alpha_index];
                    if (mask_color.a > 0 && mask_color.a - alpha <= 0) ++scrub_pixel_count;
                    mask_color.a = mask_color.a - alpha;
                    all_color[color_index] = mask_color;
                }
            }
            texture2d.SetPixels32(all_color);
            texture2d.Apply();
        }
    }
    public float GetScrubPercent()
    {
        float percent = scrub_pixel_count / total_pixel_count;
        return percent;
    }
}
