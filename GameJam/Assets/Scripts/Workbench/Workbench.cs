using System;
using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;
using static UnityEditor.Progress;

public class Workbench : MonoBehaviour
{
    public MergeTable mergeTable;
    public MergeIcon mergeIcon;
    private Dictionary<int , MergeSchedule> mergeSchedule = new Dictionary<int, MergeSchedule>();
    public MergeSchedule mergeSchedulePrefab;
    public Transform root;
    private int curProductID;
    private List<int> mergeItems;
    private List<int> remainingItems;
    public ItemBase testCurProductID;
    public ItemBase testInjectItem;
    public float popForce;
    public float horizontalForce;
    private void OnEnable()
    {
        mergeIcon.Init();
        mergeTable.InitTable();
    }
    public void SetProduct(ItemBase item)
    {
        mergeSchedule.Clear();
        mergeSchedule.Add(item.itemID, NewMergeSchedule(item.itemID));
        curProductID = item.itemID;
        MergeSchedule equalSign = NewMergeSchedule((int)Symbol.Equl);
        mergeSchedule.Add(equalSign.GetHashCode(), equalSign);

        mergeItems = mergeTable.GetMergeItems(item.itemID);
        remainingItems = mergeTable.GetMergeItems(item.itemID);
        for(int i = 0; i < mergeItems.Count; i++)
        {
            mergeSchedule.Add(mergeItems[i], NewMergeSchedule(mergeItems[i]));
            if(i != mergeItems.Count - 1)
            {
                MergeSchedule plusSign = NewMergeSchedule((int)Symbol.plus);
                mergeSchedule.Add(plusSign.GetHashCode(), plusSign);
            }
        }
    }
    private MergeSchedule NewMergeSchedule(int itemID)
    {
        MergeSchedule obj = Instantiate(mergeSchedulePrefab, root);
        obj.inActiveSpriteRd.sprite = mergeIcon.mergeScheduleIconDic[itemID].inActiveSp;
        obj.inActiveSpriteRd.enabled = true;
        obj.activeSpriteRd.sprite = mergeIcon.mergeScheduleIconDic[itemID].activeSp;
        obj.activeSpriteRd.enabled = false;
        obj.itemID = itemID;
        return obj;
    }

    public bool CheckEnableInject(ItemBase item)
    {
        foreach (int id in remainingItems)
        {
            if(id == item.itemID)
                return true;
        }
        return false;
    }

    public void InjectItem(ItemBase item)
    {
        foreach(int id in remainingItems)
        {
            remainingItems.Remove(item.itemID);
            mergeSchedule[id].inActiveSpriteRd.enabled = false;
            mergeSchedule[id].activeSpriteRd.enabled = true;
            break;
        }
        CheckStartMerge();
    }
    private void CheckStartMerge()
    {
        if (remainingItems.Count == 0)
            Merge();
    }

    private void Merge()
    {
        var item = ItemManager.Instance.GetItem(curProductID);
        item.transform.position = this.transform.position + (Vector3.up * 0.1f);
        item.rigid2D.AddForce(new Vector2(UnityEngine.Random.Range(-horizontalForce, horizontalForce), popForce));

        CompleteMerge();
    }

    private void CompleteMerge()
    {
        Dictionary<int, MergeSchedule> _mergeSchedule = new Dictionary<int, MergeSchedule>(mergeSchedule);
        foreach (KeyValuePair<int, MergeSchedule> item in _mergeSchedule)
        {
            Destroy(mergeSchedule[item.Key]);
        }
        Debug.Log("Complete");
    }

    [ContextMenu("InjectItem")]
    private void TestInjectItem()
    {
        InjectItem(testInjectItem);
    }

    [ContextMenu("RefreshProduct")]
    private void RefreshProduct()
    {
        SetProduct(testCurProductID);
    }

    public enum Symbol
    {
        Equl = -1,
        plus = -2
    }
}
