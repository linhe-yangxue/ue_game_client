using UnityEngine;

using System;


public abstract class Singleton<T> : MonoBehaviour where T : Singleton<T>
{
	public static T			Instance { get; private set; }
	
	public static bool CheckExist()
	{
		if( Instance )
			return true;
		else
		{
			Debug.LogError( DateTime.Now + "\t找不到！" + typeof( T ).Name );
			return false;
		}
	}
	
	virtual protected void Awake()
	{
		if( PreAwake() )
			if( !Instance)
		{
			Instance = ( T )this;
			GameObject.DontDestroyOnLoad(gameObject);
			DoAwake();
		}
		else
		{
			enabled = false;
			Debug.LogError(DateTime.Now + "\t单件已存在！" + GetType().Name + " / " + typeof(T).Name + " / " + name, gameObject);
		}
	}
	
	protected virtual void OnDisable()
	{  /*
		if( !gameObject.activeInHierarchy )									// iOS下似乎无法区别切换场景还是deactive
			if( UnityEditor.EditorApplication.isPlaying && !UnityEditor.EditorApplication.isPlayingOrWillChangePlaymode )
				Debug.LogError( DateTime.Now + "\t单件绝对不能被deactive！" + name + " / " + typeof( T ).Name + "\n" + gameObject.activeInHierarchy + " / " + gameObject.activeSelf, this );
		*/
	}
	
	void OnDestroy()
	{
		DoDestroy();
		if( Instance == this ) {
			Instance = null;
		}
	}
	
	protected virtual bool PreAwake() { return true; }
	protected virtual void DoAwake() { }
	protected virtual void DoDestroy() { }
}

public abstract class SingletonCanDestroy<T> : MonoBehaviour where T : SingletonCanDestroy<T>
{
    public static T Instance { get; private set; }

    public static bool CheckExist()
    {
        if (Instance)
            return true;
        else
        {
            Debug.LogError(DateTime.Now + "\t找不到！" + typeof(T).Name);
            return false;
        }
    }

    void Awake()
    {
        if (PreAwake())
            if (!Instance)
            {
                Instance = (T)this;
                DoAwake();
            }
            else
            {
                enabled = false;
                Debug.LogError(DateTime.Now + "\t单件已存在！" + GetType().Name + " / " + typeof(T).Name + " / " + name, gameObject);
            }
    }

    void OnDisable()
    {  /*
		if( !gameObject.activeInHierarchy )									// iOS下似乎无法区别切换场景还是deactive
			if( UnityEditor.EditorApplication.isPlaying && !UnityEditor.EditorApplication.isPlayingOrWillChangePlaymode )
				Debug.LogError( DateTime.Now + "\t单件绝对不能被deactive！" + name + " / " + typeof( T ).Name + "\n" + gameObject.activeInHierarchy + " / " + gameObject.activeSelf, this );
		*/
    }

    void OnDestroy()
    {
        DoDestroy();
        if (Instance == this)
        {
            Instance = null;
        }
    }

    protected virtual bool PreAwake() { return true; }
    protected virtual void DoAwake() { }
    protected virtual void DoDestroy() { }
}
