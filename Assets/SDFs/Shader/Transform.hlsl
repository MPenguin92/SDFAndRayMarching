#ifndef Transform
#define Transform
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

float3 translate(float3 oriPos, float3 offset)
{
    return oriPos + (-offset);
}

float3 rotate(float3 oriPos, float3 angle)
{
    //0.01745 -> π/180
    float radianX = angle.x * 0.01745f;
    float radianY = angle.y * 0.01745f;
    float radianZ = angle.z * 0.01745f;
    float3x3 mX = {
        1, 0.0f, 0,
        0.0f, cos(radianX), -sin(radianX),
        0, sin(radianX), cos(radianX),
    };
    float3x3 mY = {
        cos(radianY), 0.0f, sin(radianY),
        0.0f, 1, 0.0f,
        -sin(radianY), 0, cos(radianY),
    };
    float3x3 mZ = {
        cos(radianZ), -sin(radianZ), 0,
        sin(radianZ),cos(radianZ), 0.0f,
        0, 0, 1,
    };

    const float3x3 compose = mul(mul(mX,mY),mZ);
    return mul(transpose(compose), float3(oriPos));
}

#endif
