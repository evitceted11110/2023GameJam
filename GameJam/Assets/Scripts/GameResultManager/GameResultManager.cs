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

    public float remainTime
    {
        get
        {
            return StageManager.Instance.GetStageSetting().totalTime - useTime;
        }
    }
    public float useTime { get; private set; }
    public void setUseTime(float value)
    {
        useTime = value;
    }
    public GameState gameState { get; private set; }

    public void SetGameState(GameState state)
    {
        gameState = state;
        if (onGameStateChange != null)
        {
            onGameStateChange(gameState);
        }
    }
    private void Awake()
    {
        _manager = this;
        DontDestroyOnLoad(this.gameObject);
    }

    public Action<GameState> onGameStateChange;
    private List<Action> completeCallBack = new List<Action>();

    public void RegisterCompleteActionEvent(Action callBack)
    {
        completeCallBack.Add(callBack);
    }
    public void DeregisterCompleteActionEvent(Action callBack)
    {
        completeCallBack.Remove(callBack);
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

    public void ForceGameComplete() {
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

    public void ResetManager()
    {
        onGameStateChange = null;
        completeCallBack.Clear();
    }
}

public enum GameState
{
    READY,
    START,
    PLAYING,
    PAUSE,
    COMPLETE
}
