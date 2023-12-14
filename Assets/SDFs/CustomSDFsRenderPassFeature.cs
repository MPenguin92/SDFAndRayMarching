using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

[DisallowMultipleRendererFeature("Custom/SDFs")]
public partial class CustomSDFsRenderPassFeature : ScriptableRendererFeature
{
    private CustomSDFsRenderPass m_ScriptablePass;
    private SDFsVolume m_Volume;
    public Material material;
    public RenderPassEvent renderPassEvent;
    
    /// <inheritdoc/>
    public override void Create()
    {
        m_ScriptablePass = new CustomSDFsRenderPass(m_Volume,material,renderPassEvent);

        // Configures where the render pass should be injected.
        m_ScriptablePass.renderPassEvent = RenderPassEvent.AfterRenderingOpaques;
    }

    // Here you can inject one or multiple render passes in the renderer.
    // This method is called when setting up the renderer once per-camera.
    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        renderer.EnqueuePass(m_ScriptablePass);
    }
}


