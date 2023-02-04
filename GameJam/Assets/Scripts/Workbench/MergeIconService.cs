using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using static MergeIcon;

public class MergeIconService : MonoBehaviour
{
    public MergeIcon mergeIcon;
    public static Dictionary<int, Icon> mergeScheduleIconDic = new Dictionary<int, Icon>();

    private void OnEnable()
    {
        foreach (Icon info in mergeIcon.mergeScheduleIcon)
        {
            mergeScheduleIconDic.Add(info.itemID, info);
        }
    }

    public static Icon GetMergeIcon(int itemID)
    {
        return mergeScheduleIconDic[itemID];
    }
}
