Shader "Custom/SDFs"
{
    Properties
    {
        _Step ("Step", float) = 512
        _ShadowStep ("ShadowStep", float) = 512
        //平行光方向
        _DirectionalLightDir("Directional Light Dir",vector) = (0,1,0)
        //软阴影范围
        _SoftShadow ("SoftShadow", float) = 8
        //阴影颜色
        _ShadowColor("ShadowColor",Color) = (0.1,0.1,0.1,1)
        //物体底色
        _BaseColor("BaseColor",Color) = (1,1,1,1)
        //环境光
        _AmbientColor("_AmbientColor",Color) = (1,1,1,1)
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
            float _ShadowStep;
            float4 _BaseColor;
            float4 _AmbientColor;
            float4 _ShadowColor;
            CBUFFER_END

            #define StepFloatPrecision 0.0001

            struct Attributes
            {
                float3 positionOS : POSITION;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 positionWS : TEXCOORD0;
            };

            //拼场景
            float sdfScene(float3 samplePos)
            {
                float result = 0;

                result = sdfSphere(samplePos + float3(0, 0, -25), 5);
                result = min(result, sdBox(samplePos + float3(-9, 0, -25), 2));
                result = min(result, sdfPlane(samplePos, -5));

                return result;
            }

            //曲面求导的方式算出法线方向
            //https://iquilezles.org/articles/normalsSDF/
            float3 calcNormal(float3 surfacePos)
            {
                float df = sdfScene(surfacePos);
                float2 dt = float2(StepFloatPrecision, 0.0f);
                return normalize(float3(
                    sdfScene(surfacePos + dt.xyy) - df,
                    sdfScene(surfacePos + dt.yxy) - df,
                    sdfScene(surfacePos + dt.yyx) - df
                ));
            }

            //从着色点向光源方向步进,如果进入到其它图形中,认为有遮挡,在遮挡处着色
            //@_ShadowStep 最大步数
            bool calHardShadow(float3 surfacePos)
            {
                float t = 0.5f;
                for (int i = 0; i < _ShadowStep; i++)
                {
                    float h = sdfScene(surfacePos + _DirectionalLightDir * t);
                    if (h < StepFloatPrecision)
                    {
                        return true;
                    }
                    t += h;
                }
                return false;
            }

            //软阴影就是除了被完全遮挡的部分无光,周围也有渐变衰减的阴影
            float calSoftShadow(float3 surfacePos, float k)
            {
                float res = 1.0f;
                float t = 0.5f;
                for (int i = 0; i < _ShadowStep; i++)
                {
                    float h = sdfScene(surfacePos + _DirectionalLightDir * t);
                    if (h < StepFloatPrecision)
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
                for (int step = 0; step < _Step; step++)
                {
                    float d = sdfScene(pos);
                    //d==0话代表在表面 <0则是在内部
                    if (d < StepFloatPrecision)
                    {
                        //bool isShadow = calHardShadow(pos);
                        float4 diffuse = _BaseColor * getLight(pos) + _AmbientColor;
                        //渲染阴影~反射颜色的插值
                        return lerp(_ShadowColor, diffuse, calSoftShadow(pos, _SoftShadow));
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
                //相机视椎体剪裁面的世界坐标
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