using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class HomeSelector : MonoBehaviour
{
    public void OnClick() {
        GameSceneManager.Instance.BackToStageSelect();
    }
}
