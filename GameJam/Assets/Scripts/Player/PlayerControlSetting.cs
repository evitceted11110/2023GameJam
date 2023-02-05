using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerControlSetting : ScriptableObject
{
    public string upKey;
    public string downKey;
    public string rightKey;
    public string leftKey;      
    public string actionKey;    //丟擲/撿取
    public string talkKey;      //互動/對話

    public float moveSpeed;
    public float jumpHeight;
    public float throwStrength;
}
