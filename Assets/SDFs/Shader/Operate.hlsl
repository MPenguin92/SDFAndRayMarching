#ifndef Operate
#define Operate

struct DrawSceneData
{
    float opResult;
    float3 opColor;
};

//min(a,b) ->a∪b
float opUnion(float d1, float d2)
{
    return min(d1, d2);
}

DrawSceneData opUnion(DrawSceneData d1, DrawSceneData d2)
{
    DrawSceneData result;
    if(d1.opResult<d2.opResult)
    {
        result.opResult = d1.opResult;
        result.opColor = d1.opColor;
    }
    else
    {
        result.opResult = d2.opResult;
        result.opColor = d2.opColor;
    }
    return result;
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

DrawSceneData opSmoothUnion(DrawSceneData d1, DrawSceneData d2, float k)
{
    DrawSceneData result;
    float h = clamp(0.5 + 0.5 * (d2.opResult - d1.opResult) / k, 0.0, 1.0);
    k = k * h * (1.0 - h);
    result.opResult = lerp(d2.opResult, d1.opResult, h) - k;
    result.opColor = lerp(d2.opColor, d1.opColor, h) - k;

    return result;
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
