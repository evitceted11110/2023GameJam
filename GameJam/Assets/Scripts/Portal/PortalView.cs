using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PortalView : MonoBehaviour
{
    public int toRightID;
    public int toLeftID;

    public PortalAbsorber leftAbsorber;
    public PortalAbsorber rightAbsorber;
    public float genForce;
    private void Awake()
    {
        leftAbsorber.onAbsor = ConvertToRight;
        rightAbsorber.onAbsor = ConvertToLeft;
    }

    private void ConvertToRight(PortalAbsorber absorber, ItemBase item)
    {
        OnConvertObject(item, toRightID, rightAbsorber.throwTransform, genForce);
    }
    private void ConvertToLeft(PortalAbsorber absorber, ItemBase item)
    {
        OnConvertObject(item, toLeftID, leftAbsorber.throwTransform, -genForce);
    }
    public void OnConvertObject(ItemBase fromItem, int targetID, Transform genTransform, float force)
    {
        fromItem.OnPickUp();
        fromItem.OnConvert(() =>
        {
            var convertItem = ItemManager.Instance.GetItem(targetID);
            convertItem.transform.position = genTransform.position;
            convertItem.OnRelese(force);
        });
    }


}
