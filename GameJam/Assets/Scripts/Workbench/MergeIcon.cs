using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MergeIcon : ScriptableObject
{
    public List<Icon> mergeScheduleIcon;
    public Dictionary<int, Icon> mergeScheduleIconDic = new Dictionary<int, Icon>();
    public void Init()
    {
        foreach(Icon info in mergeScheduleIcon)
        {
            mergeScheduleIconDic.Add(info.itemID, info);
        }
    }
    [System.Serializable]
    public class Icon
    {
        public int itemID;
        public Sprite activeSp;
        public Sprite inActiveSp;
    }
}
