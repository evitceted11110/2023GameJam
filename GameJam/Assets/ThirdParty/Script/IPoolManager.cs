using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public abstract class IPoolManager : MonoBehaviour
{
    protected Queue<IPoolable> pool = new Queue<IPoolable>();
    [SerializeField]
    protected int defaultPoolSize = 20;
    [SerializeField]
    public IPoolable prefab;
    public int poolUsingCount
    {
        private set; get;
    }

    protected void Setup()
    {
        for (int i = 0; i < defaultPoolSize; i++)
        {
            IPoolable obj = New();
            obj.gameObject.SetActive(false);
            pool.Enqueue(obj);
        }
    }

    private IPoolable New()
    {
        var obj = Instantiate<IPoolable>(prefab, transform);
        obj.Setup(this);
        return obj;
    }

    public T Get<T>() where T : IPoolable
    {
        poolUsingCount++;
        if (pool.Count == 0)
            return (T)New();
        var obj = pool.Dequeue();
        obj.gameObject.SetActive(true);
        return (T)obj;
    }

    public void Recycle(IPoolable poolable)
    {
        poolUsingCount--;
        poolable.gameObject.SetActive(false);
        pool.Enqueue(poolable);
    }

    public void RecycleToRoot(IPoolable poolable)
    {
        if (pool.Contains(poolable))
        {
            Debug.LogWarning(string.Format("{0} 重複回收 {1}", gameObject.name, poolable.name));
            return;
        }

        poolUsingCount--;
        poolable.transform.SetParent(transform);
        poolable.gameObject.SetActive(false);

        pool.Enqueue(poolable);
    }

    public void RecycleAll()
    {
        var objs = GetComponentsInChildren<IPoolable>();
        for (int i = 0; i < objs.Length; i++)
        {
            objs[i].Dispose();
        }
    }

    public void RecycleAllToRoot()
    {
        var objs = GetComponentsInChildren<IPoolable>();
        for (int i = 0; i < objs.Length; i++)
        {
            objs[i].DisposeToRoot();
        }
    }
}
