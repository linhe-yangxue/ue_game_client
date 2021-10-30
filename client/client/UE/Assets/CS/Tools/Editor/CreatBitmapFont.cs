using UnityEditor;
using UnityEngine;
using System.Collections.Generic;
using System.IO;
using System;

public class CreatBitmapFont
{
    [MenuItem("Assets/CreatFont")]
    static void CreateBitmapFont()
    {
        string path = EditorUtility.SaveFilePanelInProject("保存地址", "font", "", "");
        if (string.IsNullOrEmpty(path))return;
        UnityEngine.Object[] objs = Selection.objects;
        Texture2D[] textures = new Texture2D[objs.Length];
        int[] unicodes = new int[objs.Length];
        int max_height = 0;
        for (int i = 0; i < objs.Length; i++)
        {
            Texture2D texture = objs[i] as Texture2D;
            textures[i] = texture;
            unicodes[i] = GetUnicode(texture.name);
            if (texture.height > max_height)
            {
                max_height = texture.height;
            }
        }
        Rect[] rects = TexturePack(textures, path);
        GenerateFont(textures ,rects, unicodes, path, max_height);
        AssetDatabase.SaveAssets();
        AssetDatabase.Refresh();
    }

    static Rect[] TexturePack(Texture2D[] textures, string path)
    {
        Texture2D tex = new Texture2D(1024, 1024, TextureFormat.RGBA32, false);
        Rect[] rects = tex.PackTextures(textures, 2, 1024);
        byte[] buffer = tex.EncodeToPNG();
        string save_path = path.Replace("Assets", "");
        File.WriteAllBytes(Application.dataPath + save_path + ".png", buffer);
        AssetDatabase.Refresh();
        SetTextureImporter(path + ".png");
        return rects;
    }

    public static void GenerateFont(Texture2D[] textures,  Rect[] rects, int[] unicodes, string path, float max_hegith)
    {
        string tex_path = path + ".png";
        string font_path = path + ".fontsettings";
        string mat_path = path + ".mat";
        Texture font_tex = AssetDatabase.LoadAssetAtPath(tex_path, typeof(Texture)) as Texture;
        Material font_mat = AssetDatabase.LoadAssetAtPath(mat_path, typeof(Material)) as Material;
        if (font_mat == null)
        {
            font_mat = new Material(Shader.Find("UI/Default"));
            font_mat.mainTexture = font_tex;
            AssetDatabase.CreateAsset(font_mat, mat_path);
        }
        else
        {
            font_mat.mainTexture = font_tex;
        }

        Font font_asset = AssetDatabase.LoadAssetAtPath(font_path, typeof(Font)) as Font;
        if (font_asset == null)
        {
            font_asset = new Font();
            AssetDatabase.CreateAsset(font_asset, font_path);
        }
        font_asset.material = font_mat;
        CharacterInfo[] characters = new CharacterInfo[rects.Length];
        for (int i = 0; i < rects.Length; i++)
        {
            Rect rect = rects[i];
            CharacterInfo info = new CharacterInfo();
            Texture2D tx_2d = textures[i];
            info.index = unicodes[i];
            info.uvTopLeft = new Vector2(rect.x, rect.y + rect.height);
            info.uvTopRight = new Vector2(rect.x + rect.width, rect.y + rect.height);
            info.uvBottomLeft = new Vector2(rect.x, rect.y);
            info.uvBottomRight = new Vector2(rect.x + rect.width, rect.y);
            info.minX = 0;
            info.maxX = tx_2d.width;
            info.minY = (int)-((max_hegith - tx_2d.height) / 2 + tx_2d.height);
            info.maxY = (int)-(max_hegith - tx_2d.height) / 2;
            info.advance = tx_2d.width;
            characters[i] = info;
        }
        font_asset.characterInfo = characters;
        EditorUtility.SetDirty(font_asset);
    }

    static int GetUnicode(string str)
    {
        int code = 0;
        if (!string.IsNullOrEmpty(str))
        {
            if (str.Equals("add"))
            {
                code = (int)'+';
            }
            else if (str.Equals("minus"))
            {
                code = (int)'-';
            }
            else if(str.Equals("point"))
            {
                code = (int)'.';
            }
            else
            {
                code = ((int)str[0]);
            }
        }
        return code;
    }

    static void SetTextureImporter(string path)
    {
        TextureImporter ti = AssetImporter.GetAtPath(path) as TextureImporter;
        ti.textureType = TextureImporterType.Sprite;
        ti.mipmapEnabled = false;
        ti.isReadable = false;
        ti.alphaIsTransparency = true;
        ti.filterMode = FilterMode.Bilinear;
        AssetDatabase.ImportAsset(path, ImportAssetOptions.ForceUpdate | ImportAssetOptions.ForceSynchronousImport);
    }
}