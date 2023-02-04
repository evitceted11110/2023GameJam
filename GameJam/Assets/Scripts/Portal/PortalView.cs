using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PortalView : MonoBehaviour
{
    public ProtalTransItemData leftItemData;
    public ProtalTransItemData rightItemData;

    public float genForce;
    private void Awake()
    {
        leftItemData.absorber.onAbsor = ConvertToRight;
        rightItemData.absorber.onAbsor = ConvertToLeft;
    }

    private void Start()
    {
        SetRightID(rightItemData.toID);
        SetLeftID(leftItemData.toID);
    }

    public void SetRightID(int id)
    {
        rightItemData.toID = id;
        rightItemData.iconRenderer.sprite = MergeIconService.Instance.GetMergeIcon(id).activeSp;
    }

    public void SetLeftID(int id)
    {
        leftItemData.toID = id;
        leftItemData.iconRenderer.sprite = MergeIconService.Instance.GetMergeIcon(id).activeSp;
    }

    private void ConvertToRight(PortalAbsorber absorber, ItemBase item)
    {
        OnConvertObject(item, rightItemData.toID, rightItemData.absorber.throwTransform, genForce);
    }
    private void ConvertToLeft(PortalAbsorber absorber, ItemBase item)
    {
        OnConvertObject(item, leftItemData.toID, leftItemData.absorber.throwTransform, -genForce);
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

[System.Serializable]
public class ProtalTransItemData
{
    public int toID;
    public SpriteRenderer iconRenderer;
    public PortalAbsorber absorber;
}
