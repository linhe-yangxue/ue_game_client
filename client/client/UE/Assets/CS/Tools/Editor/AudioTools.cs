using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.U2D;
using UnityEditor;
using UnityEditor.U2D;
using System.IO;

public class AudioTools {
    [MenuItem("Assets/音频/统一设置为流式加载")]
    static void SetToStream() {
        var clips = Selection.GetFiltered<AudioClip>(SelectionMode.DeepAssets);
        float count = (float)clips.Length;
        var i = 0;
        foreach(var clip in clips) {
            var path = AssetDatabase.GetAssetPath(clip);
            EditorUtility.DisplayProgressBar("统一设置为流式加载", path, i++ / count);
            var importer = AudioImporter.GetAtPath(path) as AudioImporter;
            var setting = importer.defaultSampleSettings;
            if (setting.loadType != AudioClipLoadType.Streaming) {
                setting.loadType = AudioClipLoadType.Streaming;
                importer.defaultSampleSettings = setting;
                importer.SaveAndReimport();
            }
        }
        EditorUtility.ClearProgressBar();
    }

    [MenuItem("Assets/音频/统一设置为80%品质压缩")]
    static void SetToCompress80() {
        var clips = Selection.GetFiltered<AudioClip>(SelectionMode.DeepAssets);
        float count = (float)clips.Length;
        var i = 0;
        foreach (var clip in clips) {
            var path = AssetDatabase.GetAssetPath(clip);
            EditorUtility.DisplayProgressBar("统一设置为80%品质压缩", path, i++ / count);
            var importer = AudioImporter.GetAtPath(path) as AudioImporter;
            var setting = importer.defaultSampleSettings;
            if (setting.compressionFormat != AudioCompressionFormat.Vorbis ||
                Mathf.Abs(setting.quality - 0.8f) > 0.001f) {
                setting.compressionFormat = AudioCompressionFormat.Vorbis;
                setting.quality = 0.8f;
                importer.defaultSampleSettings = setting;
                importer.SaveAndReimport();
            }
            setting.loadType = AudioClipLoadType.Streaming;
            importer.SaveAndReimport();
        }
        EditorUtility.ClearProgressBar();
    }
}
