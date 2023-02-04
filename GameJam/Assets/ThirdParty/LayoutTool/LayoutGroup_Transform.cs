using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LayoutGroup_Transform : MonoBehaviour
{
    //[SerializeField]
    //private GameObject targetPrefab;
    public LayoutOption option;
    [SerializeField, HideInInspector]
    public Transform[] groupObjects;
    public Vector2 offSet;
    public float spaceing;

    public enum LayoutOption
    {
        Horizontal,
        Vertical
    }

    public void GetChildren()
    {
        List<Transform> result = new List<Transform>();
        foreach (var t in transform.GetComponentsInChildren<Transform>())
        {
            if (t.parent == this.gameObject.transform)
            {
                result.Add(t);
            }
        }
        groupObjects = result.ToArray();
    }

    public void UpdateSorting()
    {
        for (int i = 0; i < groupObjects.Length; i++)
        {
            Vector2 resultOffSet = offSet +
                (option == LayoutGroup_Transform.LayoutOption.Horizontal ?
                new Vector2(spaceing * (i + 1), 0) :
                new Vector2(0, spaceing * (i + 1)))
                ;

            groupObjects[i].localPosition = resultOffSet;
        }
    }

    public void ForceUpdate()
    {
        if (gameObject.activeInHierarchy)
            StartCoroutine(WaitUpdateLayout());
    }

    IEnumerator WaitUpdateLayout()
    {
        yield return new WaitForEndOfFrame();
        GetChildren();
        UpdateSorting();
    }
}
