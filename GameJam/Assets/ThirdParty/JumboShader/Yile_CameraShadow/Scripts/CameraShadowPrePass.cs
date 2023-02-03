using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class CameraShadowPrePass : MonoBehaviour
{
    [SerializeField]
    private static RenderTexture Shadowed;

    private Material _shadowMat;
    private Material _prePassMat;
    public bool matchScreenSize = true;
    public Vector2Int screenSize = new Vector2Int(1136, 640);

    public int reqeat = 5;
    [Range(0, 0.1f)]
    public float blurValue = 1.1f;
    [Range(0, 0.01f)]
    public float loopShift = 0.0015f;
    public Vector2 shift = Vector2.zero;

    [SerializeField]
    private RenderTexture logShadowed;

    Camera cam;
    private void Awake()
    {
        cam = GetComponent<Camera>();
    }
    void OnEnable()
    {
        Refresh();
    }


    public void Refresh()
    {


        if (matchScreenSize)
            screenSize = new Vector2Int(Screen.width, Screen.height);

        Shadowed = new RenderTexture(screenSize.x, screenSize.y, 24, RenderTextureFormat.ARGB32);

        cam.targetTexture = null;
        var shadowReplaceMat = (Shader.Find("Yile/Shadow/ShadowReplace"));
        cam.SetReplacementShader(shadowReplaceMat, "Shadowable");

        Shader.SetGlobalTexture("_ShadowTex", Shadowed);

        _shadowMat = new Material(Shader.Find("Yile/Camera/Shadow"));

    }

    void OnRenderImage(RenderTexture src, RenderTexture dst)
    {
        Graphics.SetRenderTarget(Shadowed);
        GL.Clear(false, true, Color.clear);

        _shadowMat.SetInt("_Repeat", reqeat);
        _shadowMat.SetFloat("_BlurValue", blurValue);
        _shadowMat.SetVector("_Shift", shift);
        _shadowMat.SetFloat("_LoopShift", loopShift);
        Graphics.Blit(src, Shadowed, _shadowMat, 0);
        logShadowed = Shadowed;
    }
}
