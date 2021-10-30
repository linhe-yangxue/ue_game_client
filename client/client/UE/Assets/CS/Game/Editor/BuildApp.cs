using UnityEditor;
using UnityEngine;
using System;
using System.IO;
using System.Linq;
using System.Collections.Generic;
using System.Text.RegularExpressions;

public class BuildApp
{


    public static string TargetStr;
    public static BuildTarget Target;

    public static BuildOptions Opt;

    public static string[] GetLevelsFromBuildSettings()
    {
        List<string> levels = new List<string>();
        for (int i = 0; i < EditorBuildSettings.scenes.Length; ++i)
        {
            if (EditorBuildSettings.scenes[i].enabled)
            {
                Debug.Log("build map to :" + EditorBuildSettings.scenes[i].path);
                levels.Add(EditorBuildSettings.scenes[i].path);
            }
        }

        return levels.ToArray();
    }


    public static void BuildGameWoAB()
    {
        PackScripts.PackAll();
        string[] levels = GetLevelsFromBuildSettings();
        //PlayerSettings.keystorePass = "mindsetgame_HGAME";
        //PlayerSettings.keyaliasPass = "mindsetgame_HGAME";
        BuildPipeline.BuildPlayer(levels, TargetStr, Target, Opt);
    }

    public static void BuildGameWithAB()
    {
		AssetBundles.AssetBundleBuilder.BuildAssetBundles(Target);
        string[] levels = {
                              "Assets/GameEntry.unity",
							  // "Assets/EmptyMap.unity",
                          };
        //PlayerSettings.keystorePass = "wangpaiyushi";
        //PlayerSettings.keyaliasPass = "wangpaiyushi";
        BuildPipeline.BuildPlayer(levels, TargetStr, Target, Opt);
    }

    /*
    public static void PreBuild()
    {
        A2CodeGen.CustomUnity();
    }
     */

    public static void BuildIosDebug()
    {
        string[] arguments = Environment.GetCommandLineArgs();
        string out_name = "";
        for (int i = 0; i < arguments.Length; ++i) {
            if (arguments[i] == "-outname" && i + 1 < arguments.Length) {
                out_name = arguments[i + 1];
                break;
            }
        }
        //PreBuild();
        TargetStr = GetBuildPathiOS(out_name);
        Target = BuildTarget.iOS;
        Opt = BuildOptions.Development | BuildOptions.ConnectWithProfiler | BuildOptions.AllowDebugging | BuildOptions.SymlinkLibraries | BuildOptions.AcceptExternalModificationsToPlayer;
        BuildGameWithAB();
    }

	static string GetBuildPathiOS(string out_name)
    {
		string dt_path = Application.dataPath.Substring(0, Application.dataPath.Length - "/Assets".Length);
		string dirPath = dt_path + "/../../buildIos" + out_name;
        if (File.Exists(dirPath))
        {
            File.Delete(dirPath);
        }
        if (!System.IO.Directory.Exists(dirPath))
        {
            System.IO.Directory.CreateDirectory(dirPath);
        }
        return dirPath;
    }

    public static void BuildIosRelease()
    {
		string[] arguments = Environment.GetCommandLineArgs();
        string out_name = "";
        for (int i = 0; i < arguments.Length; ++i)
        {
            if (arguments[i] == "-outname" && i + 1 < arguments.Length)
            {
				out_name = arguments[i + 1];
				break;
            }
        }
        //PreBuild();
		TargetStr = GetBuildPathiOS(out_name);
        Target = BuildTarget.iOS;
        Opt = BuildOptions.None;
        BuildGameWithAB();
    }

    public static void BuildAndroidDebug()
    {
        string[] arguments = Environment.GetCommandLineArgs();
        string path = null;
        for (int i = 0; i < arguments.Length; ++i) {
            if (arguments[i] == "-asdk" && i + 1 < arguments.Length) {
                path = arguments[i + 1];
                break;
            }
        }
        if (path != null) {
            EditorPrefs.SetString("AndroidSdkRoot", path);
        }
        PlayerSettings.Android.keystoreName = Application.dataPath + "/../user.keystore";
        PlayerSettings.Android.keystorePass = "wanpixia123";
        PlayerSettings.Android.keyaliasName = "zc";
        PlayerSettings.Android.keyaliasPass = "wanpixia123";

        TargetStr = GetBuildPathAndroid();
        Target = BuildTarget.Android;
        Opt = BuildOptions.Development | BuildOptions.ConnectWithProfiler | BuildOptions.AllowDebugging | BuildOptions.SymlinkLibraries;
        BuildGameWithAB();
    }

    static string GetBuildPathAndroid()
    {
		string[] arguments = Environment.GetCommandLineArgs();
        string out_name = "";
        for (int i = 0; i < arguments.Length; ++i)
        {
            if (arguments[i] == "-outname" && i + 1 < arguments.Length)
            {
				out_name = arguments[i + 1];
				break;
            }
        }
		string dt_path = Application.dataPath.Substring(0, Application.dataPath.Length - "/Assets".Length);
		string dirPath = dt_path + "/../../build/" + out_name + ".apk";
        if (File.Exists(dirPath))
        {
            File.Delete(dirPath);
        }
        if (!System.IO.Directory.Exists(dirPath))
        {
            System.IO.Directory.CreateDirectory(dirPath);
        }
        return dirPath;
    } 

    public static void BuildAndroidRelease()
    {
        //PreBuild();
        //PreBuild();
        string[] arguments = Environment.GetCommandLineArgs();
        string path = null;
        for (int i = 0; i < arguments.Length; ++i)
        {
            if (arguments[i] == "-asdk" && i + 1 < arguments.Length)
            {
                path = arguments[i + 1];
                break;
            }
        }
        if (path != null)
        {
            EditorPrefs.SetString("AndroidSdkRoot", path);
        }
        PlayerSettings.Android.keystoreName = Application.dataPath + "/../user.keystore";
        PlayerSettings.Android.keystorePass = "wanpixia123";
        PlayerSettings.Android.keyaliasName = "zc";
        PlayerSettings.Android.keyaliasPass = "wanpixia123";

        TargetStr = GetBuildPathAndroid();
        Target = BuildTarget.Android;
        Opt = BuildOptions.None;
        BuildGameWithAB();
    }

}
