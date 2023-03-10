using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PortalView : MonoBehaviour
{
    public ProtalTransItemView leftItemView;
    public ProtalTransItemView rightItemView;
    public SwitchButton leftButton;
    public SwitchButton rightButton;
    public float genForce;
    private int rightIndex;
    private int leftIndex;
    private void Awake()
    {
        leftItemView.absorber.onAbsor = ConvertToRight;
        rightItemView.absorber.onAbsor = ConvertToLeft;

        if (leftButton != null)
        {
            leftButton.onSwitch += SwitchNextLeftItem;
        }
        if (rightButton != null)
        {
            rightButton.onSwitch += SwitchNextRightItem;
        }
        rightIndex = 0;
        leftIndex = 0;
    }

    private void Start()
    {
        SetRightID();
        SetLeftID();
    }

    public void SwitchNextRightItem()
    {
        rightIndex = (int)Mathf.Repeat(rightIndex + 1, StageManager.Instance.GetStageSetting().rightProtalGenList.Count);
        SetRightID();
    }
    public void SwitchNextLeftItem()
    {
        leftIndex = (int)Mathf.Repeat(leftIndex + 1, StageManager.Instance.GetStageSetting().leftProtalGenList.Count);
        SetLeftID();
    }
    private void SetRightID()
    {
        rightItemView.toID = StageManager.Instance.GetStageSetting().rightProtalGenList[rightIndex].itemID;
        rightItemView.iconRenderer.sprite = MergeIconService.Instance.GetMergeIcon(rightItemView.toID).activeSp;
    }

    private void SetLeftID()
    {
        leftItemView.toID = StageManager.Instance.GetStageSetting().leftProtalGenList[leftIndex].itemID; ;
        leftItemView.iconRenderer.sprite = MergeIconService.Instance.GetMergeIcon(leftItemView.toID).activeSp;
    }

    private void ConvertToRight(PortalAbsorber absorber, ItemBase item)
    {
        OnConvertObject(item, rightItemView.toID, rightItemView.absorber.throwTransform, genForce, rightItemView);
    }
    private void ConvertToLeft(PortalAbsorber absorber, ItemBase item)
    {
        OnConvertObject(item, leftItemView.toID, leftItemView.absorber.throwTransform, -genForce, leftItemView);
    }
    public void OnConvertObject(ItemBase fromItem, int targetID, Transform genTransform, float force, ProtalTransItemView view)
    {
        AudioManagerScript.Instance.PlayAudioClip(AudioClipConst.Portal_In);

        fromItem.OnPickUp();
        fromItem.OnConvert(() =>
        {
            var convertItem = ItemManager.Instance.GetItem(targetID);
            convertItem.transform.position = genTransform.position;
            convertItem.OnRelese(Random.Range((force/2f), force), Random.Range(-100, 100));
            view.PlayShoot();
            AudioManagerScript.Instance.PlayAudioClip(AudioClipConst.Portal_Out);

        });
    }
}

[System.Serializable]
public class ProtalTransItemView
{
    public int toID;
    public SpriteRenderer iconRenderer;
    public PortalAbsorber absorber;
    public ParticleSystem[] shootParticles;
    private int particleIndex = 0;
    public void PlayShoot()
    {
        particleIndex = (int)Mathf.Repeat(particleIndex + 1, shootParticles.Length);
        shootParticles[particleIndex].Play();
    }

}
