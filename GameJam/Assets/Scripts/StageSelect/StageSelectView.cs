using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI.Extensions.Tweens;
using Newtonsoft.Json;
public class StageSelectView : MonoBehaviour
{
    public SingleStageSelector[] stageButtonList;
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
        StageSetting stageSetting = StageManager.Instance.GetStageSetting();
        for (int x = 0; x < stageButtonList.Length; x++)
        {
            bool[] starResult = stageSetting.GetStarResult(bestTimes[x]);
            for(int y = 0; y < starResult.Length; y++)
            {
                if (starResult[y])
                    stageButtonList[x].stars[y].SetActive(true);
                else
                    stageButtonList[x].stars[y].SetActive(false);
            }
        }
    }
}
