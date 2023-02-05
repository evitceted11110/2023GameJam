using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ItemPoolManager : IPoolManager
{
    public ItemBase item
    {
        get
        {
            return prefab as ItemBase;
        }
    }

    public int itemID
    {
        get
        {
            return item.itemID;
        }
    }

    private void Awake()
    {
        Setup();
    }
}
