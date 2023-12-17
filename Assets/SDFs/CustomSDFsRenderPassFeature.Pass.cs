// CustomSDFsRenderPassFeature.Pass.cs
// Created by Cui Lingzhi
// on 2023 - 12 - 12

using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public partial class CustomSDFsRenderPassFeature
{
    private static readonly int DirectionalLightDir = Shader.PropertyToID("_DirectionalLightDir");

    private class CustomSDFsRenderPass : ScriptableRenderPass
    {
        private SDFsVolume mVolume;
        private readonly Material mMaterial;

        // This method is called before executing the render pass.
        // It can be used to configure render targets and their clear state. Also to create temporary render target textures.
        // When empty this render pass will render to the active camera render target.
        // You should never call CommandBuffer.SetRenderTarget. Instead call <c>ConfigureTarget</c> and <c>ConfigureClear</c>.
        // The render pipeline will ensure target setup and clearing happens in a performant manner.
        public CustomSDFsRenderPass(SDFsVolume volume, Material material, RenderPassEvent renderPassEvent)
        {
            mVolume = volume;
            mMaterial = material;

            this.renderPassEvent = renderPassEvent;
        }

        public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
        {
        }

        // Here you can implement the rendering logic.
        // Use <c>ScriptableRenderContext</c> to issue drawing commands or execute command buffers
        // https://docs.unity3d.com/ScriptReference/Rendering.ScriptableRenderContext.html
        // You don't have to call ScriptableRenderContext.submit, the render pipeline will call it at specific points in the pipeline.
        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            var cmd = CommandBufferPool.Get("CustomSDFsRenderPass");
            try
            {
                cmd.Clear();
                cmd.DrawMesh(MiscUtil.FullScreenTriangleMesh, Matrix4x4.identity, mMaterial);
                if (mVolume != null)
                {
                    mMaterial.SetVector(DirectionalLightDir, -mVolume.GetFakeLightDir());
                }

                context.ExecuteCommandBuffer(cmd);
            }
            finally
            {
                cmd.Release();
            }
        }

        // Cleanup any allocated resources that were created during the execution of this render pass.
        public override void OnCameraCleanup(CommandBuffer cmd)
        {
        }
    }
}