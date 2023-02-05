using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class UIIntroView : MonoBehaviour
{
    [SerializeField]
    private Image[] leftTargetImages;
    [SerializeField]
    private Image[] rightTargetImages;

    private void Start()
    {
        var stateSetting = StageManager.Instance.GetStageSetting();
        SetTarget(leftTargetImages, stateSetting.leftProductItems);
        SetTarget(rightTargetImages, stateSetting.rightProductItems);
    }
    public void SetTarget(Image[] targetImages, List<ItemBase> items)
    {
        for (int i = 0; i < targetImages.Length; i++)
        {
            if (i < items.Count)
            {
                targetImages[i].sprite = MergeIconService.Instance.GetMergeIcon(items[i].itemID).activeSp;
                targetImages[i].gameObject.SetActive(true);
            }
            else
            {
                targetImages[i].gameObject.SetActive(false);
            }
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
