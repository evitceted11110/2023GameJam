using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GlowSetter : MonoBehaviour
{
    public Color GlowColor;
    public Color MainColor;
    public float LerpFactor = 10;
    public string[] materialColors;
    public Renderer[] Renderers
    {
        get;
        private set;
    }

    public Color CurrentColor
    {
        get { return _currentColor; }
    }

    private List<Material> _materials = new List<Material>();
    private Color _currentColor;
    private Color _targetColor;
    public bool loop;
    public bool setAlpha;
    float currentTime;
    void Start()
    {
        Renderers = GetComponentsInChildren<Renderer>(true);

        foreach (var renderer in Renderers)
        {
            _materials.AddRange(renderer.sharedMaterials);
        }

        for (int i = 0; i < _materials.Count; i++)
        {
            _materials[i].SetColor("_GlowColor", GlowColor);
        }
    }

    private void Update()
    {
        if (loop)
        {
            currentTime += Time.deltaTime * LerpFactor;
            SetColor(Color.Lerp(Color.black, GlowColor, Mathf.Sin(currentTime)));
        }    
    }

    private void SetColor(Color c)
    {
        for (int i = 0; i < _materials.Count; i++)
        {
            _materials[i].SetColor("_GlowColor", c);

        }
    }
}
