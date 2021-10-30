using System;
using UnityEngine;

[AttributeUsage(AttributeTargets.Field)]
public class RenameAttribute : PropertyAttribute
{
    //用来显示中文的字符串
    public string name;

    public RenameAttribute(string name)
    {
        this.name = name;
    }
}