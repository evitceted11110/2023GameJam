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
}
