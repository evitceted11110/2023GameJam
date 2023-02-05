using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerControlSetting : ScriptableObject
{
    public string upKey;
    public string downKey;
    public string rightKey;
    public string leftKey;      
    public string actionKey;    //���Y/�ߨ�
    public string talkKey;      //����/���

    public float moveSpeed;
    public float jumpHeight;
    public float throwStrength;
}
