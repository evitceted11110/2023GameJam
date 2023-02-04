using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class PlayerController : MonoBehaviour
{
    private const string ANIMATOR_WALK = "walk";
    private const string ANIMATOR_THROW = "doThrow";
    private const string ANIMATOR_HAS_ITEM = "hasItem";

    public PlayerControlSetting playerControlSetting;
    [SerializeField]
    private Animator animator;
    [SerializeField]
    private SpriteRenderer spriteRenderer;
    [Range(0, .3f)]
    [SerializeField]
    private float m_JumpSmoothing = .05f;  // How much to smooth out the movement
    [Range(0, .3f)]
    [SerializeField]
    private float m_MovementSmoothing = .05f;  // How much to smooth out the movement
    [SerializeField]
    private bool m_AirControl = false;                         // Whether or not a player can steer while jumping;
    [SerializeField]
    private LayerMask m_WhatIsGround;                          // A mask determining what is ground to the character
    [SerializeField]
    private Transform m_GroundCheck;                           // A position marking where to check if the player is grounded.
    
    const float k_GroundedRadius = .2f; // Radius of the overlap circle to determine if grounded
    [SerializeField]
    private Transform m_ForwardCheck;                           // A position marking where to check if the player is grounded.
    const float k_ForwardRadius = .2f; // Radius of the overlap circle to determine if grounded



    private bool m_Grounded;            // Whether or not the player is grounded.
    const float k_CeilingRadius = .2f; // Radius of the overlap circle to determine if the player can stand up
    private Rigidbody2D m_Rigidbody2D;
    private bool m_FacingRight = true;  // For determining which way the player is currently facing.
    private Vector3 m_Velocity = Vector3.zero;
    private Vector3 m_MoveVelocity = Vector3.zero;

    [SerializeField]
    private float jumpTimeThreshole = 0.05f;
    private float jumpTimer;
    [SerializeField]
    private float actionThreshole = 0.05f;
    private float actionTimer;
    [Header("Pick")]
    [SerializeField]
    private Transform pickItemTransform;
    private ItemBase currentPickingItem;


    private void Awake()
    {
        m_Rigidbody2D = GetComponent<Rigidbody2D>();
    }

    private void Update()
    {
        InputDetect();
    }

    private void FixedUpdate()
    {
        AddTimer();
        m_Grounded = false;

        Collider2D[] groundColliders = Physics2D.OverlapCircleAll(m_GroundCheck.position, k_GroundedRadius);
        for (int i = 0; i < groundColliders.Length; i++)
        {
            if (groundColliders[i].gameObject != gameObject)
            {
                m_Grounded = true;
            }
        }

        Collider2D[] forwardColliders = Physics2D.OverlapCircleAll(m_ForwardCheck.position, k_ForwardRadius);

        //前方有物品 優先拿取
        if (!ItemDetect(forwardColliders))
        {
            ItemDetect(groundColliders);
        }

    }

    private void AddTimer()
    {
        jumpTimer += Time.deltaTime;
        actionTimer += Time.deltaTime;
    }
    private void InputDetect()
    {
        if (Input.GetKeyDown(playerControlSetting.upKey))
        {
            Move(0, true);
        }
        //else
        if (Input.GetKey(playerControlSetting.rightKey))
        {
            Move(playerControlSetting.moveSpeed, false);
        }
        else
        if (Input.GetKey(playerControlSetting.leftKey))
        {
            Move(-playerControlSetting.moveSpeed, false);
        }
        else
        {
            animator.SetBool(ANIMATOR_WALK, false);
        }

        //else
        if (Input.GetKeyDown(playerControlSetting.downKey))
        {

        }
        // else
        if (Input.GetKeyDown(playerControlSetting.actionKey))
        {
            DoAction();
        }
    }

    private bool ItemDetect(Collider2D[] colliders)
    {
        for (int i = 0; i < colliders.Length; i++)
        {
            if (colliders[i].gameObject != gameObject)
            {

                var item = colliders[i].GetComponent<ItemBase>();
                if (item != null)
                {
                    ItemManager.Instance.SetHighLight(this, item);
                    return true;
                }
            }
        }
        ItemManager.Instance.SetHighLight(this, null);
        return false;
    }

    public void Move(float move, bool jump)
    {
        if (m_Grounded || m_AirControl)
        {
            Vector3 targetVelocity = new Vector2(move * 10f, m_Rigidbody2D.velocity.y);
            m_Rigidbody2D.velocity = Vector3.SmoothDamp(m_Rigidbody2D.velocity, targetVelocity, ref m_Velocity, m_MovementSmoothing);
            animator.SetBool(ANIMATOR_WALK, true);
            if (move > 0 && !m_FacingRight)
            {
                Flip();
            }
            else if (move < 0 && m_FacingRight)
            {
                Flip();
            }
        }
        if (m_Grounded && jump)
        {
            if (jumpTimer < jumpTimeThreshole)
            {
                return;
            }
            jumpTimer = 0;
            // Add a vertical force to the player.
            m_Grounded = false;
            m_Rigidbody2D.AddForce(new Vector2(0f, playerControlSetting.jumpHeight));
        }
    }

    private void Flip()
    {
        m_FacingRight = !m_FacingRight;

       // spriteRenderer.flipX = !m_FacingRight;
        Vector3 theScale = transform.localScale;
        theScale.x *= -1;
        transform.localScale = theScale;
    }

    private void DoAction()
    {

        if (currentPickingItem != null)
        {
            DoThrowItem();
            return;
        }

        var item = ItemManager.Instance.GetHightLightItem(this);
        if (item != null)
        {
            DoPickItem(item);
            return;
        }
    }

    private void DoThrowItem()
    {
        animator.SetTrigger(ANIMATOR_THROW);
        animator.SetBool(ANIMATOR_HAS_ITEM, false);
        currentPickingItem.OnRelese(m_FacingRight ? playerControlSetting.throwStrength : -playerControlSetting.throwStrength);
        currentPickingItem = null;
    }

    private void DoPickItem(ItemBase item)
    {
        animator.SetBool(ANIMATOR_HAS_ITEM, true);
        item.OnPickUp();
        item.transform.parent = pickItemTransform;
        item.transform.localPosition = Vector3.zero;
        currentPickingItem = item;
    }
}
