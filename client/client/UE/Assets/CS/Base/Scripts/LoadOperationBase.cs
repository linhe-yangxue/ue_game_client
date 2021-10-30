using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public abstract class LoadOperationBase : IEnumerator {
    public object Current {
        get {
            return null;
        }
    }
    public bool MoveNext() {
        return !IsDone();
    }
    public void Reset() {
    }
    public virtual bool allowSceneActivation {
        get { return false; }
        set {}
    }
    public abstract bool IsDone ();
    public virtual bool isDone { get { return IsDone(); } }
    public abstract float progress { get; }
    public abstract Object asset { get; }
}
