using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public abstract class IPoolable : MonoBehaviour
{
    private IPoolManager manager;

    public virtual void Setup(IPoolManager manager)
    {
        this.manager = manager;
    }

    public virtual void Dispose()
    {
        manager.Recycle(this);
    }

    public virtual void DisposeToRoot()
    {
        manager.RecycleToRoot(this);
    }
}

