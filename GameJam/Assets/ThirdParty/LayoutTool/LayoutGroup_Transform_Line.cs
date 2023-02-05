using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LayoutGroup_Transform_Line : MonoBehaviour
{

    [SerializeField]
    private GameObject targetPrefab;
    [SerializeField]
    private LineRenderer lineRenderer;
    //[SerializeField, HideInInspector]
    private List<Transform> groupObjects;
    public float spaceing;
    // Use this for initialization
    void Start()
    {

    }

    [ContextMenu("GenerateObject")]
    public void GenerateObject()
    {
        if (groupObjects == null)
            groupObjects = new List<Transform>();
        else
        {
            foreach (var obj in groupObjects)
            {
                if (obj != null)
                    DestroyImmediate(obj.gameObject);
            }

        }
        groupObjects.Clear();

        for (int i = 0; i < lineRenderer.positionCount - 1; i++)
        {
            Vector3 pointA = lineRenderer.GetPosition(i);
            Vector3 pointB = lineRenderer.GetPosition(i + 1);
            float distance = Vector3.Distance(pointA, pointB);

            int spawnCount = (int)(distance / spaceing);
            for (int x = 0; x < spawnCount; x++)
            {
                Transform t = Instantiate(targetPrefab, this.transform).GetComponent<Transform>();
                t.gameObject.name = targetPrefab.name + groupObjects.Count;
                float normalize = (float)x / (float)spawnCount;
                Vector3 targetPosition = Vector3.Lerp(pointA, pointB, normalize);
                t.position = targetPosition;
                groupObjects.Add(t);
            }
        }
    }
    [ContextMenu("Clear")]
    public void ClearObject()
    {
        if (groupObjects == null)
            groupObjects = new List<Transform>();
        else
        {
            foreach (var obj in groupObjects)
            {
                if (obj != null)
                    DestroyImmediate(obj.gameObject);
            }

        }
        groupObjects.Clear();
    }

    [ContextMenu("GenerateObject_Sp")]
    public void GenerateObject_Space()
    {
        if (groupObjects == null)
            groupObjects = new List<Transform>();
        else
        {
            foreach (var obj in groupObjects)
            {
                if (obj != null)
                    DestroyImmediate(obj.gameObject);
            }

        }
        groupObjects.Clear();

        for (int i = 0; i < lineRenderer.positionCount - 1; i++)
        {
            Vector3 pointA = lineRenderer.GetPosition(i);
            Vector3 pointB = lineRenderer.GetPosition(i + 1);
            float distance = Vector3.Distance(pointA, pointB);

            while (distance < spaceing)
            {

            }
        }
    }

    public Vector3 LerpByDistance(Vector3 A, Vector3 B, float x)
    {
        Vector3 P = x * Vector3.Normalize(B - A) + A;
        return P;
    }

}
