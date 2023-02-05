using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public interface IHighLightable
{
    Type GetType();
    void SetHighLight(bool isHighLight);
}
