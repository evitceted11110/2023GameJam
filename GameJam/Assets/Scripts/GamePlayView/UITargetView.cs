using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class UITargetView : MonoBehaviour
{
    [SerializeField]
    private Image[] leftTargetImages;
    [SerializeField]
    private Image[] rightTargetImages;

    private void Start()
    {
        GameResultManager.Instance.onProductComplete += OnProductUpdate;
        OnProductUpdate();
    }
    public void SetTarget(Image[] targetImage, List<ItemBase> requireItems, List<ItemBase> completeItems)
    {
        List<int> completeIDs = new List<int>();
        for (int i = 0; i < completeItems.Count; i++)
        {
            completeIDs.Add(completeItems[i].itemID);
        }

        for (int i = 0; i < targetImage.Length; i++)
        {
            if (i < requireItems.Count)
            {
                targetImage[i].sprite = MergeIconService.Instance.GetMergeIcon(requireItems[i].itemID).activeSp;

                if (completeIDs.Contains(requireItems[i].itemID))
                {
                    completeIDs.Remove(i);
                    targetImage[i].color = Color.white;
                }
                else
                {
                    targetImage[i].color = new Color(0.5f, 0.5f, 0.5f, 0.8f);
                }

                targetImage[i].gameObject.SetActive(true);
            }
            else
            {
                targetImage[i].gameObject.SetActive(false);
            }
        }
    }

    public void OnProductUpdate()
    {
        var stateSetting = StageManager.Instance.GetStageSetting();
        SetTarget(leftTargetImages, stateSetting.leftProductItems, GameResultManager.Instance.leftCompleteProduct);
        SetTarget(rightTargetImages, stateSetting.rightProductItems, GameResultManager.Instance.rightCompleteProduct);
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
