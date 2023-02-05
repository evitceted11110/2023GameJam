using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public interface IItem
{
    void OnConvert(Action onComplete);
    void OnPickUp();
    void OnRelese(float xforce, float yforce = 0);
    void SetHighLight(bool isHighLight);
}
