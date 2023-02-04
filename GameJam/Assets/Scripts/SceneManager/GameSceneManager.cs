using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class GameSceneManager : MonoBehaviour
{
    private static GameSceneManager _manager;
    public static GameSceneManager Instance
    {
        get
        {
            return _manager;
        }
    }

    public int stageIndex { get; private set; }
    public const string STAGE_SCENE = "StageSelectScene";
    public const string LOADING_SCENE = "LoadingScene";
    public const string GAME_SCENE = "GamePlayScene";
    public string NextScene { get; private set; }
    private void Awake()
    {
        DontDestroyOnLoad(this.gameObject);
        _manager = this;
    }

    public void SelectStage(int _stageIndex)
    {
        stageIndex = _stageIndex;
        NextScene = GAME_SCENE;
        SceneManager.LoadScene(LOADING_SCENE);
    }

    public void BackToStageSelect()
    {
        stageIndex = 0;
        NextScene = STAGE_SCENE;
        SceneManager.LoadScene(LOADING_SCENE);
    }
}
