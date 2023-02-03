using System.Collections;
using System.Collections.Generic;
using Unity.Collections;
using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(SpriteRenderer))]
public class SpriteUVRemapHandler : MonoBehaviour
{
    [ReadOnly]
    public SpriteRenderer spriteRenderer;
    public Vector2 leftButtom = new Vector2(0, 0);
    public Vector2 leftTop = new Vector2(0, 1);
    public Vector2 rightButtom = new Vector2(1, 0);
    public Vector2 rightTop = new Vector2(1, 1);

    private int LB = Shader.PropertyToID("_LB");
    private int LT = Shader.PropertyToID("_LT");
    private int RB = Shader.PropertyToID("_RB");
    private int RT = Shader.PropertyToID("_RT");
    public bool alwaysUpdate;
    public float MinY
    {
        get
        {

            if (spriteRenderer.sprite != null)
                return transform.position.y
                    + ((float)spriteRenderer.sprite.texture.height / 2f - spriteRenderer.sprite.pivot.y) / 100f
                    - ((float)spriteRenderer.sprite.texture.height / 2f / 100f * transform.localScale.y);
            return transform.position.y;
        }
    }
    public float MaxY
    {
        get
        {

            if (spriteRenderer.sprite != null)
                return transform.position.y
                    + ((float)spriteRenderer.sprite.texture.height / 2f - spriteRenderer.sprite.pivot.y) / 100f
                    + ((float)spriteRenderer.sprite.texture.height / 2f / 100f * transform.localScale.y);
            return transform.position.y;
        }
    }

    public float MinX
    {
        get
        {

            if (spriteRenderer.sprite != null)
                return transform.position.x
                    + ((float)spriteRenderer.sprite.texture.width / 2f - spriteRenderer.sprite.pivot.x) / 100f
                    - ((float)spriteRenderer.sprite.texture.width / 2f / 100f * transform.localScale.x);
            return transform.position.x;
        }
    }
    public float MaxX
    {
        get
        {

            if (spriteRenderer.sprite != null)
                return transform.position.x
                    + ((float)spriteRenderer.sprite.texture.width / 2f - spriteRenderer.sprite.pivot.x) / 100f
                    + ((float)spriteRenderer.sprite.texture.width / 2f / 100f * transform.localScale.x);
            return transform.position.x;
        }
    }



    private void Reset()
    {
        spriteRenderer = GetComponent<SpriteRenderer>();
        UpdateMaterial();
    }

    public void UpdateMaterial()
    {

        spriteRenderer.sharedMaterial.SetVector(LB, leftButtom);
        spriteRenderer.sharedMaterial.SetVector(LT, leftTop);
        spriteRenderer.sharedMaterial.SetVector(RB, rightButtom);
        spriteRenderer.sharedMaterial.SetVector(RT, rightTop);
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
