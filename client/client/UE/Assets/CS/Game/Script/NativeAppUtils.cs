using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Runtime.InteropServices;
using System.IO;
using System.Security.Cryptography;
using System.Text;
using System;

public class NativeAppUtils {
    // 文件操作 --------------------------------------
    // -----------------------------------------------
    public static bool IsFileExists(string file_name) {
        return File.Exists(file_name);
    }

    public static string ReadFile(string file_name) {
        if (file_name.Contains("://")) {
            WWW www = new WWW(file_name);
            while (!www.isDone) ;
            if (www.error != null) {
                return "";
            }
            return www.text;
        } else {
            if (!File.Exists(file_name)) {
                return "";
            }
            return File.ReadAllText(file_name);
        }
    }

    public static byte[] ReadBinaryFile(string file_name) {
        if (file_name.Contains("://")) {
            WWW www = new WWW(file_name);
            while (!www.isDone) ;
            if (www.error != null) {
                return null;
            }
            return www.bytes;
        } else {
            if (!File.Exists(file_name)) {
                return null;
            }
            return File.ReadAllBytes(file_name);
        }
    }

    public static void WriteFile(string file_name, string content) {
        File.WriteAllText(file_name, content);
    }

    public static void WriteBinaryFile(string file_name, byte[] content) {
        File.WriteAllBytes(file_name, content);
    }

    public static void DeleteFile(string file_name) {
        File.Delete(file_name);
    }

    public static void MoveFile(string file_name, string new_file_name) {
        if (File.Exists(new_file_name))
        {
            File.Delete(new_file_name);
        }
        File.Move(file_name, new_file_name);
    }

    public static void CopyFile(string file_name, string new_file_name) {
        File.Copy(file_name, new_file_name, true);
    }

    // 目录操作 --------------------------------------
    // -----------------------------------------------
    public static bool IsDirectoryExists(string path) {
        return Directory.Exists(path);
    }

    public static void CreateDirectory(string path) {
        Directory.CreateDirectory(path);
    }

    public static void DeleteDirectory(string path) {
        Directory.Delete(path, true);
    }

    public static string[] GetFiles(string path) {
        return Directory.GetFiles(path);
    }

    public static string[] GetDirectories(string path) {
        return Directory.GetDirectories(path);
    }

    // MD5相关 --------------------------------------
    // -----------------------------------------------
    public static string MD5(byte[] data) {
        byte[] md5Data = BinaryMD5(data);
        string destString = "";
        for (int i = 0; i < md5Data.Length; i++) {
            destString += System.Convert.ToString(md5Data[i], 16).PadLeft(2, '0');
        }
        destString = destString.PadLeft(32, '0');
        return destString;
    }

    public static byte[] BinaryMD5(byte[] data) {
        MD5CryptoServiceProvider md5 = new MD5CryptoServiceProvider();
        byte[] md5Data = md5.ComputeHash(data, 0, data.Length);
        md5.Clear();
        return md5Data;
    }

    public static string MD5File(string filename) {
        try {
            byte[] retVal = BinaryMD5File(filename);
            StringBuilder sb = new StringBuilder();
            for (int i = 0; i < retVal.Length; i++) {
                sb.Append(retVal[i].ToString("x2"));
            }
            return sb.ToString();
        } catch (Exception ex) {
            throw new Exception("md5file() fail, error:" + ex.Message);
        }
    }

    public static byte[] BinaryMD5File(string filename) {
        try {
            FileStream fs = new FileStream(filename, FileMode.Open);
            System.Security.Cryptography.MD5 md5 = new System.Security.Cryptography.MD5CryptoServiceProvider();
            byte[] retVal = md5.ComputeHash(fs);
            fs.Close();
            return retVal;
        } catch (Exception ex) {
            throw new Exception("md5file() fail, error:" + ex.Message);
        }
    }


    //Base64编码 --------------------------------------
    // -----------------------------------------------
    public static string Base64Encode(byte[] bytes) {
        return Convert.ToBase64String(bytes);
    }

    public static byte[] Base64Decode(string content) {
        return Convert.FromBase64String(content);
    }

    // 时间相关 --------------------------------------
    // -----------------------------------------------
    public static double GetTimeStamp() {
        TimeSpan ts = DateTime.UtcNow - new DateTime(1970, 1, 1, 0, 0, 0, 0);
        return ts.TotalSeconds;
    }

#if UNITY_ANDROID && !UNITY_EDITOR
	private static AndroidJavaClass jc_ = null;
#endif

    static public string GetNetWorkState() {
		// public static final int NETWORK_NONE = 0;
		// public static final int NETWORK_WIFI = 1;
		// public static final int NETWORK_2G = 2;
		// public static final int NETWORK_3G = 3;
		// public static final int NETWORK_4G = 4;
		// public static final int NETWORK_OTHER = 5;
		string ret = "none";
		int st = Application.internetReachability == NetworkReachability.ReachableViaLocalAreaNetwork ? 1 : 0;
		if (st != 1 && Application.internetReachability == NetworkReachability.ReachableViaCarrierDataNetwork) {
			#if (UNITY_ANDROID && !UNITY_EDITOR)
			if (jc_ == null) {
				jc_ = new AndroidJavaClass("com.apputils.apputils.AppUtils");
			}
			if (jc_ != null) {
				st = jc_.CallStatic<int>("GetNetWorkState");
			}
			#endif
			#if UNITY_IPHONE && !UNITY_EDITOR
			st = Native_GetNetWorkState();
			#endif
		}
		switch(st) {
			case 1:
				ret = "wifi";
				break;
			case 2:
				ret = "2G";
				break;
			case 3:
				ret = "3G";
				break;
			case 4:
				ret = "4G";
				break;
			case 5:
				ret = "5G";
				break;
			default:
				ret = "none";
				break;
		}
		return ret;
	}

	static public int GetBatteryPercentage() {
		int pct = 100;

		#if (UNITY_ANDROID && !UNITY_EDITOR)
		if (jc_ == null) {
			jc_ = new AndroidJavaClass("com.apputils.apputils.AppUtils");
		}
		if (jc_ != null) {
			pct = jc_.CallStatic<int>("GetBatteryPercentage");
		}
		#endif

		#if UNITY_IPHONE && !UNITY_EDITOR
		pct = Native_GetBatteryPercentage();
		#endif

		return pct;
	}
	#if UNITY_IPHONE && !UNITY_EDITOR
	const string APPUTILSDLL = "__Internal";

	[DllImport(APPUTILSDLL, CallingConvention = CallingConvention.Cdecl)]
	public static extern int Native_GetNetWorkState();

	[DllImport(APPUTILSDLL, CallingConvention = CallingConvention.Cdecl)]
	public static extern int Native_GetBatteryPercentage();
	#endif
}
