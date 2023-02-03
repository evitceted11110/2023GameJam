using UnityEngine;
using System.Collections;
using UnityEngine.UI;

[RequireComponent(typeof(Renderer))]
public class RippleWaterCollisionControl : MonoBehaviour
{
    private int arrayCount = 8;                         //最多支援同時8個水波
    private int waveNumber = 1;                         //當前水波Index
    private float[] waveAmplitude;                      //各水波振幅
    private float[] distance;                           //水波擴散距離
    private Renderer waveRenderer;
    private Material targetMat;

    public bool reverseWave = false;
    public float reverseWaveMaxDistance;
    public float speedWaveSpread = 0.15f;
    public float waveAmplitudeDecreaseRate = 0.98f;
    public float minMagnitude = 1;
    public float MaxMagnitude = 2;
    public Camera cam;
    public bool useClick;
    public bool useCollider;
    public GameObject colliderObject;
    public Vector2 scaleRange = Vector2.one;

    private Vector2 size = Vector2.one;

    private void Awake()
    {
        if (cam == null)
            cam = Camera.main;

        waveRenderer = GetComponent<Renderer>();
        waveAmplitude = new float[arrayCount];
        distance = new float[arrayCount];
    }

    // Update is called once per frame
    void LateUpdate()
    {
        for (int i = 0; i < waveAmplitude.Length; i++)
        {
            waveAmplitude[i] = waveRenderer.material.GetFloat("_WaveAmplitude" + (i + 1));

            if (waveAmplitude[i] > 0)
            {
                if (reverseWave)
                    distance[i] -= speedWaveSpread;
                else
                    distance[i] += speedWaveSpread;
                waveRenderer.material.SetFloat("_Distance" + (i + 1), distance[i]);
                waveRenderer.material.SetFloat("_WaveAmplitude" + (i + 1), waveAmplitude[i] * waveAmplitudeDecreaseRate);
            }
            if (waveAmplitude[i] < 0.0001)
            {
                distance[i] = 0;
                waveRenderer.material.SetFloat("_Distance" + (i + 1), distance[i]);
                waveRenderer.material.SetFloat("_WaveAmplitude" + (i + 1), 0);

            }

        }

        if (useClick)
        {
            if (Input.GetMouseButtonUp(0))
            {
                if (!useCollider)
                {
                    Vector3 mousePos = cam.ScreenToWorldPoint(Input.mousePosition);
                    if (mousePos.x <= scaleRange.x && mousePos.x >= -scaleRange.x &&
                        mousePos.y <= scaleRange.y && mousePos.y >= -scaleRange.y
                        )
                    {
                        UpdateWave(mousePos);
                    }
                }
                else
                {
                    RaycastHit2D hit = Physics2D.Raycast(cam.ScreenToWorldPoint(Input.mousePosition), Vector2.zero);
                    if (hit.collider != null)
                    {
                        if (hit.transform.gameObject == colliderObject)
                        {
                            UpdateWave(hit.point);
                        }
                    }
                }
            }
        }
    }


    public void UpdateWave(Vector2 position, float magnitude = -999)
    {
        int tempI = (int)Mathf.Repeat(waveNumber, waveAmplitude.Length);
        if (waveAmplitude[tempI] != 0)
        {
            return;
        }
        waveNumber++;
        if (waveNumber > waveAmplitude.Length)
        {
            waveNumber = 1;
        }
        int index = waveNumber - 1;
        waveAmplitude[index] = 0;
        if (reverseWave)
        {
            distance[index] = reverseWaveMaxDistance;
            waveRenderer.material.SetFloat("_Distance" + waveNumber, distance[index]);
        }
        else
        {
            distance[index] = 0;
        }


        if (magnitude == -999)
            magnitude = Random.Range(minMagnitude, MaxMagnitude);

        waveRenderer.material.SetFloat("_OffsetX" + waveNumber, position.x);
        waveRenderer.material.SetFloat("_OffsetY" + waveNumber, position.y);
        waveRenderer.material.SetFloat("_WaveAmplitude" + waveNumber, magnitude);

    }


    private void OnGUI()
    {
        //GUI.Label(new Rect(0, 0, 500, 500), (1f / Time.deltaTime).ToString());
    }

#if UNITY_EDITOR
    private void OnDrawGizmos()
    {
        if (!useCollider && useClick)
        {
            Gizmos.color = Color.green;
            Gizmos.DrawWireCube(transform.position, new Vector2(scaleRange.x, scaleRange.y) * 2);
        }
    }
#endif
}
