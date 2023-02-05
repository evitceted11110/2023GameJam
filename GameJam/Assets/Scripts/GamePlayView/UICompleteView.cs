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
        var stageSetting = StageManager.Instance.GetStageSetting();
        bool[] resultStar = stageSetting.GetStarResult(GameResultManager.Instance.useTime);
        for (int i = 0; i < starImages.Length; i++)
        {
            starImages[i].sprite = resultStar[i] ? completeStar : failStar;
        }
        TimeSpan time = TimeSpan.FromSeconds(GameResultManager.Instance.useTime);
        timeResultText.text = string.Format("{0}:{1}", time.Minutes.ToString("00"), time.Seconds.ToString("00"));
        gameObject.SetActive(true);
    }

    public void Hide()
    {
        gameObject.SetActive(false);
    }

    public void OnCompelteClick()
    {
        GameSceneManager.Instance.BackToStageSelect();
    }
}
