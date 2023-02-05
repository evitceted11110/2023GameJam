using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SwitchButton : MonoBehaviour
{
    public SpriteRenderer buttonRenderer;
    public Sprite pressSprite;
    public Sprite releaseSprite;

    public Action onSwitch;

    private void Awake()
    {
        buttonRenderer.sprite = releaseSprite;
    }

    private void OnCollisionEnter2D(Collision2D collision)
    {
        if (collision.gameObject.GetComponent<PlayerController>() != null)
        {
            buttonRenderer.sprite = pressSprite;
            onSwitch();
        }
    }

    private void OnCollisionExit2D(Collision2D collision)
    {
        if (collision.gameObject.GetComponent<PlayerController>() != null)
        {
            buttonRenderer.sprite = releaseSprite;
        }

    }
}
