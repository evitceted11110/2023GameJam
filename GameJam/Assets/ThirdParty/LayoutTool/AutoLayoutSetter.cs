using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;


[ExecuteInEditMode]
public class AutoLayoutSetter : MonoBehaviour
{
    public bool includeGrandChildren = true;
    public bool autoUpdate;
    public Vector2 edgePosition;
    public Direction direction;

    private ILayoutComponent[] layoutObjects;


    private void GetAllObject()
    {
        layoutObjects = transform.GetComponentsInChildren<ILayoutComponent>();

        if (!includeGrandChildren)
        {
            List<ILayoutComponent> tempLayout = new List<ILayoutComponent>();

            for (int i = 0; i < layoutObjects.Length; i++)
            {
                if (layoutObjects[i].transform.parent == this.transform)
                {
                    tempLayout.Add(layoutObjects[i]);
                }
            }

            layoutObjects = tempLayout.ToArray();
        }
    }

    public void UpdateLayout()
    {
        if (gameObject.activeInHierarchy)
            StartCoroutine(DoLayout());
        //GetAllObject();

        //Vector3 startPosition = direction == Direction.Horizontal ?
        //    new Vector3(edgePosition.x, 0, 0) :
        //    new Vector3(0, edgePosition.x, 0);

        //Vector3 endPosition = direction == Direction.Horizontal ?
        //    new Vector3(edgePosition.y, 0, 0) :
        //    new Vector3(0, edgePosition.y, 0);

        //float totalSize = 0;

        //for (int i = 0; i < layoutObjects.Length; i++)
        //{
        //    totalSize += direction == Direction.Horizontal ? layoutObjects[i].GetWidth() : layoutObjects[i].GetHeight();
        //}
        //float stepSize = 0;
        //for (int i = 0; i < layoutObjects.Length; i++)
        //{
        //    float halfSize = ((direction == Direction.Horizontal ? layoutObjects[i].GetWidth() : layoutObjects[i].GetHeight()) / 2);

        //    stepSize += halfSize;
        //    layoutObjects[i].transform.localPosition = Vector3.Lerp(startPosition, endPosition, stepSize / totalSize);
        //    stepSize += halfSize;
        //}
    }

    IEnumerator DoLayout()
    {
        yield return new WaitForEndOfFrame();
        Refresh();
    }
    public enum Direction
    {
        Vertical,
        Horizontal,
    }

    private void LateUpdate()
    {
        if (autoUpdate)
        {
            UpdateLayout();
        }
    }
    [ContextMenu("UpdateLayout")]
    public void EditorRefresh()
    {
        Refresh();
    }

    void Refresh()
    {
        GetAllObject();

        Vector3 startPosition = direction == Direction.Horizontal ?
            new Vector3(edgePosition.x, 0, 0) :
            new Vector3(0, edgePosition.x, 0);

        Vector3 endPosition = direction == Direction.Horizontal ?
            new Vector3(edgePosition.y, 0, 0) :
            new Vector3(0, edgePosition.y, 0);

        float totalSize = 0;

        for (int i = 0; i < layoutObjects.Length; i++)
        {
            totalSize += direction == Direction.Horizontal ? layoutObjects[i].GetWidth() : layoutObjects[i].GetHeight();
        }
        float stepSize = 0;
        for (int i = 0; i < layoutObjects.Length; i++)
        {
            float halfSize = ((direction == Direction.Horizontal ? layoutObjects[i].GetWidth() : layoutObjects[i].GetHeight()) / 2);

            stepSize += halfSize;
            layoutObjects[i].transform.localPosition = Vector3.Lerp(startPosition, endPosition, stepSize / totalSize);
            stepSize += halfSize;
        }
    }
}
