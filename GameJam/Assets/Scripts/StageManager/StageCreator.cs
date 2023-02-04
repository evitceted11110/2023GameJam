using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class StageCreator : MonoBehaviour
{
    private void Awake()
    {
        StageSetting setting = StageManager.Instance.GetStageSetting(GameSceneManager.Instance.stageIndex);

        for (int i = 0; i < setting.createObjects.Length; i++)
        {
            Instantiate(setting.createObjects[i]);
        }
    }
}
