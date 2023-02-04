using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;
using System;

public class ItemBase : IPoolable, IItem
{
    public int itemID;
    public Collider2D _collider2D;
    public new Collider2D collider2D
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
    public Rigidbody2D _rigidbody2D;
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
    public SpriteRenderer _spriteRenderer;
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
    public float convertDuration = 1f;
    private bool forceHightLight;

    private void Awake()
    {
        spriteRenderer.sharedMaterial = Material.Instantiate(spriteRenderer.sharedMaterial);
    }
    public void OnConvert(Action onComplete)
    {
        DOVirtual.Float(0, 1, convertDuration, (value) =>
         {
             transform.localScale = Vector3.one * Mathf.Lerp(1, 0, value);
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
        forceHightLight = true;
        rigid2D.simulated = false;
        collider2D.enabled = false;
    }

    public void SetHighLight(bool isHighLight)
    {
        if (forceHightLight)
            return;
        rendererMaterial.SetFloat("_Brightness", isHighLight ? 1 : 0);
    }

    public void ResetItem()
    {
        transform.localScale = Vector3.one;
    }

    [ContextMenu("Test")]
    private void Test()
    {
        OnConvert(() => { });
    }

    public void OnRelese(float force)
    {
        transform.parent = GetManagerRoot();
        forceHightLight = false;
        collider2D.enabled = true;
        rigid2D.simulated = true;
        SetHighLight(false);
        rigid2D.AddForce(new Vector2(force, 0));
    }
}
