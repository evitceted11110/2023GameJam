using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

[ExecuteInEditMode]
[RequireComponent(typeof(Image))]
[RequireComponent(typeof(Mask))]
[DefaultExecutionOrder(500)]
public class ShapeMaskSetter : UIBehaviour
{
    private int _Shape = Shader.PropertyToID("_Shape");
    private int _Width = Shader.PropertyToID("_Width");
    private int _Height = Shader.PropertyToID("_Height");
    private int _Radius = Shader.PropertyToID("_Radius");
    private int _Sides = Shader.PropertyToID("_Sides");
    private int _CustomRectangle = Shader.PropertyToID("_CustomRectangle");
    private int _RectDefine = Shader.PropertyToID("_RectDefine");
    private int _Size = Shader.PropertyToID("_Size");
    private int _Inverse = Shader.PropertyToID("_Inverse");

    private int _UseInnerGlow = Shader.PropertyToID("_UseInnerGlow");
    private int _Samples = Shader.PropertyToID("_Samples");
    private int _Scale = Shader.PropertyToID("_Scale");
    private int _EffectAmount = Shader.PropertyToID("_EffectAmount");


    private Image _image;
    private Mask _mask;
    [HideInInspector]
    public ShapeShaderEnum shape;
    [HideInInspector]
    [Range(0, 1)]
    public float width = 0.5f;
    [HideInInspector]
    [Range(0, 1)]
    public float height = 0.5f;
    [HideInInspector]
    [Range(0, 1)]
    public float radius = 0.5f;
    [HideInInspector]
    [Range(3, 16)]
    public int side = 3;
    [HideInInspector]
    public Vector4 customRectangle;
    [HideInInspector]
    public ShapShaderRectDefine rectDefine;
    [HideInInspector]
    public bool useInnerGlow;
    [HideInInspector]
    [Range(1, 32)]
    public int samples;

    [HideInInspector]
    [Range(0, 1f)]
    public float scale;
    [HideInInspector]
    [Range(0, 1f)]
    public float effectAmount;
    [SerializeField]
    public bool inverse;
    private WaitForEndOfFrame waitForEndOfFrame = new WaitForEndOfFrame();

    private new void OnEnable()
    {
        base.OnEnable();
        StartCoroutine(DelayRefresh());
    }

    private IEnumerator DelayRefresh()
    {
        yield return waitForEndOfFrame;
        Refresh();
    }

    private new void OnDestroy()
    {
        if (Application.isPlaying && _image)
            Destroy(_image.material);
        base.OnDestroy();

    }


    private Mask Mask
    {
        get
        {
            if (_mask == null)
            {
                _mask = GetComponent<Mask>();
            }
            return _mask;
        }
    }

    private Image Image
    {
        get
        {
            if (_image == null)
            {
                _image = GetComponent<Image>();
                var shader = Shader.Find("Yile/UI/Image_ShapeMask");
                var material = new Material(shader);
                material.name += material.GetInstanceID();
                _image.material = material;

            }
            return _image;
        }
    }

#if UNITY_EDITOR
    protected override void OnValidate()
    {
        Refresh();
    }
#endif

    private void UpdateRectTransform(Material material)
    {
        material.SetVector(_Size, new Vector2(Image.rectTransform.rect.width, Image.rectTransform.rect.height));
    }

    private void Refresh()
    {
        Material modifiedMaterial = null;
#if UNITY_EDITOR
        if (Application.isPlaying)
            modifiedMaterial = Image.material;
        else
            modifiedMaterial = Mask.GetModifiedMaterial(Image.material);
#else
        modifiedMaterial = Image.material;
#endif
        modifiedMaterial.SetFloat(_Shape, (int)shape);
        modifiedMaterial.SetFloat(_Width, width);
        modifiedMaterial.SetFloat(_Height, height);
        modifiedMaterial.SetFloat(_Radius, radius);
        modifiedMaterial.SetFloat(_Sides, side);
        modifiedMaterial.SetInt(_Inverse, inverse ? 1 : 0);
        modifiedMaterial.SetVector(_CustomRectangle, customRectangle);
        modifiedMaterial.SetFloat(_RectDefine, (int)rectDefine);

        modifiedMaterial.SetInt(_UseInnerGlow, useInnerGlow ? 1 : 0);
        modifiedMaterial.SetInt(_Samples, samples);
        modifiedMaterial.SetFloat(_Scale, scale);
        modifiedMaterial.SetFloat(_EffectAmount, effectAmount);
        UpdateRectTransform(modifiedMaterial);

        
        // Image.material = modifiedMaterial;
    }

    protected override void OnRectTransformDimensionsChange()
    {
        UpdateRectTransform(Mask.GetModifiedMaterial(Image.material));
    }
}
