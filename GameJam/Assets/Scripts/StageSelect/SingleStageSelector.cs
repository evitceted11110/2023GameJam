using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SingleStageSelector : MonoBehaviour
{
    public int index;
    public void OnClicked()
    {
        GameSceneManager.Instance.SelectStage(index);
    }
}
