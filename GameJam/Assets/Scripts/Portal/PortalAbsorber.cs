using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PortalAbsorber : MonoBehaviour
{
    public Transform throwTransform;
    public Action<PortalAbsorber, ItemBase> onAbsor;

    private void OnTriggerEnter2D(Collider2D other)
    {
        var item = other.GetComponent<ItemBase>();
        if (item != null)
        {
            onAbsor(this, item);
        }
    }

}
