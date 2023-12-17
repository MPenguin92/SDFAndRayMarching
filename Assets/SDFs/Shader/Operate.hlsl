#ifndef Operate
#define Operate
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

//min(a,b) ->a∪b
float opUnion(float d1, float d2)
{
    return min(d1, d2);
}

//max(-a,b) ->补
float opSubtraction(float d1, float d2)
{
    return max(-d1, d2);
}

//max(a,b) ->a∩b
float opIntersection(float d1, float d2)
{
    return max(d1, d2);
}

//平滑并 ∪
//https://iquilezles.org/articles/smin/
//https://www.shadertoy.com/view/lt3BW2
float opSmoothUnion(float d1, float d2, float k)
{
    float h = clamp(0.5 + 0.5 * (d2 - d1) / k, 0.0, 1.0);
    return lerp(d2, d1, h) - k * h * (1.0 - h);
}

//平滑补 
float opSmoothSubtraction(float d1, float d2, float k)
{
    float h = clamp(0.5 - 0.5 * (d2 + d1) / k, 0.0, 1.0);
    return lerp(d2, -d1, h) + k * h * (1.0 - h);
}

//平滑交 ∩
float opSmoothIntersection(float d1, float d2, float k)
{
    float h = clamp(0.5 - 0.5 * (d2 - d1) / k, 0.0, 1.0);
    return lerp(d2, d1, h) + k * h * (1.0 - h);
}

#endif
