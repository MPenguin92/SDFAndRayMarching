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

    public bool IsActive() => isRender.value;
    public bool IsTileCompatible() => false;
}
