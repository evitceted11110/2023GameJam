using System;
using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;

public class GamePlayView : MonoBehaviour
{
    [SerializeField]
    private TextMeshProUGUI timerText;
    [SerializeField]
    private UIIntroView uIIntroView;
    [SerializeField]
    private UITargetView uITargetView;
    [SerializeField]
    private UIPauseView uIPauseView;
    [SerializeField]
    private UICompleteView uICompleteView;
    public GameObject timerRoot;
    private float _timer;
    private float Timer
    {
        get
        {
            return _timer;
        }
        set
        {
            _timer = value;
            GameResultManager.Instance.setUseTime(_timer);
            TimeSpan time = TimeSpan.FromSeconds(StageManager.Instance.GetStageSetting().totalTime - _timer);
            timerText.text = string.Format("{0}:{1}", time.Minutes.ToString("00"),time.Seconds.ToString("00"));
        }
    }
    public void Start()
    {
        GameResultManager.Instance.RegisterCompleteActionEvent(OnMissionComplete);
        GameResultManager.Instance.onGameStateChange += OnGameStateChange;
        GameResultManager.Instance.SetGameState(GameState.READY);
        Timer = 0;
    }

    private void Awake()
    {
    }

    void OnGameStateChange(GameState state)
    {
        uIIntroView.SetActive(state == GameState.READY);
        uITargetView.SetActive(state == GameState.PLAYING || state == GameState.PAUSE);
        uIPauseView.SetActive(state == GameState.PAUSE);
        uICompleteView.SetActive(state == GameState.COMPLETE);
        timerRoot.SetActive(state != GameState.COMPLETE);
    }

    void OnMissionComplete()
    {
        GameResultManager.Instance.SetGameState(GameState.COMPLETE);

    }

    public void GameStartClick()
    {
        GameResultManager.Instance.SetGameState(GameState.PLAYING);
    }
    public void ResumeClick()
    {
        GameResultManager.Instance.SetGameState(GameState.PLAYING);
    }
    public void ExitClick()
    {
        GameResultManager.Instance.SetGameState(GameState.PLAYING);
    }

    private void FixedUpdate()
    {
        if (GameResultManager.Instance.gameState == GameState.PLAYING)
        {
            Timer += Time.deltaTime;

        }
    }
    // Update is called once per frame
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Escape))
        {
            if (GameResultManager.Instance.gameState == GameState.PLAYING)
            {
                GameResultManager.Instance.SetGameState(GameState.PAUSE);
            }
            else
            {
                GameResultManager.Instance.SetGameState(GameState.PLAYING);
            }
        }
    }
}
