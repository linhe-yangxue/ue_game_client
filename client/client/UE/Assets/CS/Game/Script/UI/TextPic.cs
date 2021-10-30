using System;
using System.Collections.Generic;
using System.Text;
using System.Text.RegularExpressions;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

/// <summary>
/// 利用Text富文本的quad保留图片位置 再通过网格顶点的位置得到图片应放置的位置
/// （插入图片参考：http://blog.csdn.net/akof1314/article/details/49028279）
/// 
/// 利用IPointerClickHandler接口的OnPointerClick判断是否点击在指定区域实现点击文本事件
/// （插入超链接参考：http://blog.csdn.net/akof1314/article/details/49077983）
/// 
/// </summary>
public class TextPic : Text, IPointerClickHandler, IPointerDownHandler
{
    /// <summary>
    /// 图片的最后一个顶点的索引
    /// </summary>
    private readonly List<int> img_vertex_index_ = new List<int>();

    /// <summary>
    /// 正则取出所需要的图片信息
    /// </summary>
    private static readonly Regex img_id_regex_ =
          new Regex(@"<quad id=(.+?) size=(.+?)/>", RegexOptions.Singleline);

    /// <summary>
    /// 保存的图片位置
    /// </summary>
    private List<float> img_pos_list_;
    public float[] ImgPosList { get { return img_pos_list_.ToArray(); } }

    /// <summary>
    /// 更新图片位置的回调
    /// </summary>
    public delegate void NoParamCallBack();
    public NoParamCallBack PopulateMeshCallBack;

    /// <summary>
    /// 更新图片标志
    /// </summary>
    private bool update_img_flag_;

    /// <summary>
    /// 超链接信息类
    /// </summary>
    private class HrefInfo
    {
        public int StartIndex;

        public int EndIndex;

        public string Key;

        public readonly List<Rect> Boxes = new List<Rect>();
    }

    /// <summary>
    /// 超链接信息列表
    /// </summary>
    /// 
    private readonly List<HrefInfo> href_infos_ = new List<HrefInfo>();

    /// <summary>
    /// 超链接正则
    /// </summary>
    private static readonly Regex href_regex_ =
        new Regex(@"<a href=([^>\n\s]+)>(.*?)</a>", RegexOptions.Singleline);

    /// <summary>
    /// 超链接点击事件
    /// </summary>
    public delegate void StringParamCallBack(string key);
    public StringParamCallBack ClickHrefCallBack;

    /// <summary>
    /// 设置文本 并返回图片信息
    /// </summary>
    /// <param name="value"></param>
    /// <returns></returns>
    public string[] SetTextPicValue(string value)
    {
        text = value;
        if (img_pos_list_ == null) img_pos_list_ = new List<float>();
        else img_pos_list_.Clear();
        update_img_flag_ = false;
        GetHrefInfoList();
        return GetQuadImageList();
    }

    public int[] GetImageSize()
    {
        List<int> img_size_list = new List<int>();
        int picIndex;
        int endIndex;
        int size;
        foreach (Match match in img_id_regex_.Matches(text))
        {
            picIndex = match.Index;
            endIndex = picIndex * 4 + 3;
            img_vertex_index_.Add(endIndex);
            size = int.Parse(match.Groups[2].Value);
            img_size_list.Add(size);
        }
        return img_size_list.ToArray();
    }

    /// <summary>
    /// 获取文本内图片信息
    /// </summary>
    /// <returns></returns>
    protected string[] GetQuadImageList()
    {
        img_vertex_index_.Clear();
        List<string> img_id_list = new List<string>();
        int picIndex;
        int endIndex;
        string pic_id;
        foreach (Match match in img_id_regex_.Matches(text))
        {
            picIndex = match.Index;
            endIndex = picIndex * 4 + 3;

            img_vertex_index_.Add(endIndex);
            pic_id = match.Groups[1].Value;
            img_id_list.Add(pic_id);
        }
        return img_id_list.ToArray();
    }

    /// <summary>
    /// 获取超链接解析后(去掉超链接标记)的输出文本
    /// </summary>
    /// <returns></returns>
    protected void GetHrefInfoList()
    {
        StringBuilder s_TextBuilder = new StringBuilder();
        int indexText = 0;
        href_infos_.Clear();
        foreach (Match match in href_regex_.Matches(text))
        {
            s_TextBuilder.Append(text.Substring(indexText, match.Index - indexText));

            href_infos_.Add(new HrefInfo()
            {
                StartIndex = s_TextBuilder.Length * 4, // 超链接里的文本起始顶点索引
                EndIndex = (s_TextBuilder.Length + match.Groups[2].Length - 1) * 4 + 3,
                Key = match.Groups[1].Value,
            });
            s_TextBuilder.Append(match.Groups[2].Value);
            indexText = match.Index + match.Length;
        }
        s_TextBuilder.Append(text.Substring(indexText, text.Length - indexText));
        text = s_TextBuilder.ToString();
    }

    /// <summary>
    /// 点击事件检测是否点击到超链接文本
    /// </summary>
    /// <param name="eventData"></param>
    public void OnPointerClick(PointerEventData eventData)
    {
        Vector2 lp;
        RectTransformUtility.ScreenPointToLocalPointInRectangle(
            rectTransform, eventData.position, eventData.pressEventCamera, out lp);

        List<Rect> boxes;
        foreach (HrefInfo hrefInfo in href_infos_)
        {
            boxes = hrefInfo.Boxes;
            for (int i = 0; i < boxes.Count; ++i)
            {
                if (boxes[i].Contains(lp))
                {
                    if (ClickHrefCallBack != null) ClickHrefCallBack(hrefInfo.Key);
                    return;
                }
            }
        }
    }

    public string[] SetTextWithEllipsis(string value)
    {
        string[] img_id_list = SetTextPicValue(value);
        string str = text;
        TextGenerator tg = cachedTextGeneratorForLayout;
        Vector2 size = gameObject.GetComponent<RectTransform>().rect.size;
        TextGenerationSettings tgs = GetGenerationSettings(size);
        tg.Populate(str, tgs);
        int visible_character_count = tg.characterCountVisible;
        if (str.Length > visible_character_count)
        {
            foreach (Match match in img_id_regex_.Matches(text))
            {
                int picIndex = match.Index;
                if (picIndex >= visible_character_count)
                {
                    str = str.Substring(0, picIndex - match.Length);
                    break;
                }
            }
            if (str.Length > visible_character_count)
                str = str.Substring(0, visible_character_count - 1);
            text = str + "...";
            return GetQuadImageList();
        }
        return img_id_list;
    }

    /// <summary>
    /// 文本渲染刷新时
    /// 把图片位置记录下来
    /// 把图片点抹掉
    /// 记录超链接位置给点击事件判断
    /// </summary>
    /// <param name="toFill"></param>
    protected override void OnPopulateMesh(VertexHelper toFill)
    {
        base.OnPopulateMesh(toFill);
        UIVertex vert = new UIVertex();
        Vector3 pos;
        if (img_pos_list_ != null)
        {
            for (int i = 0; i < img_vertex_index_.Count; i++)
            {
                int endIndex = img_vertex_index_[i];
                if (endIndex < toFill.currentVertCount)
                {
                    // 记录位置
                    if (!update_img_flag_)
                    {
                        toFill.PopulateUIVertex(ref vert, endIndex);
                        img_pos_list_.Add(vert.position.x);
                        img_pos_list_.Add(vert.position.y);
                    }

                    // 抹掉左下角的小黑点 （quad渲染出来的内容）
                    toFill.PopulateUIVertex(ref vert, endIndex - 3);
                    pos = vert.position;
                    for (int j = endIndex, m = endIndex - 3; j > m; j--)
                    {
                        toFill.PopulateUIVertex(ref vert, endIndex);
                        vert.position = pos;
                        toFill.SetUIVertex(vert, j);
                    }
                }
            }
            if (!update_img_flag_ && img_pos_list_.Count > 0)
            {
                if (PopulateMeshCallBack != null) PopulateMeshCallBack();
                update_img_flag_ = true;
            }
        }

        // 处理超链接包围框
        Bounds bounds;
        foreach (HrefInfo hrefInfo in href_infos_)
        {
            hrefInfo.Boxes.Clear();
            if (hrefInfo.StartIndex >= toFill.currentVertCount)
            {
                continue;
            }
            // 将超链接里面的文本顶点索引坐标加入到包围框
            toFill.PopulateUIVertex(ref vert, hrefInfo.StartIndex);
            pos = vert.position;
            bounds = new Bounds(pos, Vector3.zero);
            for (int i = hrefInfo.StartIndex + 1, m = hrefInfo.EndIndex; i < m; i++)
            {
                if (i >= toFill.currentVertCount)
                {
                    break;
                }

                toFill.PopulateUIVertex(ref vert, i);
                pos = vert.position;
                if (pos.x <= bounds.min.x) // 换行重新添加包围框
                {
                    hrefInfo.Boxes.Add(new Rect(bounds.min, bounds.size));
                    bounds = new Bounds(pos, Vector3.zero);
                }
                else
                {
                    bounds.Encapsulate(pos); // 扩展包围框
                }
            }
            hrefInfo.Boxes.Add(new Rect(bounds.min, bounds.size));
        }
        RefleshImagePos(img_pos_list_);
    }

    // 刷新图片位置
    public void RefleshImagePos(List<float> image_pos_list)
    {
        if (image_pos_list == null)
        {
            return;
        }
        int[] item_size_list = GetImageSize();
        for (int i = 0; i < image_pos_list.Count / 2; i++)
        {
            if (transform.childCount > i && item_size_list.Length > i)
            {
                Transform child = transform.GetChild(i);
                // 居中
                child.localPosition = new Vector3(image_pos_list[2 * i], image_pos_list[2 * i + 1] - item_size_list[i] / 2 + fontSize / 2 - 4);
            }
        }
    }

    public void OnPointerDown(PointerEventData eventData)
    {
    }
}