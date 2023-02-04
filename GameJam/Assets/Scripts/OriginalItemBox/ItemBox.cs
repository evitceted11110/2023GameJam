using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ItemBox : MonoBehaviour, IHighLightable
{
    public int itemID;
    [SerializeField]
    private float popForce;
    [SerializeField]
    private float horizontalForce;
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

    private void Awake()
    {
        spriteRenderer.sharedMaterial = Material.Instantiate(spriteRenderer.sharedMaterial);
    }
    public void GenItem()
    {
        var item = ItemManager.Instance.GetItem(itemID);
        item.transform.position = this.transform.position + (Vector3.up * 0.1f);
        item.rigid2D.AddForce(new Vector2(Random.Range(-horizontalForce, horizontalForce), popForce));
    }

    public void SetHighLight(bool isHighLight)
    {
        rendererMaterial.SetFloat("_Brightness", isHighLight ? 2 : 0);
    }

    private void Update()
    {
        if (Input.GetKeyUp(KeyCode.G))
        {
            GenItem();
        }
    }
}
