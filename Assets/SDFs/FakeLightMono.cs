using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

[ExecuteInEditMode]
public class FakeLightMono : MonoBehaviour
{
    private SDFsVolume mVolume;
    // Start is called before the first frame update
    void OnEnable()
    {
        var stack = VolumeManager.instance.stack;
        mVolume = stack.GetComponent<SDFsVolume>();
    }

    // Update is called once per frame
    void Update()
    {
        if (mVolume)
        {
            mVolume.SetFakeLightDir(transform.forward);
        }
    }
}
