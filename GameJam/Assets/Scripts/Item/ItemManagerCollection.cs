using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ItemManagerCollection : ScriptableObject
{
    public List<ManagerItem> managers;
}

[System.Serializable]
public class ManagerItem
{
    public string note;
    public ItemPoolManager prefab;
}
