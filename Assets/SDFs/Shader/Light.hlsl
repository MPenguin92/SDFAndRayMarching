#ifndef Light
#define Light

float4 GetLight(float4 baseColor,float3 normal,float3 lightDir,float3 viewDir,float intensity,float specular,float4 ambientColor)
{
    //漫反射
    float4 diffuse = baseColor * max(0.0f, dot(normal, lightDir)) * intensity;
    //半程向量,光照方向和视角向量的和
    float3 halfDir = normalize(lightDir + viewDir);
    float4 spec = specular * intensity * pow(saturate(dot(halfDir,normal)),200);
    
    return diffuse + spec + ambientColor; 
}

#endif
