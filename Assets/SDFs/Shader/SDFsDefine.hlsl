#ifndef SDFsDefine
#define SDFsDefine
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

//min(a,b) ->a∪b
//max(a,b) ->a∩b
//max(-a,b) ->补
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


//平滑并 ∪
//https://iquilezles.org/articles/smin/
//https://www.shadertoy.com/view/lt3BW2
float opSmoothUnion( float d1, float d2, float k )
{
    float h = clamp( 0.5 + 0.5*(d2-d1)/k, 0.0, 1.0 );
    return lerp( d2, d1, h ) - k*h*(1.0-h);
}

//平滑补 
float opSmoothSubtraction( float d1, float d2, float k )
{
    float h = clamp( 0.5 - 0.5*(d2+d1)/k, 0.0, 1.0 );
    return lerp( d2, -d1, h ) + k*h*(1.0-h);
}

//平滑交 ∩
float opSmoothIntersection( float d1, float d2, float k )
{
    float h = clamp( 0.5 - 0.5*(d2-d1)/k, 0.0, 1.0 );
    return lerp( d2, d1, h ) + k*h*(1.0-h);
}
#endif