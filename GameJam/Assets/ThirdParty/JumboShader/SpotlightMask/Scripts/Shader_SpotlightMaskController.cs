using System.Collections;
using System.Collections.Generic;
using Unity.Collections;
using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(SpriteRenderer))]
public class Shader_SpotlightMaskController : MonoBehaviour
{
    private const int MAX_SPOTLIGHT_COUNT = 6;

    private const string POS_X = "_OffsetX";
    private const string POS_Y = "_OffsetY";
    private const string RADIUS = "_Radius";
    private Shader_SingleSpotlight[] _singleSpotLights;
    public Shader_SingleSpotlight[] singleSpotLights
    {
        get
        {
            if (_singleSpotLights == null)
            {
                _singleSpotLights = GetComponentsInChildren<Shader_SingleSpotlight>(true);
            }
            return _singleSpotLights;
        }
    }

    private SpriteRenderer _spriteRenderer;
    public SpriteRenderer spriteRenderer
    {
        get
        {
            if (_spriteRenderer == null)
            {
                _spriteRenderer = GetComponent<SpriteRenderer>();
            }
            return _spriteRenderer;
        }
    }
    private void LateUpdate()
    {
        for (int i = 0; i < singleSpotLights.Length; i++)
        {
            if (i >= MAX_SPOTLIGHT_COUNT)
            {
                Debug.LogWarning("聚光燈Shder 只支援最多6組燈光");
                return;
            }
            spriteRenderer.sharedMaterial.SetFloat(POS_X + (i + 1).ToString(), singleSpotLights[i].transform.position.x);
            spriteRenderer.sharedMaterial.SetFloat(POS_Y + (i + 1).ToString(), singleSpotLights[i].transform.position.y);
            spriteRenderer.sharedMaterial.SetFloat(RADIUS + (i + 1).ToString(), singleSpotLights[i].radis);

        }
    }

    [ContextMenu("Refresh")]
    private void Refresh()
    {
        _singleSpotLights = GetComponentsInChildren<Shader_SingleSpotlight>(true);
    }
}
