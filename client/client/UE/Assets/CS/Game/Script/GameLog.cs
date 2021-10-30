using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Text;

public class GameLog {
	static LinkedList<string> _sLogCacheText = new LinkedList<string>();
	static string _sLogPath;

	public static void InitGameLog() {
		_sLogPath = Application.persistentDataPath + "/gamelog.txt";
		string pre_log_path = Application.persistentDataPath + "/gamelog_prev.txt";
		if (System.IO.File.Exists(_sLogPath)) {
			if (System.IO.File.Exists(pre_log_path)) {
				System.IO.File.Delete(pre_log_path);
			}
			System.IO.File.Copy(_sLogPath, pre_log_path);
		}
		if (System.IO.File.Exists(_sLogPath)) {
			System.IO.File.Delete(_sLogPath);
		}
		Application.logMessageReceived += _ReceiveLog;
		Debug.Log("===================InitGameLog===============");
	}

	static void _ReceiveLog(string log_string, string stack_trace, LogType type) {
		_sLogCacheText.AddLast(log_string);
	}

	public static void WriteLog() {
		int num = _sLogCacheText.Count;
		if (num > 0) {
			using (StreamWriter writer = new StreamWriter(_sLogPath, true, Encoding.UTF8)) {
				for (int i = 0; i < num; ++i) {
					var first_node = _sLogCacheText.First;
					writer.WriteLine(first_node.Value);
					_sLogCacheText.RemoveFirst();
				}
				writer.Flush();
			}
		}
	}

	public static void LaterUpdate() {
		WriteLog();
	}
}
