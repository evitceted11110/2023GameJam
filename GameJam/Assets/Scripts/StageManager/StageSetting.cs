using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class StageSetting : ScriptableObject
{
    public int stageIndex;
    public string note;
    public GameObject[] createObjects;
    public List<ItemBase> leftProductItems;
    public List<ItemBase> rightProductItems;
    //限制時間
    public float totalTime;

    //使用時間為基礎
    //ex 限制時間為 300s
    //[0] = 300
    //[1] = 240
    //[3] = 180
    public float[] starGap;

    public bool[] GetStarResult(float passTime)
    {
        if (passTime == -1)
        {
            return new bool[starGap.Length];
        }

        List<bool> resultStar = new List<bool>();

        for (int i = 0; i < starGap.Length; i++)
        {
            resultStar.Add(passTime < starGap[i]);
        }
        return resultStar.ToArray();
    }
}
