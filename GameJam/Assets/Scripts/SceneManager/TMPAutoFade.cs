using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;
using DG.Tweening;

[RequireComponent(typeof(TextMeshProUGUI))]
public class TMPAutoFade : MonoBehaviour
{
    private TextMeshProUGUI textMesh;

    [SerializeField]
    private float duration;
    [SerializeField]
    private AnimationCurve fadeCurve;
    private bool fadeIn;

    private Tween fadeTween;

    private void OnEnable()
    {
        textMesh = GetComponent<TextMeshProUGUI>();
        textMesh.color = new Color(0, 0, 0, 0);
        fadeIn = false;
        Fade();
    }

    private void Fade()
    {
        KillTween();
        fadeIn = !fadeIn;
        fadeTween = DOVirtual.Float(0, 1, duration, (value) =>
        {
            float lerpValue = fadeIn ? value : 1 - value;
            float alpha = Mathf.Lerp(0, 1, fadeCurve.Evaluate(lerpValue));
            textMesh.color = Color.white * new Color(1, 1, 1, alpha);
        }).OnComplete(Fade);
    }

    private void OnDisable()
    {
        KillTween();
    }

    private void KillTween()
    {
        if (fadeTween != null)
            fadeTween.Kill();
        fadeTween = null;
    }
}
