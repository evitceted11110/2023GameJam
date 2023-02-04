using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GameResultManager : MonoBehaviour
{
    private static GameResultManager _manager;
    public static GameResultManager Instance
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

    private List<Action> completeCallBack;
    public void InjectCompleteActionEvent(Action callBack)
    {
        completeCallBack.Add(callBack);
    }

    private bool isleftComplte;
    public bool IsLeftComplte
    {
        set
        {
            isleftComplte = value;
            OnMissionCompleteCheck();
        }
        get { return isleftComplte; }
    }

    private bool isRightComplte;
    public bool IsRightComplte
    {
        set
        {
            isRightComplte = value;
            OnMissionCompleteCheck();
        }
        get { return isRightComplte; }
    }

    private void OnMissionCompleteCheck()
    {
        if (isleftComplte && isRightComplte)
        {
            isleftComplte = false;
            isRightComplte = false;
            foreach (Action action in completeCallBack)
            {
                action.Invoke();
            }
            CollectManager.Instance.GameMissionComplete();
            Debug.LogWarning("Mission Complete");
            completeCallBack.Clear();
        }
    }
}
