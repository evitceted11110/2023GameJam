using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CollectManager : MonoBehaviour
{
    private static CollectManager _manager;
    public static CollectManager Instance
    {
        get
        {
            return _manager;
        }
    }
    private void Awake()
    {
        _manager = this;
        DontDestroyOnLoad(this.gameObject);
    }

    private List<Action<ItemBase>> completeCallBack = new List<Action<ItemBase>>();
    public void InjectCompleteActionEvent(Action<ItemBase> callBack)
    {
        completeCallBack.Add(callBack);
    }

    public void OnCollectedCheck(ItemBase item)
    {
        foreach(Action<ItemBase> action in completeCallBack)
        {
            action.Invoke(item);
        }
        completeCallBack.Clear();
    }
}
