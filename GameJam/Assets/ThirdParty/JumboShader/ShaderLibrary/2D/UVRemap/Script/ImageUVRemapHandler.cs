using System.Collections;
using System.Collections.Generic;
using Unity.Collections;
using UnityEngine;
using UnityEngine.UI;

[ExecuteInEditMode]
[RequireComponent(typeof(Image))]
public class ImageUVRemapHandler : MonoBehaviour
{
    [ReadOnly]
    public Image image;
    public Vector2 leftButtom = new Vector2(0, 0);
    public Vector2 leftTop = new Vector2(0, 1);
    public Vector2 rightButtom = new Vector2(1, 0);
    public Vector2 rightTop = new Vector2(1, 1);

    private int LB = Shader.PropertyToID("_LB");
    private int LT = Shader.PropertyToID("_LT");
    private int RB = Shader.PropertyToID("_RB");
    private int RT = Shader.PropertyToID("_RT");
    public bool alwaysUpdate;
    // public bool updateMaterial = true;

    public Vector2 Center
    {
        get
        {
            if (image == null)
                return Vector2.zero;

            return image.rectTransform.position;
        }
    }

    public Vector2 ImageSize
    {
        get
        {
            if (image == null)
            {
                return Vector2.zero;
            }
            switch (image.canvas.renderMode)
            {
                case RenderMode.ScreenSpaceCamera:
                    return image.rectTransform.rect.size;

            }
            return image.rectTransform.rect.size;
        }
    }

    public Vector2 Pivot
    {
        get
        {
            if (image == null)
                return new Vector2(0.5f, 0.5f);

            return image.rectTransform.pivot;
        }
    }

    public float MinY
    {
        get
        {
            if (image.sprite != null)
                return Center.y
                        + (ImageSize.y / 2f - ImageSize.y * Pivot.y)
                        - (ImageSize.y / 2f / 1f * transform.localScale.y);
            
            return Center.y;
        }
    }
    public float MaxY
    {
        get
        {
            if (image.sprite != null)
                return Center.y
                    + (ImageSize.y / 2f - ImageSize.y * Pivot.y)
                    + (ImageSize.y / 2f / 1f * transform.localScale.y);

            return Center.y;
        }
    }

    public float MinX
    {
        get
        {
            if (image.sprite != null)
                return Center.x
                    + (ImageSize.x / 2f - ImageSize.x * Pivot.x)
                    - (ImageSize.x / 2f / 1f * transform.localScale.x);

            return Center.x;
        }
    }
    public float MaxX
    {
        get
        {
            if (image.sprite != null)
                return Center.x
                    + (ImageSize.x / 2f - ImageSize.x * Pivot.x)
                    + (ImageSize.x / 2f / 1f * transform.localScale.x);

            return Center.x;
        }
    }



    private void Reset()
    {
        image = GetComponent<Image>();
        UpdateMaterial();
    }

    public void UpdateMaterial()
    {
        //if (!updateMaterial)
        //    return;
        image.material.SetVector(LB, leftButtom);
        image.material.SetVector(LT, leftTop);
        image.material.SetVector(RB, rightButtom);
        image.material.SetVector(RT, rightTop);
    }


    public void LateUpdate()
    {
        if (alwaysUpdate)
            UpdateMaterial();
    }

#if UNITY_EDITOR
    private void OnValidate()
    {
        UpdateMaterial();
    }

#endif

}
