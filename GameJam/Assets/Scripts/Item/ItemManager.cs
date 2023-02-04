using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ItemManager : MonoBehaviour
{
    private static ItemManager _instance;
    public static ItemManager Instance
    {
        get
        {
            return _instance;
        }
    }
    [SerializeField]
    private ItemManagerCollection collection;

    private Dictionary<int, ItemPoolManager> managerDictionary = new Dictionary<int, ItemPoolManager>();
    private void Awake()
    {
        _instance = this;
        for (int i = 0; i < collection.managers.Count; i++)
        {
            ItemPoolManager manager = Instantiate<ItemPoolManager>(collection.managers[i].prefab, this.transform);
            manager.name = collection.managers[i].prefab.name;
            managerDictionary.Add(manager.itemID, manager);
        }
    }

    public ItemBase GetItem(int id)
    {
        return managerDictionary[id].Get<ItemBase>();
    }
}
