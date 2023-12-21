#ifndef DrawSDFScene
#define DrawSDFScene
#include "Assets/SDFs/Shader/SDFsDefine.hlsl"
#include "Assets/SDFs/Shader/Operate.hlsl"
#include "Assets/SDFs/Shader/Transform.hlsl"

// https://iquilezles.org/articles/checkerfiltering
float checkersGradBox(float2 p, float dx, float dy)
{
    // filter kernel
    float2 w = abs(float2(dx,dx))+abs(float2(dy,dy)) + 0.001;
    // analytical integral (box filter)
    float2 i = 2.0*(abs(frac((p-0.5*w)*0.5)-0.5)-abs(frac((p+0.5*w)*0.5)-0.5))/w;
    // xor pattern
    return 0.5 - 0.5*i.x*i.y;
}

//拼场景
DrawSceneData drawSDFScene(float3 samplePos,float smooth,float dpx,float dpy)
{
    DrawSceneData result;
    float t = sin(_Time.y * 1.8);

    DrawSceneData sphere1;
    const float3 spherePoint = translate(samplePos, float3(0, 0, 25));
    sphere1.opResult = sdfSphere(spherePoint, 5);
    sphere1.opColor = float3(0.2, 0.2, 0.6);

    DrawSceneData box1;
    const float3 boxPoint = rotate(translate(samplePos, float3(t * 18, 0, 25)), float3(0, t * 360, 45));
    box1.opResult =lerp(sdfSphere(boxPoint,5),sdfBox(boxPoint, 2), abs(t)) ;
    box1.opColor = float3(0, 0.8, 0.8);
    result = opSmoothUnion(sphere1, box1, smooth);

    DrawSceneData sphere2;
    const float3 spherePoint2 = translate(samplePos, float3(0, abs(t) * 12, 25));
    sphere2.opResult = sdfSphere(spherePoint2, 2);
    sphere2.opColor = float3(1, 1, 0);
    result = opSmoothUnion(result, sphere2, smooth);


    DrawSceneData sdfBoxFrame1;
    const float3 boxFramePoint2 = translate(samplePos, float3(-18, 0, 25));
    sdfBoxFrame1.opResult = sdfBoxFrame(boxFramePoint2, 4,0.3);
    sdfBoxFrame1.opColor = float3(0.2, 1,0.6);
    result = opSmoothUnion(result, sdfBoxFrame1, smooth);
    
    DrawSceneData plane;
    plane.opResult = sdfPlane(samplePos, -5);
    plane.opColor = 0.15 * float3(1,1,1)  + checkersGradBox(0.2 * samplePos.xz,dpx,dpy) * 0.4 * float3(1,1,1);
    result = opUnion(result, plane);

    return result;
}

#endif
