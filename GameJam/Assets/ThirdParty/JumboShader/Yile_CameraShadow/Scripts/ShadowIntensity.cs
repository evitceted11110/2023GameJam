using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

[ExecuteInEditMode]
[RequireComponent(typeof(Image))]
public class ShadowIntensity : MonoBehaviour {
    Image img;
    [Range(0, 5)][SerializeField]
    private float intensity;
    private void Awake()
    {
        img = GetComponent<Image>();
    }
    // Use this for initialization
    void Start () {
		
	}
	
	// Update is called once per frame
	void Update () {
        img.material.SetFloat("_Intensity", intensity);
	}
}
