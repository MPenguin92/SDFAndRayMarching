using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

[Serializable, VolumeComponentMenuForRenderPipeline("Custom/SDFs", typeof(UniversalRenderPipeline))]
public class SDFsVolume : VolumeComponent, IPostProcessComponent
{
    public BoolParameter isRender = new BoolParameter(false);
    //弄个空的gameObject,方便调节灯光方向
    private Vector3 mFakeLightDir;
    public void SetFakeLightDir(Vector3 v)
    {
        mFakeLightDir = v;
    }
    
    public Vector3 GetFakeLightDir()
    {
        return mFakeLightDir;
    }

    public bool IsActive() => isRender.value;
    public bool IsTileCompatible() => false;
}
