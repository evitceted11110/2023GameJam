using Newtonsoft.Json;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using static MergeIcon;

public class MergeTableService : MonoBehaviour
{
    private static MergeTableService _instance;
    public static MergeTableService Instance
    {
        get
        {
            return _instance;
        }
    }
    public static Dictionary<int, List<int>> mergeTable = new Dictionary<int, List<int>>();
    public TextAsset mergeTableJson;
    private void Awake()
    {
        DontDestroyOnLoad(this.gameObject);
        _instance = this;
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
        return new List<int>(mergeTable[productID]);
    }
}
