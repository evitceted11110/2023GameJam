using System;
using System.Collections;
using System.Collections.Generic;
using Unity.Collections;
using UnityEngine;

[RequireComponent(typeof(Animator))]
public class AnimatorView : MonoBehaviour
{
    [SerializeField, ReadOnly]
    private int _id;
    public int id
    {
        protected set
        {
            _id = value;
        }
        get
        {
            return _id;
        }
    }
    public SpriteRenderer foreground;
    private Animator _animator;
    public Animator animator
    {
        get
        {
            if (_animator == null)
            {
                _animator = GetComponent<Animator>();
            }
            return _animator;
        }
    }
    protected RuntimeAnimatorController animatorController;
    private Action<AnimatorView> callBack;
    private Coroutine callBackCoroutine;
    public bool isPlaying { private set; get; }
    protected virtual void Awake()
    {
        if (animator.runtimeAnimatorController != null)
            animatorController = animator.runtimeAnimatorController;
        animator.runtimeAnimatorController = null;
    }

    /// <summary>
    /// 設定SymbolID (設定後會將 Animator關閉)
    /// </summary>
    /// <param name="id"></param>
    public virtual void SetSymbolID(int id)
    {
        this.id = id;
        StopAnimation();
    }
    /// <summary>
    /// 設定前景Sprite
    /// </summary>
    /// <param name="sprite"></param>
    /// 
    public void SetForeground(Sprite sprite)
    {
        if (foreground == null) return;
        foreground.sprite = sprite;
    }

    public virtual void SetForegroundSpriteActive(bool active)
    {
        if (foreground == null) return;
        foreground.enabled = active;
    }

    /// <summary>
    /// 播放Animation (回傳 : SymbolID . SymbolView)
    /// </summary>
    /// <param name="playID"></param>
    /// <param name="frame"></param>
    /// <param name="_callBack"></param>
    public void PlayAnimation(string playID, float frame = 0, Action<AnimatorView> _callBack = null)
    {

        if (animator.runtimeAnimatorController == null)
        {
            if (animatorController == null) return;
            animator.runtimeAnimatorController = animatorController;
        }

        AnimatorStateInfo stateInfo = animator.GetCurrentAnimatorStateInfo(0);

        if (!stateInfo.IsName(playID) || frame != 0 || !isPlaying)
        {
            animator.Play(playID, 0, frame);
            animator.Update(0);
            isPlaying = true;
        }
        callBack = _callBack;
        if (callBackCoroutine != null)
        {
            StopCoroutine(callBackCoroutine);
        }
        if (isActiveAndEnabled)
            callBackCoroutine = StartCoroutine(CallBackIEnumerator());
    }

    public void PlayAnimationByLayer(string playID, int layer)
    {
        if (animator.runtimeAnimatorController == null)
        {
            if (animatorController == null) return;
            animator.runtimeAnimatorController = animatorController;
        }

        animator.Play(playID, layer);
    }

    public void PlayAnimation(int playID, float frame = 0, Action<AnimatorView> _callBack = null)
    {
        PlayAnimation(playID.ToString(), frame, _callBack);
    }
    /// <summary>
    /// 取得當前撥放的百分比(0~1)
    /// </summary>
    /// <returns></returns>
    public float GetCurrentPlayFrame()
    {
        return animator.GetCurrentAnimatorStateInfo(0).normalizedTime;
    }
    /// <summary>
    /// 設定AnimatorController
    /// </summary>
    /// <param name="controller"></param>
    public void SetRuntimeAnimatorController(RuntimeAnimatorController controller)
    {
        animatorController = controller;
    }

    /// <summary>
    /// 停止動畫
    /// </summary>
    public void StopAnimation()
    {
        isPlaying = false;
        //新版Animator 在拔除 Controller的時候 會將控制過的物件Reset成原始畫面
        Sprite sp = null;
        if (foreground != null) sp = foreground.sprite;
        if (animator.runtimeAnimatorController != null)
            animatorController = animator.runtimeAnimatorController;
        animator.runtimeAnimatorController = null;
        SetForeground(sp);
    }

    public virtual void Show()
    {
        gameObject.SetActive(true);
    }

    public virtual void Hide()
    {
        StopAnimation();
        gameObject.SetActive(false);
    }

    /// <summary>
    /// 設定Layer
    /// </summary>
    /// <param name="layerName"></param>
    public virtual void SetLayer(string layerName)
    {
        foreground.sortingLayerName = layerName;
    }

    public virtual void SetSortingOrder(int sortingOrder)
    {
        foreground.sortingOrder = sortingOrder;
    }

    /// <summary>
    /// 取得動畫長度(秒)
    /// </summary>
    /// <returns></returns>
    public float GetAnimationDuration()
    {
        return animator.GetCurrentAnimatorStateInfo(0).length;
    }

    IEnumerator CallBackIEnumerator()
    {
        var duration = GetAnimationDuration();
        var normalTime = GetCurrentPlayFrame();
        yield return new WaitForSeconds(duration * (1 - normalTime));
        if (callBack != null)
        {
            isPlaying = false;
            callBack(this);
        }
    }

    private void OnDisable()
    {
        if (callBackCoroutine != null)
        {
            StopCoroutine(callBackCoroutine);
        }
    }

    public bool IsPlayClipName(string clipName)
    {
        AnimatorStateInfo stateInfo = animator.GetCurrentAnimatorStateInfo(0);
        return stateInfo.IsName(clipName);
    }

}
