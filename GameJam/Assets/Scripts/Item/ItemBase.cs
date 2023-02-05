using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;
using System;

public class ItemBase : IPoolable, IItem, IHighLightable
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
    private Tween convertTween;
    private bool forceHightLight;
    private Vector3 originScale;
    private void Awake()
    {
        originScale = this.transform.localScale;
        spriteRenderer.sharedMaterial = Material.Instantiate(spriteRenderer.sharedMaterial);
    }
    private void OnEnable()
    {
        ResetItem();
        pickAble = true;
        forceHightLight = false;
        itemCollider.enabled = true;
        rigid2D.simulated = true;
        SetHighLight(false);
        DoDisappearTimer();

        GameResultManager.Instance.onGameStateChange += OnGameStateChange;

    }

    private void OnDisable()
    {
        GameResultManager.Instance.onGameStateChange -= OnGameStateChange;

    }

    public void OnConvert(Action onComplete)
    {
        KillTween();
        pickAble = false;
        convertTween = DOVirtual.Float(0, 1, convertDuration, (value) =>
          {
              transform.localScale = originScale * Mathf.Lerp(1, 0, value);
              transform.localEulerAngles = transform.forward * Mathf.Lerp(0, 360 * 2, value);
          }).OnComplete(() =>
          {
              onComplete();
              ResetItem();
              Dispose();
              KillTween();
          });
    }

    void OnGameStateChange(GameState state)
    {
        switch (state)
        {
            case GameState.PAUSE:
                OnPause();
                break;
            case GameState.PLAYING:
                OnResume();
                break;
        }
    }

    private void OnPause()
    {
        if (convertTween != null)
        {
            convertTween.Pause();
        }
        if (disappearTween != null)
        {
            disappearTween.Pause();
        }
        rigid2D.simulated = false;
    }

    private void OnResume()
    {
        if (convertTween != null)
        {
            convertTween.Play();
        }
        if (disappearTween != null)
        {
            disappearTween.Play();
        }
        rigid2D.simulated = true;
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

        if (convertTween != null)
            convertTween.Kill();
        convertTween = null;
    }


}
