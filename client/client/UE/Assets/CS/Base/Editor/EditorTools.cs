using UnityEngine;
using UnityEditor;

public class EditorTools
{
    [MenuItem("Assets/Save")]
    public static void Save() {
        AssetDatabase.SaveAssets();
    }
    [MenuItem("Assets/CreateScriptObjectAsset")]
    public static void CreateScriptObjectAsset()
    {
        var go = Selection.activeObject as MonoScript;
        if (go != null && go.GetClass().IsSubclassOf(typeof(ScriptableObject)))
        {
            var s_asset = ScriptableObject.CreateInstance(go.GetClass());
            var path = AssetDatabase.GetAssetPath(go);
            path = path.Replace(".cs", ".asset");
            AssetDatabase.CreateAsset(s_asset, path);
            AssetDatabase.SaveAssets();
        }
    }
    [MenuItem("Assets/CopyPath")]
    public static void CopyPath() {
        Object go = Selection.activeObject;
        if (go == null) {
            return;
        }
        string path = AssetDatabase.GetAssetPath(go);
        int index = path.LastIndexOf(".");
        path = path.Substring(0, index);
        TextEditor te = new TextEditor();
        te.text = path;
        te.OnFocus();
        te.Copy();
    }
    [MenuItem("GameObject/拷贝子物体位置",false,12)]
    public static void CopyChildPos()
    {
        GameObject go = Selection.activeGameObject;
        if (go == null)
        {
            return;
        }
        string pos_str = GetChildPos(go);
        TextEditor te = new TextEditor();
        te.text = pos_str;
        te.OnFocus();
        te.Copy();
    }
    static public string GetChildPos(GameObject go)
    {
        RectTransform trans = go.GetComponent<RectTransform>();
        if (trans == null) return "";
        string pos_str = "";
        for (int i = 0; i < trans.childCount; ++i)
        {
            Vector2 pos = trans.GetChild(i).GetComponent<RectTransform>().anchoredPosition;
            pos_str = pos_str + Mathf.Floor(pos.x) + "//" + Mathf.Floor(pos.y);
            if (i != trans.childCount - 1)
            {
                pos_str += "\n";
            }
        }
        return pos_str;
    }

    [MenuItem("GameObject/拷贝骨骼路径", false, 11)]
    static public void CopyBonePath() {
        GUIUtility.systemCopyBuffer = GetPathByBone(Selection.activeTransform);
    }
    static public string GetPathByBone(Transform trans) {
        if (trans == null) return "";
        string path = trans.name;
        trans = trans.parent;
        while (trans != null) {
            path = trans.name + "/" + path;
            if (trans.GetComponent<Animator>() != null) break;
            trans = trans.parent;
        }
        return path;
    }
    [MenuItem("GameObject/拷贝场景物件路径", false, 11)]
    static public void CopySceneObjPath() {
        GUIUtility.systemCopyBuffer = GetSceneObjPath(Selection.activeTransform);
    }
    static public string GetSceneObjPath(Transform trans) {
        if (trans == null) return "";
        string path = "";
        while (trans != null) {
            path = "/" + trans.name + path;
            trans = trans.parent;
        }
        return path;
    }
    static public string GetRelativePath(Transform trans, Transform root) {
        if (trans == null || trans == root) return "";
        string path = trans.name;
        trans = trans.parent;
        while (trans != root) {
            path = trans.name + "/" + path;
            trans = trans.parent;
        }
        return path;
    }
    //[MenuItem("Test/TestExportTerrainDetail")]
    static public void TestExportTerrainDetail() {
        var terrain = Object.FindObjectOfType<Terrain>();
        var data = terrain.terrainData;
        var infos = data.detailPrototypes;
        var width = data.detailWidth;
        var height = data.detailHeight;
        for (int i = 0; i < infos.Length; ++i) {
            var detail = data.GetDetailLayer(0, 0, width, height, i);
            var tex = new Texture2D(width, height, TextureFormat.ARGB32, false);
            Color32[] colors = new Color32[width * height];
            for (int x = 0; x < width; ++x) {
                for (int y = 0; y < height; ++y) {
                    var value = detail[x, y];
                    colors[x * height + y] = new Color32((byte)value, (byte)value, (byte)value, 255);
                }
            }
            tex.SetPixels32(colors);
            tex.Apply();
            var png = tex.EncodeToPNG();
            System.IO.File.WriteAllBytes("Assets/aaa.png", png);
            AssetDatabase.Refresh();
        }
    }
}
