using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;
using System;

public class ItemBase : IPoolable, IItem
{
    public int itemID;
    public bool pickAble { get; private set; }
    private Collider2D _collider2D;
    public Collider2D itemCollider
    {
        get
        {
            if (_collider2D == null)
            {
                _collider2D = GetComponent<Collider2D>();
            }
            return _collider2D;
        }
    }
    private Rigidbody2D _rigidbody2D;
    public Rigidbody2D rigid2D
    {
        get
        {
            if (_rigidbody2D == null)
            {
                _rigidbody2D = GetComponent<Rigidbody2D>();
            }
            return _rigidbody2D;
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
    private Material rendererMaterial
    {
        get
        {
            return spriteRenderer.sharedMaterial;
        }
    }
    [SerializeField]
    private float heighLightValue = 1f;
    [SerializeField]
    private float autoDisappearDuration = 20f;
    private Tween disappearTween;
    [SerializeField]
    private float convertDuration = 1f;
    private bool forceHightLight;
    private Vector3 originScale;
    private void Awake()
    {
        originScale = this.transform.localScale;
        spriteRenderer.sharedMaterial = Material.Instantiate(spriteRenderer.sharedMaterial);
    }
    private void OnEnable()
    {
        pickAble = true;
        DoDisappearTimer();
    }
    public void OnConvert(Action onComplete)
    {
        KillTween();
        pickAble = false;
        DOVirtual.Float(0, 1, convertDuration, (value) =>
         {
             transform.localScale = originScale * Mathf.Lerp(1, 0, value);
             transform.localEulerAngles = transform.forward * Mathf.Lerp(0, 360 * 2, value);
         }).OnComplete(() =>
         {
             onComplete();
             ResetItem();
             Dispose();
         });
    }

    public void OnPickUp()
    {
        KillTween();
        forceHightLight = true;
        rigid2D.simulated = false;
        itemCollider.enabled = false;
    }

    public void SetHighLight(bool isHighLight)
    {
        if (forceHightLight)
            return;
        rendererMaterial.SetFloat("_Brightness", isHighLight ? heighLightValue : 0);
    }

    public void ResetItem()
    {
        transform.localScale = originScale;
        KillTween();
    }

    [ContextMenu("Test")]
    private void Test()
    {
        OnConvert(() => { });
    }

    public void OnRelese(float force)
    {
        DoDisappearTimer();
        transform.parent = GetManagerRoot();
        forceHightLight = false;
        itemCollider.enabled = true;
        rigid2D.simulated = true;
        SetHighLight(false);
        rigid2D.AddForce(new Vector2(force, 0));
    }

    private void DoDisappearTimer()
    {
        KillTween();
        disappearTween = DOVirtual.Float(0, 1, autoDisappearDuration, (value) =>
        {

        }).OnComplete(() =>
        {
            OnConvert(() => { });
        });
    }

    private void KillTween()
    {
        if (disappearTween != null)
            disappearTween.Kill();
        disappearTween = null;
    }
}
