using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ItemBase : IPoolable, IItem
{
    public int itemID;
    public void OnConvert()
    {
        throw new System.NotImplementedException();
    }

    public void OnHighLight()
    {
        throw new System.NotImplementedException();
    }

    public void OnPickUp()
    {
        throw new System.NotImplementedException();
    }

}
