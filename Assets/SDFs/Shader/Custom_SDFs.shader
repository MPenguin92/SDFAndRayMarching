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
        //环境光
        _AmbientColor("AmbientColor",Color) = (1,1,1,1)
        //并集平滑值
        _SmoothUnion("SmoothUnion",Range(0.0,1.0)) = 0.5
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline" = "UniversalPipeline"
        }
        Blend SrcAlpha OneMinusSrcAlpha
        Pass
        {
            HLSLPROGRAM
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Assets/SDFs/Shader/SDFsDefine.hlsl"
            #include "Assets/SDFs/Shader/Transform.hlsl"
            #include "Assets/SDFs/Shader/Operate.hlsl"

            #pragma vertex vert
            #pragma fragment frag

            CBUFFER_START(UnityPerMaterial)
            float _Step;
            float3 _DirectionalLightDir;
            float _SoftShadow;
            float _ShadowStep;
            float4 _AmbientColor;
            float4 _ShadowColor;
            float _SmoothUnion;
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
            DrawSceneData sdfScene(float3 samplePos)
            {
                DrawSceneData result;
                float t = sin(_Time.z);

                DrawSceneData sphere1;
                const float3 spherePoint = translate(samplePos, float3(0, 0, 25));
                sphere1.opResult = sdfSphere(spherePoint, 5);
                sphere1.opColor = float3(0.2, 0.2, 0.6);

                DrawSceneData box1;
                const float3 boxPoint = rotate(translate(samplePos, float3(t * 8, 0, 25)), float3(0, t * 360, 45));
                box1.opResult = sdfBox(boxPoint, 2);
                box1.opColor = float3(0, 0.8, 0.8);
                // result = opUnion(sphere1, box1);
                result = opSmoothUnion(sphere1, box1, _SmoothUnion);

                DrawSceneData sphere2;
                const float3 spherePoint2 = translate(samplePos, float3(0, abs(t) * 8, 25));
                sphere2.opResult = sdfSphere(spherePoint2, 2);
                sphere2.opColor = float3(1, 1, 0);
                //result = opUnion(result, sphere2);
                result = opSmoothUnion(result, sphere2, _SmoothUnion);

                DrawSceneData plane;
                plane.opResult = sdfPlane(samplePos, -5);
                plane.opColor = float3(1, 1, 1);
                result = opUnion(result, plane);

                return result;
            }

            //曲面求导的方式算出法线方向
            //https://iquilezles.org/articles/normalsSDF/
            float3 calcNormal(float3 surfacePos)
            {
                DrawSceneData df = sdfScene(surfacePos);
                float2 dt = float2(StepFloatPrecision, 0.0f);
                return normalize(float3(
                    sdfScene(surfacePos + dt.xyy).opResult - df.opResult,
                    sdfScene(surfacePos + dt.yxy).opResult - df.opResult,
                    sdfScene(surfacePos + dt.yyx).opResult - df.opResult
                ));
            }

            //从着色点向光源方向步进,如果进入到其它图形中,认为有遮挡,在遮挡处着色
            //@_ShadowStep 最大步数
            bool calHardShadow(float3 surfacePos)
            {
                float t = 0.5f;
                for (int i = 0; i < _ShadowStep; i++)
                {
                    float h = sdfScene(surfacePos + _DirectionalLightDir * t).opResult;
                    if (h < StepFloatPrecision)
                    {
                        return true;
                    }
                    t += h;
                }
                return false;
            }

            //软阴影简单来说就是除了被完全遮挡的部分无光,周围也有渐变衰减的阴影
            //https://iquilezles.org/articles/rmshadows/
            float calSoftShadow(float3 surfacePos, float k)
            {
                float res = 1.0f;
                float t = 0.5f;
                for (int i = 0; i < _ShadowStep; i++)
                {
                    float h = sdfScene(surfacePos + _DirectionalLightDir * t).opResult;
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
                float4 col = float4(0.0f, 0.0f, 0.0f, 0.0f);
                for (int step = 0; step < _Step; step++)
                {
                    DrawSceneData data = sdfScene(pos);
                    float d = data.opResult;
                    float4 baseC = float4(data.opColor, 1);
                    //d==0话代表在表面 <0则是在内部
                    if (d < StepFloatPrecision)
                    {
                        //bool isShadow = calHardShadow(pos);
                        float4 diffuse = baseC * getLight(pos) + _AmbientColor;
                        //渲染阴影~阴影颜色的插值
                        col = lerp(_ShadowColor, diffuse, calSoftShadow(pos, _SoftShadow));
                        break;
                    }
                    pos += dir * d;
                }
                return col;
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