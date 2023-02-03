using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Workbench : MonoBehaviour
{
    private List<ItemInfo> injectItemList = new List<ItemInfo>();
    public int curProductID;
    public List<int> mergeItems;
    public void SetProduct(int productID)
    {
        mergeItems = MergeTable.GetMergeItems(productID);
    }
    public void InjectItem(ItemInfo item)
    {
        //�n�b+�P�_���Ǫ���i�H�Q�`�J
        injectItemList.Add(item);
        CheckStartMerge();
    }
    private void CheckStartMerge()
    {
        if (mergeItems.Count == injectItemList.Count)
            Merge();
    }

    private void Merge()
    {
        CompleteMerge();
    }

    private void CompleteMerge()
    {
        injectItemList.Clear();
    }
}
