Shader "Custom/SDFs"
{
    Properties
    {
        _Step ("Step", float) = 512
        _DirectionalLightDir("Directional Light Dir",vector) = (0,1,0)
         _SoftShadow ("SoftShadow", float) = 8
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline" = "UniversalPipeline"
        }

        Pass
        {
            HLSLPROGRAM
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Assets/SDFs/Shader/SDFsDefine.hlsl"

            #pragma vertex vert
            #pragma fragment frag

            CBUFFER_START(UnityPerMaterial)
            float _Step;
            float3 _DirectionalLightDir;
            float _SoftShadow;
            CBUFFER_END


            struct Attributes
            {
                float3 positionOS : POSITION;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 positionWS : TEXCOORD0;
            };


            float sdfScene(float3 samplePos)
            {
                float result = 0;

                result = sdfSphere(samplePos + float3(0, 0, -25), 5);
                result = min(result, sdBox(samplePos + float3(-9, 0, -25), 2));
                result = min(result, sdfPlane(samplePos, -5));

                return result;
            }

            float3 calcNormal(float3 surfacePos)
            {
                float df = sdfScene(surfacePos);
                float2 dt = float2(0.001f, 0.0f);
                return normalize(float3(
                    sdfScene(surfacePos + dt.xyy) - df,
                    sdfScene(surfacePos + dt.yxy) - df,
                    sdfScene(surfacePos + dt.yyx) - df
                ));
            }

            //从着色点向光源方向步进,如果进入到其它图形中,认为有遮挡,在遮挡处着色
            //@最大步数 512
            //@阴影颜色系数 0.2
            float calHardShadow(float3 surfacePos)
            {
                float t = 0.5f;
                for (int i = 0; i < 512; i++)
                {
                    float h = sdfScene(surfacePos + _DirectionalLightDir * t);
                    if (h < 0.001f)
                    {
                        return 0.2f;
                    }
                    t += h;
                }
                return 1.0f;
            }

            float calSoftShadow(float3 surfacePos, float k)
            {
                float res = 1.0f;
                float t = 0.5f;
                for (int i = 0; i < 512; i++)
                {
                    float h = sdfScene(surfacePos + _DirectionalLightDir * t);
                    if (h < 0.001f)
                    {
                        return 0.02f;
                    }
                    res = min(res, k * h / t);
                    t += h;
                }
                return res;
            }

            float getLight(float3 surfacePos)
            {
                float3 normal = calcNormal(surfacePos);
                //漫反射光照
                return max(0.0f, dot(normal, _DirectionalLightDir));
            }

            float4 rayMarching(float3 pos, float3 dir)
            {
                float3 baseColor = float3(1.0f, 1.0f, 1.0f);
                float3 ambient = float3(0.05f, 0.05f, 0.05f);
                for (int step = 0; step < _Step; step++)
                {
                    float d = sdfScene(pos);
                    if (d < 0.001f)
                    {
                        //return float4(baseColor * getLight(pos) * calHardShadow(pos) + ambient, 1.0f);
                        return float4(baseColor * getLight(pos) * calSoftShadow(pos,_SoftShadow) + ambient, 1.0f);
                    }
                    pos += dir * d;
                }
                return float4(0.0f, 0.0f, 0.0f, 1.0f);
            }

            Varyings vert(Attributes input)
            {
                Varyings output;
                output.positionHCS = float4(input.positionOS.xy, 1.0f, 1.0f);
                float4 worldPos = mul(unity_MatrixInvVP, output.positionHCS);
                output.positionWS = worldPos.xyz / worldPos.w;
                return output;
            }

            half4 frag(Varyings input) : SV_Target
            {
                float3 start = GetCameraPositionWS();
                float3 target = input.positionWS;
                float3 dir = normalize(target - start);
                //根据相机的位置和方向，开始光线步进
                return rayMarching(start, dir);
            }
            ENDHLSL
        }
    }
    FallBack "Packages/com.unity.render-pipelines.universal/FallbackError"
}