using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI.Extensions.Tweens;
using Newtonsoft.Json;
public class StageSelectView : MonoBehaviour
{
    public SingleStageSelector[] stageButtonList;
    private void Start()
    {
        AudioManagerScript.Instance.CoverPlayAudioClip(AudioClipConst.Home_BGM);
    }
    private void OnEnable()
    {
        InitStageButtonDateSetup();
    }

    public void InitStageButtonDateSetup()
    {
        PlayerPrefsService.Instance.RefreshUseTime();
        float[] bestTimes = PlayerPrefsService.Instance.bestTimes;
        if (bestTimes == null)
        {
            PlayerPrefsService.Instance.bestTimes = new float[stageButtonList.Length];
            bestTimes = PlayerPrefsService.Instance.bestTimes;

        }
        else
        {
            if(bestTimes.Length < stageButtonList.Length)
            {
                PlayerPrefsService.Instance.bestTimes = new float[stageButtonList.Length];
                for(int x = 0; x < stageButtonList.Length; x++)
                {
                    PlayerPrefsService.Instance.bestTimes[x] = bestTimes[x];
                    bestTimes = PlayerPrefsService.Instance.bestTimes;
                }
            }
        }
        StageSetting stageSetting = StageManager.Instance.GetStageSetting();
        for (int x = 0; x < stageButtonList.Length; x++)
        {
            if (x < bestTimes.Length)
            {
                bool[] starResult = stageSetting.GetStarResult(bestTimes[x]);
                for (int y = 0; y < starResult.Length; y++)
                {
                    if (starResult[y])
                        stageButtonList[x].stars[y].SetActive(true);
                    else
                        stageButtonList[x].stars[y].SetActive(false);
                }
            }
            else
            {
                for (int y = 0; y < stageButtonList[x].stars.Length; y++)
                {
                    stageButtonList[x].stars[y].SetActive(false);
                }
            }
           
        }
    }
}
