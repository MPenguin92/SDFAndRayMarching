using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

[DisallowMultipleRendererFeature("Custom/SDFs")]
public partial class CustomSDFsRenderPassFeature : ScriptableRendererFeature
{
    private CustomSDFsRenderPass mScriptablePass;
    private SDFsVolume mVolume;
    public Material material;
    public RenderPassEvent renderPassEvent;
    
    /// <inheritdoc/>
    public override void Create()
    {
        var stack = VolumeManager.instance.stack;
        mVolume = stack.GetComponent<SDFsVolume>();

        mScriptablePass = new CustomSDFsRenderPass(mVolume,material,renderPassEvent);

        // Configures where the render pass should be injected.
        mScriptablePass.renderPassEvent = RenderPassEvent.AfterRenderingOpaques;
    }

    // Here you can inject one or multiple render passes in the renderer.
    // This method is called when setting up the renderer once per-camera.
    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        renderer.EnqueuePass(mScriptablePass);
    }
}


