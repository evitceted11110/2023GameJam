using System;
using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class UICompleteView : MonoBehaviour
{
    public Sprite completeStar;
    public Sprite failStar;

    public Image[] starImages;

    public GameObject successRoot;
    public GameObject failRoot;

    public TextMeshProUGUI timeResultText;
    public void ShowResult(float useTime)
    { }
    public void SetActive(bool active)
    {
        gameObject.SetActive(active);
        if (active)
        {
            Show();
        }
    }

    public void Show()
    {
        if (GameResultManager.Instance.remainTime > 0)
            AudioManagerScript.Instance.PlayAudioClip(AudioClipConst.Finish);
        else
            AudioManagerScript.Instance.PlayAudioClip(AudioClipConst.Fail);

        var stageSetting = StageManager.Instance.GetStageSetting();
        bool[] resultStar = stageSetting.GetStarResult(GameResultManager.Instance.useTime);
        for (int i = 0; i < starImages.Length; i++)
        {
            starImages[i].sprite = resultStar[i] ? completeStar : failStar;
        }
        TimeSpan time = TimeSpan.FromSeconds(GameResultManager.Instance.useTime);
        timeResultText.text = string.Format("{0}:{1}", time.Minutes.ToString("00"), time.Seconds.ToString("00"));

        successRoot.SetActive(GameResultManager.Instance.remainTime > 0);
        failRoot.SetActive(GameResultManager.Instance.remainTime <= 0);

        gameObject.SetActive(true);
        PlayerPrefsService.Instance.SavedUseTime(GameSceneManager.Instance.stageIndex, GameResultManager.Instance.useTime);
    }

    public void Hide()
    {
        gameObject.SetActive(false);
    }

    public void OnCompelteClick()
    {
        AudioManagerScript.Instance.PlayAudioClip(AudioClipConst.ButtonConfirm);

        GameSceneManager.Instance.BackToStageSelect();
    }
}
