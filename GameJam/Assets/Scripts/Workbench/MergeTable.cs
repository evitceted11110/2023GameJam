using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MergeTable : MonoBehaviour
{
    private static Dictionary<int, List<int>> mergeTable;
    private static void InitTable()
    {
        mergeTable = new Dictionary<int, List<int>>();

        mergeTable.Add(Item.MEAT, new List<int> { Item.MEAT_RM });
        mergeTable.Add(Item.SCREW, new List<int> { Item.SCREW_RM });
    }

    public static List<int> GetMergeItems(int productID)
    {
        if (mergeTable == null)
            InitTable();
        return mergeTable[productID];
    }
}
