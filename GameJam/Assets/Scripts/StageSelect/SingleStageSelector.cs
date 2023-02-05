using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;

public class SingleStageSelector : MonoBehaviour
{
    public int index;
    public GameObject[] stars;
    public TextMeshProUGUI bestTime;
    public void OnClicked()
    {
        GameSceneManager.Instance.SelectStage(index);
    }
}
