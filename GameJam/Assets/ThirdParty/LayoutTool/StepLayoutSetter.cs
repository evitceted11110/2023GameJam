using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class StepLayoutSetter : MonoBehaviour
{
    public bool autoUpdate;
    public Vector2 startPosition;
    public Direction direction;
    public StepDirection stepDirection;
    public float step;
    private ILayoutComponent[] layoutObjects;


    private void GetAllObject()
    {
        layoutObjects = transform.GetComponentsInChildren<ILayoutComponent>();

    }
    [ContextMenu("AutoLayout")]
    public void AutoLayout()
    {
        GetAllObject();

        Vector2 stepPosition = startPosition;
        for (int i = 0; i < layoutObjects.Length; i++)
        {
            Vector2 halfPosition = ((
                direction == Direction.Horizontal ?
                new Vector2(layoutObjects[i].GetWidth(), 0) :
                new Vector2(0, layoutObjects[i].GetHeight()))
                ) / 2;

            if (stepDirection == StepDirection.Negative)
            {
                halfPosition *= -1;
            }

            layoutObjects[i].transform.localPosition = stepPosition + halfPosition;

            Vector2 stepVector = direction == Direction.Horizontal ?
                    new Vector2(step, 0) :
                    new Vector2(0, step);

            stepPosition += halfPosition * 2;

            if (stepDirection == StepDirection.Positive)
            {
                stepPosition += stepVector;
            }
            else
            {
                stepPosition -= stepVector;
            }

        }
    }

    public enum StepDirection
    {
        Positive,
        Negative
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
            AutoLayout();
        }
    }
}
