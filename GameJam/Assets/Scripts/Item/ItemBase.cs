using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;
using System;

public class ItemBase : IPoolable, IItem
{
    public int itemID;
    public SpriteRenderer spriteRenderer;
    public float convertDuration = 1f;
    public void OnConvert(Action onComplete)
    {
        DOVirtual.Float(0, 1, convertDuration, (value) =>
         {
             transform.localScale = Vector3.one * Mathf.Lerp(1, 0, value);
             transform.localEulerAngles = transform.forward * Mathf.Lerp(0, 360 * 2, value);
         }).OnComplete(() =>
         {
             onComplete();
             ResetItem();
             Dispose();
         });
    }

    public void OnPickUp()
    {

    }

    public void SetHighLight(bool isHighLight)
    {

    }

    public void ResetItem()
    {
        transform.localScale = Vector3.one;
    }

    [ContextMenu("Test")]
    private void Test()
    {
        OnConvert(() => { });
    }
}
