using Newtonsoft.Json;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using Unity.VisualScripting;
using UnityEngine;
using Newtonsoft.Json;
public class PlayerPrefsService : MonoBehaviour
{
    private static PlayerPrefsService _instance;
    public static PlayerPrefsService Instance
    {
        get
        {
            return _instance;
        }
    }
    public float[] bestTimes;
    private void Awake()
    {
        DontDestroyOnLoad(this.gameObject);
        _instance = this;
    }
    public void SavedUseTime(int stageIndex , float time)
    {
        if (time < bestTimes[stageIndex] || bestTimes[stageIndex] == 0)
        {
            bestTimes[stageIndex] = time;
            string josn = JsonConvert.SerializeObject(bestTimes);
            PlayerPrefs.SetString("USETIME", josn);
        }
    }

    public void RefreshUseTime()
    {
        string USETIME = PlayerPrefs.GetString("USETIME");
        bestTimes = JsonConvert.DeserializeObject<float[]>(USETIME);
    }
}
