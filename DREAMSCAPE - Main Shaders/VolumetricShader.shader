Shader "Custom/VolumetricClouds"
{
    Properties
    {
        _NoiseTexture ("Noise Texture", 3D) = "white" {} // 3D Texture
        _CustomTime ("Custom Time", Float) = 0.0
        _CameraPos ("Camera Position", Vector) = (0, 0, 0, 0)
    }
    SubShader
    {
        Tags {"RenderType" = "Opaque"}
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 4.0
            #include "UnityCG.cginc"

            struct appdata {
                float3 pos : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float3 fragPos : TEXCOORD0;
                float3 normal : TEXCOORD1;
                float2 uv : TEXCOORD2;
            };

            sampler3D _NoiseTexture; // 3D Texture
            float _CustomTime;
            float3 _CameraPos;

            float getDensity(float3 pos) {
                float3 samplePos = pos * 0.1 + float3(0.0, _CustomTime * 0.05, 0.0);
                float noise = tex3D(_NoiseTexture, samplePos).r;
                float heightFactor = 1.0 - saturate(abs(pos.y - 5.0) / 5.0);
                return noise * heightFactor * 0.5;
            }

            v2f vert(appdata v) {
                v2f o;
                float4 worldPos = mul(unity_ObjectToWorld, float4(v.pos, 1.0));
                o.pos = mul(UNITY_MATRIX_P, mul(UNITY_MATRIX_V, worldPos));
                o.fragPos = worldPos.xyz;
                o.normal = mul((float3x3)UNITY_MATRIX_IT_MV, v.normal);
                o.uv = v.uv;
                return o;
            }

            float4 frag(v2f i) : SV_Target {
                float3 rayOrigin = _CameraPos;
                float3 rayDir = normalize(i.fragPos - _CameraPos);

                float4 result = float4(0.0, 0.0, 0.0, 0.0);
                float t = 0.0;

                for (int step = 0; step < 100; step++) {
                    float3 pos = rayOrigin + rayDir * t;
                    float density = getDensity(pos);

                    if (density > 0.01) {
                        float3 lightDir = normalize(float3(1.0, 1.0, 0.0));
                        float lightDensity = getDensity(pos + lightDir * 0.5);
                        float shadow = exp(-lightDensity * 2.0);

                        float3 color = lerp(float3(0.6, 0.7, 0.9), float3(1.0, 1.0, 1.0), shadow);
                        float alpha = density * 0.1;

                        result.rgb += color * alpha * (1.0 - result.a);
                        result.a += alpha * (1.0 - result.a);

                        if (result.a >= 0.95) break;
                    }

                    t += 0.1;
                }

                return result;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
