using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.UI;


[ExecuteInEditMode]
public class TMPLayoutItem : ILayoutComponent
{
    [SerializeField]
    private TextMeshPro tmp;

    public override float GetHeight()
    {
        return tmp.renderedHeight;
    }

    public override float GetWidth()
    {
        return tmp.renderedWidth;
    }

    // Use this for initialization
    void Awake()
    {
        if (tmp == null)
            tmp = GetComponent<TextMeshPro>();
    }

}


