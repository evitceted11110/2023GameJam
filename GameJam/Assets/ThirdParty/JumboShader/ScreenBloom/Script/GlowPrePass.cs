using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class GlowPrePass : MonoBehaviour
{
    [SerializeField]
    private static RenderTexture PrePass;
    [SerializeField]
    private static RenderTexture Blurred;

    private Material _blurMat;
    public bool matchScreenSize;
    public Vector2Int screenSize = new Vector2Int(1136, 640);

    public float blurSize = 1.5f;
    public int blurRepeat = 4;

    [SerializeField]
    private RenderTexture logPrePass;
    [SerializeField]
    private RenderTexture logBlurred;
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

        PrePass = new RenderTexture(screenSize.x, screenSize.y, 24);
        // PrePass.antiAliasing = QualitySettings.antiAliasing;
        Blurred = new RenderTexture(screenSize.x >> 1, screenSize.y >> 1, 0);

        var glowShader = Shader.Find("Hidden/GlowReplace");
        cam.targetTexture = PrePass;
        cam.SetReplacementShader(glowShader, "Glowable");
        Shader.SetGlobalTexture("_GlowPrePassTex", PrePass);

        Shader.SetGlobalTexture("_GlowBlurredTex", Blurred);

        _blurMat = new Material(Shader.Find("Hidden/Blur"));
        _blurMat.SetVector("_BlurSize", new Vector2(Blurred.texelSize.x * blurSize, Blurred.texelSize.y * blurSize));
    }

    void OnRenderImage(RenderTexture src, RenderTexture dst)
    {
        Graphics.Blit(src, dst);

        Graphics.SetRenderTarget(Blurred);
        GL.Clear(false, true, Color.clear);

        Graphics.Blit(src, Blurred);

        for (int i = 0; i < blurRepeat; i++)
        {
            var temp = RenderTexture.GetTemporary(Blurred.width, Blurred.height);
            Graphics.Blit(Blurred, temp, _blurMat, 0);
            Graphics.Blit(temp, Blurred, _blurMat, 1);
            RenderTexture.ReleaseTemporary(temp);
        }
        logPrePass = PrePass;
        logBlurred = Blurred;
    }
}
