using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class HighLightManager : MonoBehaviour
{
    private static HighLightManager _instance;
    public static HighLightManager Instance
    {
        get
        {
            return _instance;
        }
    }
    private Dictionary<object, IHighLightable> currentHighLightDictionary = new Dictionary<object, IHighLightable>();

    private void Awake()
    {
        _instance = this;
    }

    public void SetHighLight(object obj, IHighLightable item)
    {
        if (!currentHighLightDictionary.ContainsKey(obj))
        {
            currentHighLightDictionary.Add(obj, item);
        }
        else
        {
            if (currentHighLightDictionary[obj] != null)
                currentHighLightDictionary[obj].SetHighLight(false);
            if (item != null)
                item.SetHighLight(true);
            currentHighLightDictionary[obj] = item;
        }
    }

    public IHighLightable GetHighLightItem(object obj)
    {
        if (currentHighLightDictionary.ContainsKey(obj))
        {
            return currentHighLightDictionary[obj];
        }
        return null;
    }
}
