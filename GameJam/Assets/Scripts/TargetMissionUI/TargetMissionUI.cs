using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TargetMissionUI : MonoBehaviour
{
    public MergeSchedule productSchedulePrefab;
    public Transform root;
    public List<ItemBase> testCurProductID;
    public ItemBase testInjectItem;
    private List<ItemBase> productItems;
    private Dictionary<int, MergeSchedule> productSchedule = new Dictionary<int, MergeSchedule>();
    private List<int> remainingItems = new List<int>();
    public bool isLeft;
    private void Start()
    {
        StageSetting stageSetting = StageManager.Instance.GetStageSetting();
        if (isLeft)
            SetProduct(stageSetting.leftProductItems);
        else
            SetProduct(stageSetting.rightProductItems);
        CollectManager.Instance.InjectCompleteActionEvent(RefreshTargetUI);
    }

    private void RefreshTargetUI(ItemBase item, bool isLeft)
    {
        if (this.isLeft == isLeft)
            InjectItem(item);
    }
    public void SetProduct(List<ItemBase> items)
    {
        productItems = items;
        remainingItems.Clear();
        foreach (ItemBase info in productItems)
        {
            MergeSchedule prodictItem = NewProductSchedule(info.itemID);
            prodictItem.inActiveSpriteRd.color = new Color(0.22f, 0.15f, 0.15f, 1);
            productSchedule.Add(info.itemID, prodictItem);
            remainingItems.Add(info.itemID);
        }
    }

    private MergeSchedule NewProductSchedule(int itemID)
    {
        MergeSchedule obj = Instantiate(productSchedulePrefab, root);
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
                productSchedule[id].inActiveSpriteRd.enabled = false;
                productSchedule[id].activeSpriteRd.enabled = true;
                break;
            }
        }
        CheckCompleteMission();
    }
    private void CheckCompleteMission()
    {
        if (remainingItems.Count == 0)
        {
            //DestroyProductSchedule();
            Debug.Log("Complete");
        }
    }

    private void DestroyProductSchedule()
    {
        Dictionary<int, MergeSchedule> _productSchedule = new Dictionary<int, MergeSchedule>(productSchedule);
        foreach (KeyValuePair<int, MergeSchedule> item in _productSchedule)
        {
            Destroy(productSchedule[item.Key].gameObject);
        }
        productSchedule.Clear();
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

    [ContextMenu("RefreshProduct")]
    private void RefreshProduct()
    {
        if (productSchedule.Count > 0)
        {
            DestroyProductSchedule();
        }
        SetProduct(testCurProductID);
    }
}
