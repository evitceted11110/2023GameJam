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

    private List<Action<ItemBase, bool>> completeCallBack = new List<Action<ItemBase, bool>>();
    public void InjectCompleteActionEvent(Action<ItemBase, bool> callBack)
    {
        completeCallBack.Add(callBack);
    }

    public void OnCollectedCheck(ItemBase item, bool isLeft)
    {
        foreach(Action<ItemBase, bool> action in completeCallBack)
        {
            action.Invoke(item, isLeft);
        }
    }
    public void GameMissionComplete()
    {
        completeCallBack.Clear();
    }
}
