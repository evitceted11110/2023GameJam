using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Newtonsoft.Json;
using System.Linq;

public class MergeTable : ScriptableObject
{
    private Dictionary<int, List<int>> mergeTable;
    public TextAsset mergeTableJson;
    public void InitTable()
    {
        mergeTable = new Dictionary<int, List<int>>();
        var mergeMaterial = JsonConvert.DeserializeObject<MergeMaterial[]>(mergeTableJson.text);
        foreach (MergeMaterial info in mergeMaterial)
        {
            if (!string.IsNullOrEmpty(info.ITEM_FORMULA))
            {
                int[] FORMULA = JsonConvert.DeserializeObject<int[]>(info.ITEM_FORMULA);
                mergeTable.Add(info.ITEM_ID, FORMULA.ToList());
            }
        }
    }

    public List<int> GetMergeItems(int productID)
    {
        if (mergeTable == null)
            InitTable();
        return new List<int>(mergeTable[productID]);
    }

}
