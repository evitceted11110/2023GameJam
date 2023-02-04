using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SingleStageSelector : MonoBehaviour
{

    public void OnClicked()
    {
        GameSceneManager.Instance.SelectStage(0);
    }
}
