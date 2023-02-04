using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public interface IItem
{
    void OnConvert();
    void OnPickUp();
    void OnHighLight();
}
