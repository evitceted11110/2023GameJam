using System;
using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.SceneManagement;

public class Workbench : MonoBehaviour
{
    private Dictionary<int, MergeSchedule> mergeSchedule = new Dictionary<int, MergeSchedule>();
    public MergeSchedule mergeSchedulePrefab;
    public Transform root;
    private int curProductID;
    private List<int> mergeItems;
    private List<int> remainingItems;
    public ItemBase testInjectItem;
    public float popForce;
    public float horizontalForce;
    public bool isLeft;
    private int curMergeIndex = 0;
    private List<ItemBase> totalMergeItems;
    private void Awake()
    {
        StageSetting stageSetting = StageManager.Instance.GetStageSetting();
        if (isLeft)
        {
            SetProduct(stageSetting.leftProductItems[0]);
            totalMergeItems = stageSetting.leftProductItems;
        }
        else
        {
            SetProduct(stageSetting.rightProductItems[0]);
            totalMergeItems = stageSetting.rightProductItems;
        }

    }
    public void SetProduct(ItemBase item)
    {
        curProductID = item.itemID;

        mergeSchedule.Add(item.itemID, NewMergeSchedule(item.itemID));

        MergeSchedule equalSign = NewMergeSchedule((int)Symbol.Equl);
        mergeSchedule.Add(equalSign.GetHashCode(), equalSign);

        mergeItems = MergeTableService.mergeTable[item.itemID];
        remainingItems = MergeTableService.mergeTable[item.itemID];
        for (int i = 0; i < mergeItems.Count; i++)
        {
            MergeSchedule mergeItem = NewMergeSchedule(mergeItems[i]);
            mergeSchedule.Add(mergeItems[i], mergeItem);
            mergeItem.inActiveSpriteRd.color = new Color(0.22f, 0.15f, 0.15f, 1);
            if (i != mergeItems.Count - 1)
            {
                MergeSchedule plusSign = NewMergeSchedule((int)Symbol.plus);
                mergeSchedule.Add(plusSign.GetHashCode(), plusSign);
            }
        }
    }
    private MergeSchedule NewMergeSchedule(int itemID)
    {
        MergeSchedule obj = Instantiate(mergeSchedulePrefab, root);
        obj.inActiveSpriteRd.sprite = MergeIconService.Instance.GetMergeIcon(itemID).inActiveSp;
        obj.inActiveSpriteRd.enabled = true;
        obj.activeSpriteRd.sprite = MergeIconService.Instance.GetMergeIcon(itemID).activeSp;
        obj.activeSpriteRd.enabled = false;
        obj.itemID = itemID;
        return obj;
    }

    public bool CheckEnableInject(ItemBase item)
    {
        foreach (int id in remainingItems)
        {
            if (id == item.itemID)
                return true;
        }
        return false;
    }

    public void InjectItem(ItemBase item)
    {
        foreach (int id in remainingItems)
        {
            if (item.itemID == id)
            {
                remainingItems.Remove(id);
                mergeSchedule[id].inActiveSpriteRd.enabled = false;
                mergeSchedule[id].activeSpriteRd.enabled = true;
                break;
            }
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
        DestroyMergeSchedule();
        Debug.Log("Complete");
    }

    private void DestroyMergeSchedule()
    {
        Dictionary<int, MergeSchedule> _mergeSchedule = new Dictionary<int, MergeSchedule>(mergeSchedule);
        foreach (KeyValuePair<int, MergeSchedule> item in _mergeSchedule)
        {
            Destroy(mergeSchedule[item.Key].gameObject);
        }
        mergeSchedule.Clear();
    }

    [ContextMenu("ChangeMergerState")]
    public void RequestChangeMergeState()
    {
        if (totalMergeItems.Count > 1)
        {
            curMergeIndex = (int)Mathf.Repeat(curMergeIndex + 1, mergeItems.Count);
            RefreshProduct(totalMergeItems[curMergeIndex]);
        }
        else
            Debug.Log("Cann't ChangeMergeState");
    }

    [ContextMenu("InjectItem")]
    private void TestInjectItem()
    {
        if (CheckEnableInject(testInjectItem))
        {
            InjectItem(testInjectItem);
        }
        else
        {
            Debug.Log("Cann't Inject");
        }
    }

    private void RefreshProduct(ItemBase changeItem = null)
    {
        if (mergeSchedule.Count > 0)
        {
            DestroyMergeSchedule();
        }
        if (changeItem != null)
        {
            SetProduct(changeItem);
        }
    }

    public enum Symbol
    {
        Equl = -1,
        plus = -2
    }
}
