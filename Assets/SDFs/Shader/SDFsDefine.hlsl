#ifndef SDFsDefine
#define SDFsDefine
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

float sdfSphere(float3 samplePos, float radius)
{
    return length(samplePos) - radius;
}

float sdfPlane(float3 samplePos, float height)
{
    return samplePos.y - height;
}

float sdfBox(float3 p, float3 b)
{
    float3 q = abs(p) - b;
    return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0);
}

#endif