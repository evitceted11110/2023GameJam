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
    private Dictionary<object, ItemBase> currentHighLightDictionary = new Dictionary<object, ItemBase>();
    private Dictionary<int, ItemPoolManager> managerDictionary = new Dictionary<int, ItemPoolManager>();
    private void Awake()
    {
        DontDestroyOnLoad(this.gameObject);
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

    public void SetHighLight(object obj, ItemBase item)
    {
        if (!currentHighLightDictionary.ContainsKey(obj))
        {
            currentHighLightDictionary.Add(obj, item);
        }
        else
        {
            if (currentHighLightDictionary[obj] != null)
                currentHighLightDictionary[obj].SetHighLight(false);
            if (item != null)
                item.SetHighLight(true);
            currentHighLightDictionary[obj] = item;
        }
    }

    public ItemBase GetHightLightItem(object obj)
    {
        if (currentHighLightDictionary.ContainsKey(obj))
        {
            return currentHighLightDictionary[obj];
        }
        return null;
    }
}
