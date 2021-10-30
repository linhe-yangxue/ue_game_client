using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.U2D;
using UnityEditor;
using UnityEditor.U2D;
using System.IO;

public class TextureTools {
    [MenuItem("Assets/贴图/生成 atlas")]
    static void CreateAtlas() {
        var assets = Selection.GetFiltered<Texture2D>(SelectionMode.DeepAssets);
        var tex_paths = new List<string>();
        foreach (var tex in assets) {
            tex_paths.Add(AssetDatabase.GetAssetPath(tex));
        }
        tex_paths.Sort();

        int i = 0;
        SpriteAtlas atlas = null;
        SpriteAtlas low_atlas = null;
        //var texs = new List<Object>();
        var tex_dict = new Dictionary<string, List<Object>>();
        while (i < tex_paths.Count) {
            var dir_path = Path.GetDirectoryName(tex_paths[i]);
            //texs.Clear();
            if (!tex_dict.ContainsKey(dir_path))
            {
                tex_dict.Add(dir_path, new List<Object>());
            }
            while (i < tex_paths.Count) {
                var tex_path = tex_paths[i];
                if (dir_path != Path.GetDirectoryName(tex_path)) {
                    break;
                }
                var tex = AssetDatabase.LoadAssetAtPath<Texture2D>(tex_path);
                tex_dict[dir_path].Add(tex);
                //texs.Add(tex);
                //if (tex.width < 512 && tex.height < 512) {
                //    texs.Add(tex);
                //} else if (tex.width % 4 != 0 || tex.height % 4 != 0) {
                //    Debug.LogErrorFormat(tex, "{0} 是大图，且尺寸不是4的倍数，请检查", tex_path);
                //} else {
                //    Debug.LogWarningFormat(tex, "{0} 是大图，不加入图集，检查是否合理", tex_path);
                //}
                ++i;
            }
        }
        foreach (var texs in tex_dict)
        {
            atlas = _CreateAtlas(texs.Key, "_pack");
            _SetAtlasSetting(atlas);
            atlas.Remove(atlas.GetPackables());
            atlas.Add(texs.Value.ToArray());

            SpriteAtlasUtility.PackAtlases(new SpriteAtlas[] { atlas }, EditorUserBuildSettings.activeBuildTarget);
            EditorUtility.SetDirty(atlas);
        }
    }

    static SpriteAtlas _CreateAtlas(string dir_path, string name_prefix) {
        var atlas_name = dir_path.Replace("Assets/Res", name_prefix).Replace("/", "--");
        var atlas_path = Path.Combine(dir_path, atlas_name + ".spriteatlas");
        var atlas = AssetDatabase.LoadAssetAtPath<SpriteAtlas>(atlas_path);
        if (atlas == null) {
            atlas = new SpriteAtlas();
            AssetDatabase.CreateAsset(atlas, atlas_path);
        }
        return atlas;
    }

    static void _SetAtlasSetting(SpriteAtlas atlas) {
        atlas.SetIncludeInBuild(true);
        // pack_settings
        var pack_settings = atlas.GetPackingSettings();
        pack_settings.enableTightPacking = false;
        pack_settings.enableRotation = false;
        atlas.SetPackingSettings(pack_settings);
        // texture_settings
        var texture_settings = atlas.GetTextureSettings();
        texture_settings.sRGB = true;
        texture_settings.readable = false;
        texture_settings.filterMode = FilterMode.Bilinear;
        texture_settings.generateMipMaps = false;
        atlas.SetTextureSettings(texture_settings);
        // pc_setting
        var pc_setting = atlas.GetPlatformSettings("Standalone");
        pc_setting.overridden = true;
        pc_setting.format = TextureImporterFormat.BC7;
        pc_setting.compressionQuality = 100;
        pc_setting.textureCompression = TextureImporterCompression.CompressedHQ;
        atlas.SetPlatformSettings(pc_setting);
        // ios_setting
        var ios_setting = atlas.GetPlatformSettings("iPhone");
        ios_setting.overridden = true;
        ios_setting.format = TextureImporterFormat.ETC2_RGBA8;
        ios_setting.compressionQuality = 50;
        ios_setting.textureCompression = TextureImporterCompression.Compressed;
        atlas.SetPlatformSettings(ios_setting);
        // android_setting
        var android_setting = atlas.GetPlatformSettings("Android");
        android_setting.overridden = true;
        android_setting.format = TextureImporterFormat.ETC2_RGBA8;
        android_setting.compressionQuality = 50;
        android_setting.textureCompression = TextureImporterCompression.Compressed;
        atlas.SetPlatformSettings(android_setting);
    }

    [MenuItem("Tools/Texture/转换成 径向扭曲贴图")]
    [MenuItem("Assets/贴图/转换成 径向扭曲贴图")]
    static void ConvertToRadialDistortionTexture() {
        var texs = Selection.GetFiltered<Texture2D>(SelectionMode.Assets);
        foreach (var tex in texs) {
            var path = AssetDatabase.GetAssetPath(tex);
            var importer = TextureImporter.GetAtPath(path) as TextureImporter;
            Color[] colors = GetUncompressedColors(importer, true);
            int width = tex.width;
            int height = tex.height;
            Vector2 center = new Vector2(width, height) / 2;
            for (int y = 0; y < height; ++y) {
                for (int x = 0; x < width; ++x) {
                    int i = x * width + y;
                    var color = colors[i];
                    Vector2 dir = (new Vector2(x, y)) - center;
                    dir.Normalize();
                    color.r = (color.r * -dir.y + 1) * 0.5f;
                    color.g = (color.g * dir.x + 1) * 0.5f;
                    color.b = 0.5f;
                    colors[i] = color;
                }
            }
            tex.SetPixels(colors);
            byte[] bytes = tex.EncodeToPNG();
            File.WriteAllBytes(path, bytes);
            importer.textureType = TextureImporterType.NormalMap;
            importer.SaveAndReimport();
        }
	}

    [MenuItem("Tools/Texture/转换成 旋转扭曲贴图")]
    [MenuItem("Assets/贴图/转换成 旋转扭曲贴图")]
    static void ConvertToVortexDistortionTexture() {
        var texs = Selection.GetFiltered<Texture2D>(SelectionMode.Assets);
        foreach (var tex in texs) {
            var path = AssetDatabase.GetAssetPath(tex);
            var importer = TextureImporter.GetAtPath(path) as TextureImporter;
            Color[] colors = GetUncompressedColors(importer, true);
            int width = tex.width;
            int height = tex.height;
            Vector2 center = new Vector2(width, height) / 2;
            for (int y = 0; y < height; ++y) {
                for (int x = 0; x < width; ++x) {
                    int i = x * width + y;
                    var color = colors[i];
                    Vector2 dir = (new Vector2(x, y)) - center;
                    dir.Normalize();
                    color.r = (color.r * dir.x + 1) * 0.5f;
                    color.g = (color.g * dir.y + 1) * 0.5f;
                    color.b = 0.5f;
                    colors[i] = color;
                }
            }
            tex.SetPixels(colors);
            byte[] bytes = tex.EncodeToPNG();
            File.WriteAllBytes(path, bytes);
            importer.textureType = TextureImporterType.NormalMap;
            importer.SaveAndReimport();
        }
	}

    [MenuItem("Tools/Texture/转换成 横向扭曲贴图")]
    [MenuItem("Assets/贴图/转换成 横向扭曲贴图")]
    static void ConvertToHorizontalDistortionTexture() {
        var texs = Selection.GetFiltered<Texture2D>(SelectionMode.Assets);
        foreach (var tex in texs) {
            var path = AssetDatabase.GetAssetPath(tex);
            var importer = TextureImporter.GetAtPath(path) as TextureImporter;
            Color[] colors = GetUncompressedColors(importer, true);
            int width = tex.width;
            int height = tex.height;
            Vector2 center = new Vector2(width, height) / 2;
            for (int y = 0; y < height; ++y) {
                for (int x = 0; x < width; ++x) {
                    int i = x * width + y;
                    var color = colors[i];
                    Vector2 dir = (new Vector2(x, y)) - center;
                    dir.Normalize();
                    color.r = color.r / 2 + 0.5f;
                    color.g = 0.5f;
                    color.b = 0.5f;
                    colors[i] = color;
                }
            }
            tex.SetPixels(colors);
            byte[] bytes = tex.EncodeToPNG();
            File.WriteAllBytes(path, bytes);
            importer.textureType = TextureImporterType.NormalMap;
            importer.SaveAndReimport();
        }
    }

    [MenuItem("Tools/Texture/转换成 竖向扭曲贴图")]
    [MenuItem("Assets/贴图/转换成 竖向扭曲贴图")]
    static void ConvertToVerticleDistortionTexture() {
        var texs = Selection.GetFiltered<Texture2D>(SelectionMode.Assets);
        foreach (var tex in texs) {
            var path = AssetDatabase.GetAssetPath(tex);
            var importer = TextureImporter.GetAtPath(path) as TextureImporter;
            Color[] colors = GetUncompressedColors(importer, true);
            int width = tex.width;
            int height = tex.height;
            Vector2 center = new Vector2(width, height) / 2;
            for (int y = 0; y < height; ++y) {
                for (int x = 0; x < width; ++x) {
                    int i = x * width + y;
                    var color = colors[i];
                    Vector2 dir = (new Vector2(x, y)) - center;
                    dir.Normalize();
                    color.r = 0.5f;
                    color.g = color.g / 2 + 0.5f;
                    color.b = 0.5f;
                    colors[i] = color;
                }
            }
            tex.SetPixels(colors);
            byte[] bytes = tex.EncodeToPNG();
            File.WriteAllBytes(path, bytes);
            importer.textureType = TextureImporterType.NormalMap;
            importer.SaveAndReimport();
        }
    }

    [MenuItem("Tools/Texture/分离alpha通道")]
    [MenuItem("Assets/贴图/分离alpha通道")]
    static void SplitAlpha() {
        var texs = Selection.GetFiltered<Texture2D>(SelectionMode.Assets);
        foreach (var tex in texs) {
            var path = AssetDatabase.GetAssetPath(tex);
            var importer = TextureImporter.GetAtPath(path) as TextureImporter;
            Color[] colors = GetUncompressedColors(importer, true);
            importer.alphaSource = TextureImporterAlphaSource.None;
            for (int i = 0; i < colors.Length; ++i) {
                colors[i] = new Color(colors[i].a, colors[i].a, colors[i].a);
            }
            var alpha_tex = new Texture2D(tex.width, tex.height, TextureFormat.RGB24, false);
            alpha_tex.SetPixels(colors);
            byte[] bytes = alpha_tex.EncodeToPNG();
            int dot_pos = path.LastIndexOf('.');
            var alpha_path = path.Substring(0, dot_pos) + "_alpha" + path.Substring(dot_pos);
            File.WriteAllBytes(alpha_path, bytes);
            AssetDatabase.Refresh();
            var alpha_importer = TextureImporter.GetAtPath(alpha_path) as TextureImporter;
            alpha_importer.alphaSource = TextureImporterAlphaSource.None;
            alpha_importer.SaveAndReimport();
        }
    }

    [MenuItem("Tools/Texture/渗透透明颜色")]
    [MenuItem("Assets/贴图/渗透透明颜色（png）")]
    static void BleedAlphaColor() {
        var texs = Selection.GetFiltered<Texture2D>(SelectionMode.Assets);
        foreach (var tex in texs) {
            var path = AssetDatabase.GetAssetPath(tex);
            var org_tex = LoadTextureFromFile(path);
            int width = org_tex.width;
            int height = org_tex.height;
            Color[] colors = org_tex.GetPixels();
            bool[] finish = new bool[colors.Length];
            List<int> current = new List<int>(colors.Length);
            List<int> next = new List<int>(colors.Length);
            for (int i = 0; i < colors.Length; ++i) {
                if (colors[i].a > 0) {
                    current.Add(i);
                    finish[i] = true;
                }
            }
            while (current.Count > 0) {
                foreach (int i in current) {
                    int x = i % width;
                    int y = i / width;
                    var color = colors[i];
                    color.a = 0;
                    if (x > 0 && !finish[i - 1]) {
                        colors[i - 1] = color;
                        finish[i - 1] = true;
                        next.Add(i - 1);
                    }
                    if (x < width - 1 && !finish[i + 1]) {
                        colors[i + 1] = color;
                        finish[i + 1] = true;
                        next.Add(i + 1);
                    }
                    if (y > 0 && !finish[i - width]) {
                        colors[i - width] = color;
                        finish[i - width] = true;
                        next.Add(i - width);
                    }
                    if (y < height - 1 && !finish[i + width]) {
                        colors[i + width] = color;
                        finish[i + width] = true;
                        next.Add(i + width);
                    }
                }
                var tmp = current;
                current = next;
                next = tmp;
                next.Clear();
            }
            org_tex.SetPixels(colors);
            var bytes = org_tex.EncodeToPNG();
            File.WriteAllBytes(path, bytes);
        }
        AssetDatabase.Refresh();
    }


    public static Color[] GetUncompressedColors(TextureImporter importer, bool no_second_save = false) {
        var path = importer.assetPath;
        var tex = AssetDatabase.LoadAssetAtPath<Texture2D>(path);
        var old_compression = importer.textureCompression;
        importer.textureCompression = TextureImporterCompression.Uncompressed;
        var old_is_readable = importer.isReadable;
        importer.isReadable = true;
        importer.SaveAndReimport();
        var colors = tex.GetPixels();
        importer.isReadable = old_is_readable;
        importer.textureCompression = old_compression;
        if (!no_second_save) importer.SaveAndReimport();
        return colors;
    }

    public static Texture2D LoadTextureFromFile(string file_path) {
        if (file_path.EndsWith(".tga", System.StringComparison.CurrentCultureIgnoreCase)) {
            return LoadTextureFromTGA(file_path);
        } else {
            var tex = new Texture2D(2, 2);
            tex.LoadImage(File.ReadAllBytes(file_path));
            return tex;
        }
    }

    public static Texture2D LoadTextureFromTGA(string file_path) {
        // https://gist.github.com/mikezila/10557162
        var imageFile = File.OpenRead(file_path);
        using (BinaryReader r = new BinaryReader(imageFile)) {
            // Skip some header info we don't care about.
            // Even if we did care, we have to move the stream seek point to the beginning,
            // as the previous method in the workflow left it at the end.
            r.BaseStream.Seek(12, SeekOrigin.Begin);

            short width = r.ReadInt16();
            short height = r.ReadInt16();
            int bitDepth = r.ReadByte();

            // Skip a byte of header information we don't care about.
            r.BaseStream.Seek(1, SeekOrigin.Current);

            Texture2D tex = new Texture2D(width, height);
            Color32[] pulledColors = new Color32[width * height];

            if (bitDepth == 32) {
                for (int i = 0; i < width * height; i++) {
                    byte red = r.ReadByte();
                    byte green = r.ReadByte();
                    byte blue = r.ReadByte();
                    byte alpha = r.ReadByte();

                    pulledColors[i] = new Color32(blue, green, red, alpha);
                }
            } else if (bitDepth == 24) {
                for (int i = 0; i < width * height; i++) {
                    byte red = r.ReadByte();
                    byte green = r.ReadByte();
                    byte blue = r.ReadByte();

                    pulledColors[i] = new Color32(blue, green, red, 1);
                }
            } else {
                throw new System.Exception("TGA texture had non 32/24 bit depth.");
            }
            tex.SetPixels32(pulledColors);
            tex.Apply();
            return tex;
        }
    }

    public static void OnPreprocessTexture(TextureImporter importer) {
        importer.textureCompression = TextureImporterCompression.Compressed;
        // pc
        var pc_setting = importer.GetDefaultPlatformTextureSettings();
        pc_setting.name = "Standalone";
        pc_setting.overridden = true;
        if (importer.textureCompression == TextureImporterCompression.Uncompressed) {
            if (importer.alphaSource == TextureImporterAlphaSource.None) {
                pc_setting.format = TextureImporterFormat.RGB24;
            } else {
                pc_setting.format = TextureImporterFormat.RGBA32;
            }
        } else {
            if (importer.alphaSource == TextureImporterAlphaSource.None) {
                pc_setting.format = TextureImporterFormat.BC7;
            } else {
                pc_setting.format = TextureImporterFormat.BC7;
            }
            pc_setting.compressionQuality = 100;
            pc_setting.textureCompression = TextureImporterCompression.CompressedHQ;
        }
        importer.SetPlatformTextureSettings(pc_setting);
        // ios
        var ios_setting = importer.GetDefaultPlatformTextureSettings();
        ios_setting.name = "iPhone";
        ios_setting.overridden = true;
        if (importer.textureCompression == TextureImporterCompression.Uncompressed) {
            if (importer.alphaSource == TextureImporterAlphaSource.None) {
                ios_setting.format = TextureImporterFormat.RGB24;
            } else {
                ios_setting.format = TextureImporterFormat.RGBA32;
            }
        } else {
            if (importer.alphaSource == TextureImporterAlphaSource.None) {
                ios_setting.format = TextureImporterFormat.PVRTC_RGB4;
                ios_setting.compressionQuality = 100;
                ios_setting.textureCompression = TextureImporterCompression.CompressedHQ;
            } else {
                ios_setting.format = TextureImporterFormat.ETC2_RGBA8;
                ios_setting.compressionQuality = 50;
                ios_setting.textureCompression = TextureImporterCompression.Compressed;
            }
        }
        importer.SetPlatformTextureSettings(ios_setting);
        // android
        var android_setting = importer.GetDefaultPlatformTextureSettings();
        android_setting.name = "Android";
        android_setting.overridden = true;
        if (importer.textureCompression == TextureImporterCompression.Uncompressed) {
            if (importer.alphaSource == TextureImporterAlphaSource.None) {
                android_setting.format = TextureImporterFormat.RGB24;
            } else {
                android_setting.format = TextureImporterFormat.RGBA32;
            }
        } else {
            if (importer.alphaSource == TextureImporterAlphaSource.None) {
                android_setting.format = TextureImporterFormat.ETC2_RGB4;
            } else {
                android_setting.format = TextureImporterFormat.ETC2_RGBA8;
            }
            android_setting.compressionQuality = 50;
            android_setting.textureCompression = TextureImporterCompression.Compressed;
        }
        importer.SetPlatformTextureSettings(android_setting);
    }

    [MenuItem("Assets/恢复设置/恢复贴图设置")]
    static void InitTextureImporter() {
        var texs = Selection.GetFiltered<Texture2D>(SelectionMode.DeepAssets);
        for (int i = 0; i < texs.Length; ++i) {
            var tex = texs[i];
            EditorUtility.DisplayProgressBar("恢复贴图设置", AssetDatabase.GetAssetPath(tex), (float)i / texs.Length);
            var path = AssetDatabase.GetAssetPath(tex);
            var importer = AssetImporter.GetAtPath(path) as TextureImporter;
            if (importer == null) continue;
            importer.allowAlphaSplitting = false;
            importer.compressionQuality = 100;
            importer.crunchedCompression = true;
            importer.maxTextureSize = 1024;
            importer.textureCompression = TextureImporterCompression.CompressedHQ;
            importer.SaveAndReimport();
        }
        EditorUtility.ClearProgressBar();
    }
}
