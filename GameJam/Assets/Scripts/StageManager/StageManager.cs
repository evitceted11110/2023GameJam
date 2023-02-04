using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class StageManager : MonoBehaviour
{
    private static StageManager _manager;
    public static StageManager Instance
    {
        get
        {
            return _manager;
        }
    }

    [SerializeField]
    private StageSettingCollection collection;

    private Dictionary<int, StageSetting> stageDictionary = new Dictionary<int, StageSetting>();

    private void Awake()
    {
        _manager = this;
        DontDestroyOnLoad(this.gameObject);
        foreach (var setting in collection.settings)
        {
            stageDictionary.Add(setting.stageIndex, setting);
        }
    }

    public StageSetting GetStageSetting(int stageIndex)
    {
        return stageDictionary[stageIndex];
    }
}
