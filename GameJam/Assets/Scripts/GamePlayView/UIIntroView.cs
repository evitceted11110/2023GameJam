using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class UIIntroView : MonoBehaviour
{
    [SerializeField]
    private Image leftTargetImage;
    [SerializeField]
    private Image rightTargetImage;

    private void Start()
    {
        var stateSetting = StageManager.Instance.GetStageSetting();
        SetTarget(leftTargetImage, stateSetting.leftProductItems);
        SetTarget(rightTargetImage, stateSetting.rightProductItems);
    }
    public void SetTarget(Image targetImage, List<ItemBase> items)
    {
        for (int i = 0; i < items.Count; i++)
        {
            targetImage.sprite = MergeIconService.Instance.GetMergeIcon(items[i].itemID).activeSp;
        }
    }

    public void SetActive(bool active)
    {
        gameObject.SetActive(active);

    }
    public void Show()
    {
        gameObject.SetActive(true);
    }

    public void Hide()
    {
        gameObject.SetActive(false);
    }
}
