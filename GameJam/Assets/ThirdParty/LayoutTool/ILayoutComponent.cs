using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ILayoutComponent : MonoBehaviour, ILayoutObject
{
    public virtual float GetHeight()
    {
        return 0;
    }

    public virtual float GetWidth()
    {
        return 0;
    }

}
