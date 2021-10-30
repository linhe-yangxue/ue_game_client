using UnityEngine;

#if UNITY_EDITOR
using UnityEditor;
using UnityEditor.Callbacks;
using UnityEditor.XCodeEditor;
#if UNITY_IOS || UNITY_IPHONE
using UnityEditor.iOS.Xcode;
using UnityEditor.iOS.Xcode.Extensions;
#endif
using System.Xml;
#endif
using System.IO;

public static class XCodePostProcess
{
    #if UNITY_EDITOR
    [PostProcessBuild (100)]
    public static void OnPostProcessBuild (BuildTarget target, string pathToBuiltProject)
    {
        if (target != BuildTarget.iOS) {
            Debug.LogWarning ("Target is not iPhone. XCodePostProcess will not run");
            return;
        }

        //得到xcode工程的路径
        string path = Path.GetFullPath (pathToBuiltProject);

        // Create a new project object from build target
        XCProject project = new XCProject (pathToBuiltProject);

        // Find and run through all projmods files to patch the project.
        // Please pay attention that ALL projmods files in your project folder will be excuted!
        //在这里面把frameworks添加在你的xcode工程里面
        string[] files = Directory.GetFiles (Application.dataPath, "*.projmods", SearchOption.AllDirectories);
        foreach (string file in files) {
            project.ApplyMod (file);
        }

        //增加一个编译标记。。没有的话sharesdk会报错。。
        project.AddOtherLinkerFlags("-ObjC -lz");
        //
        //        //设置签名的证书， 第二个参数 你可以设置成你的证书
        // project.overwriteBuildSetting ("CODE_SIGN_IDENTITY", "xxxxxx", "Release");
        //        project.overwriteBuildSetting ("CODE_SIGN_IDENTITY", "xxxxxx", "Debug");
        var target_list = (PBXList)project.project.data ["targets"];
        var attributes = new PBXDictionary ();
        var tar_attributes = new PBXDictionary ();
        var t1_setting = new PBXDictionary ();
		t1_setting.Add ("DevelopmentTeam", "J3C4DNG9Y3");
        t1_setting.Add ("ProvisioningStyle", "Automatic");
        var t2_setting = new PBXDictionary ();
		t2_setting.Add ("DevelopmentTeam", "J3C4DNG9Y3");
        t2_setting.Add ("TestTargetID", target_list[0]);
        tar_attributes.Add ((string)target_list[0], t1_setting);
        tar_attributes.Add ((string)target_list[1], t2_setting);
        attributes.Add ("TargetAttributes", tar_attributes);
        if (project.project.ContainsKey ("attributes")) {
            project.project.data ["attributes"] = attributes;
        } else {
            project.project.Add ("attributes", attributes);
        }
        //
        //
        //        // 编辑plist 文件
        EditorPlist(path);
        //
        //        //编辑代码文件
        //        EditorCode(path);

        // Finally save the xcode project
        project.Save ();
#if UNITY_IOS || UNITY_IPHONE
		string proj_path = UnityEditor.iOS.Xcode.PBXProject.GetPBXProjectPath(pathToBuiltProject);
		var pbx_proj = new UnityEditor.iOS.Xcode.PBXProject();
		pbx_proj.ReadFromString(File.ReadAllText(proj_path));
		string pbx_tar = pbx_proj.TargetGuidByName("Unity-iPhone");

		pbx_proj.AddFrameworkToProject(pbx_tar, "CoreTelephony.framework", false);
		pbx_proj.AddFrameworkToProject(pbx_tar, "AddressBook.framework", false);
		pbx_proj.AddFrameworkToProject(pbx_tar, "Contacts.framework", false);
		pbx_proj.AddFrameworkToProject(pbx_tar, "SystemConfiguration.framework", false);
		pbx_proj.AddFrameworkToProject(pbx_tar, "Security.framework", false);
		pbx_proj.AddFrameworkToProject(pbx_tar, "MobileCoreServices.framework", false);
		pbx_proj.AddFrameworkToProject(pbx_tar, "Adsupport.framework", false);
		pbx_proj.AddFrameworkToProject(pbx_tar, "Storekit.framework", false);
		pbx_proj.AddFrameworkToProject(pbx_tar, "SafariServices.framework", false);
		pbx_proj.AddFrameworkToProject(pbx_tar, "WebKit.framework", false);
		pbx_proj.AddFrameworkToProject(pbx_tar, "UserNotifications.framework", false);
		pbx_proj.AddFrameworkToProject(pbx_tar, "CoreLocation.framework", false);
		pbx_proj.AddFrameworkToProject(pbx_tar, "libresolv.tbd", false);
        // gaea
		//pbx_proj.AddFrameworkToProject(pbx_tar, "FBSDKCoreKit.framework", false);
		//pbx_proj.AddFrameworkToProject(pbx_tar, "GAEASDKResources.bundle", false);
		//pbx_proj.AddFrameworkToProject(pbx_tar, "GDTActionSDK.framework", false);
		//pbx_proj.AddFrameworkToProject(pbx_tar, "SAPILib.framework", false);
		//pbx_proj.AddFrameworkToProject(pbx_tar, "SAPIResource.bundle", false);
		//pbx_proj.AddFrameworkToProject(pbx_tar, "SVProgressHUD.bundle", false);        
        //PBXProjectExtensions.AddFileToEmbedFrameworks(pbx_proj, pbx_tar, "GDTActionSDK.framework");

		pbx_proj.SetBuildProperty(pbx_tar, "ENABLE_BITCODE", "NO");
		pbx_proj.SetBuildProperty(pbx_tar, "GCC_ENABLE_OBJC_EXCEPTIONS", "YES");

		File.WriteAllText(proj_path, pbx_proj.WriteToString());

        // 修改plist
        string plistPath = path + "/Info.plist";
        PlistDocument plist = new PlistDocument();
        plist.ReadFromString(File.ReadAllText(plistPath));
        PlistElementDict rootDict = plist.root;
        {// LSApplicationQueriesSchemes
            PlistElementArray Schemes = rootDict.CreateArray("LSApplicationQueriesSchemes");
            Schemes.AddString("weixin");
            Schemes.AddString("wechat");
            Schemes.AddString("mqqapi");
            Schemes.AddString("mqq");
            Schemes.AddString("mqqOpensdkSSoLogin");
            Schemes.AddString("mqqconnect");
            Schemes.AddString("mqqopensdkdataline");
            Schemes.AddString("mqqopensdkgrouptribeshare");
            Schemes.AddString("mqqopensdkfriend");
            Schemes.AddString("mqqopensdkapi");
            Schemes.AddString("mqqopensdkapiV2");
            Schemes.AddString("mqqopensdkapiV3");
            Schemes.AddString("mqzoneopensdk");
            Schemes.AddString("mqqopensdkapiV3");
            Schemes.AddString("mqqopensdkapiV3");
            Schemes.AddString("mqzone");
            Schemes.AddString("mqzonev2");
            Schemes.AddString("mqzoneshare");
            Schemes.AddString("wtloginqzone");
            Schemes.AddString("mqzonewx");
            Schemes.AddString("mqzoneopensdkapiV2");
            Schemes.AddString("mqzoneopensdkapi19");
            Schemes.AddString("mqzoneopensdkapi");
            Schemes.AddString("mqzoneopensdk");
        }
        // 语音所需要的声明，iOS10必须  
        rootDict.SetString("NSMicrophoneUsageDescription", "是否允许此游戏使用麦克风？");
        // 保存plist  
        plist.WriteToFile(plistPath);
#endif
        Debug.Log("XCodePostProcess Complete!!!!!");
    }

    private static void EditorPlist(string filePath)
    {
        XCPlist list =new XCPlist(filePath);

        string PlistAdd = @"  
            <key>CFBundleURLTypes</key>
    <array>
        <dict>
            <key>CFBundleTypeRole</key>
            <string>None</string>
            <key>CFBundleURLSchemes</key>
            <array>
                <string>test</string>
            </array>
        </dict>
    </array>";
        //在plist里面增加一行
        list.AddKey(PlistAdd);
		PlistAdd = @"
		<key>NSCameraUsageDescription</key>    
    	<string>cameraDesciption</string>
		";
		list.AddKey(PlistAdd);
		PlistAdd = @"
		<key>NSContactsUsageDescription</key>    
    	<string>contactsDesciption</string>
		";
		list.AddKey(PlistAdd);
		PlistAdd = @"
		<key>NSMicrophoneUsageDescription</key>    
    	<string>microphoneDesciption</string>
		";
		list.AddKey(PlistAdd);
		PlistAdd = @"
		<key>NSLocationWhenInUseUsageDescription</key>
		<string>locationDesciption</string>
		";
		list.AddKey(PlistAdd);

        //保存
        list.Save();

    }

    private static void EditorCode(string filePath)
    {
        //读取UnityAppController.mm文件
        XClass UnityAppController = new XClass(filePath + "/Classes/UnityAppController.mm");

        //在指定代码后面增加一行代码
        UnityAppController.WriteBelow("#include \"PluginBase/AppDelegateListener.h\"","#import <ShareSDK/ShareSDK.h>");

        //在指定代码中替换一行
        UnityAppController.Replace("return YES;","return [ShareSDK handleOpenURL:url sourceApplication:sourceApplication annotation:annotation wxDelegate:nil];");

        //在指定代码后面增加一行
        UnityAppController.WriteBelow("UnityCleanup();\n}","- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url\r{\r    return [ShareSDK handleOpenURL:url wxDelegate:nil];\r}");


    }

    public  static void  CopyFiles(string   varFromDirectory, string   varToDirectory) 
    {
        //删除这个目录下的所有文件
        if (Directory.GetFiles(varToDirectory).Length > 0)
        {
            foreach (string var in Directory.GetFiles(varToDirectory))
            {
                File.Delete(var);
                Debug.Log("DeleteFile: " + var);
            }
        }

        //实现从一个目录下完整拷贝到另一个目录下。 
        Directory.CreateDirectory(varToDirectory); 
        if(!Directory.Exists(varFromDirectory))   
        { 
            return; 
        }

        string[]  directories  =  Directory.GetDirectories(varFromDirectory);//取文件夹下所有文件夹名，放入数组； 
        if(directories.Length  >  0) 
        { 
            foreach(string  d  in  directories) 
            { 
                CopyFiles(d,varToDirectory  +  d.Substring(d.LastIndexOf( "/")+1));//递归拷贝文件和文件夹 
            } 
        } 

        string[]  files  =  Directory.GetFiles(varFromDirectory);//取文件夹下所有文件名，放入数组； 
        if(files.Length  >  0) 
        { 
            foreach(string  s  in  files) 
            { 
                if(s.EndsWith("meta")) continue;
                Debug.Log("CopyFile: " + s + " TO  " + varToDirectory + s.Substring(s.LastIndexOf("/")+1));
                File.Copy(s, varToDirectory + s.Substring(s.LastIndexOf("/")+1)); 
            } 
        } 
    }

    public  static void  CopyFile(string   sourcePath, string   targetPath)
    {
        if(File.Exists(sourcePath))
        {
            if(File.Exists(targetPath))
            {
                File.Delete(targetPath);
            }
            File.Copy(sourcePath, targetPath);
            Debug.Log("CopyFile: " + sourcePath + " TO  " + targetPath);
        }
    }

    #endif
}
