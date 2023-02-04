using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MergeIcon : ScriptableObject
{
    public List<Icon> mergeScheduleIcon;
    [System.Serializable]
    public class Icon
    {
        public int itemID;
        public Sprite activeSp;
        public Sprite inActiveSp;
    }
}
