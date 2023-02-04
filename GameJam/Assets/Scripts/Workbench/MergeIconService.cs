using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using static MergeIcon;

public class MergeIconService : MonoBehaviour
{
    private static MergeIconService _instance;
    public static MergeIconService Instance
    {
        get
        {
            return _instance;
        }
    }
    [SerializeField]
    private MergeIcon mergeIcon;
    private Dictionary<int, Icon> mergeScheduleIconDic = new Dictionary<int, Icon>();
    private void Awake()
    {
        DontDestroyOnLoad(this.gameObject);
        _instance = this;
        foreach (Icon info in mergeIcon.mergeScheduleIcon)
        {
            mergeScheduleIconDic.Add(info.itemID, info);
        }
    }

    public Icon GetMergeIcon(int itemID)
    {
        return mergeScheduleIconDic[itemID];
    }
}
