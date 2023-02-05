using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UIPauseView : MonoBehaviour
{

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
