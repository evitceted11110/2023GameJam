using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ItemBox : MonoBehaviour
{
    public int itemID;
    [SerializeField]
    private float popForce;
    [SerializeField]
    private float horizontalForce;
    public void GenItem()
    {
        var item = ItemManager.Instance.GetItem(itemID);
        item.transform.position = this.transform.position + (Vector3.up * 0.1f);
        item.rigid2D.AddForce(new Vector2(Random.Range(-horizontalForce, horizontalForce), popForce));
    }

    private void Update()
    {
        if (Input.GetKeyUp(KeyCode.G))
        {
            GenItem();
        }
    }
}
