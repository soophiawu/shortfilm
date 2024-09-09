Shader "Custom/PlanetShader"
{
    Properties
    {
        _CameraPos ("Camera Position", Vector) = (0, 0, 0, 0)
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            #include "UnityCG.cginc"

            // Vertex Shader
            struct appdata_t
            {
                float3 position : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 fragPos : TEXCOORD0;
                float3 normal : TEXCOORD1;
                float2 uv : TEXCOORD2;
            };

            uniform float4 _CameraPos;

            v2f vert(appdata_t v)
            {
                v2f o;
                o.fregPos = mul(unity_ObjectToWorld, float4(v.position, 1.0)).xyz;
                o.normal = mul((float3x3)unity_ObjectToWorld, v.normal);
                o.uv = v.uv;
                o.pos = UnityObjectToClipPos(o.fregPos);
                return o;
            }

            // Noise Function
            float3 hash33(float3 p3)
            {
                p3 = frac(p3 * float3(0.1031, 0.1030, 0.0973));
                p3 += dot(p3, p3.yxz + 33.33);
                return frac((p3.xxy + p3.yxx) * p3.zyx);
            }

            float snoise(float3 v)
            {
                // Your noise function implementation here
                // Ensure it is translated from GLSL to HLSL/CG
                return 0.0; // Placeholder
            }

            // Fragment Shader
            float4 frag(v2f i) : SV_Target
            {
                float3 viewDir = normalize(_CameraPos.xyz - i.fregPos);
                float3 normal = normalize(i.normal);

                // Base planet color
                float3 baseColor = float3(0.2, 0.4, 0.8);

                // Surface features
                float surfaceNoise = snoise(float3(i.uv * 10.0, _Time.y * 0.05)) * 0.5 + 0.5;
                float3 surfaceColor = lerp(baseColor, float3(0.8, 0.7, 0.5), surfaceNoise);

                // Atmosphere
                float atmosphereThickness = 0.1;
                float atmosphereFalloff = 3.0;
                float NdotV = dot(normal, viewDir);
                float atmosphereStrength = pow(1.0 - NdotV, atmosphereFalloff) * atmosphereThickness;
                float3 atmosphereColor = float3(0.6, 0.8, 1.0);

                // Cloud layer
                float cloudNoise = snoise(float3(i.uv * 5.0 + _Time.y * 0.02, _Time.y * 0.01)) * 0.5 + 0.5;
                float cloudCoverage = 0.4;
                float clouds = smoothstep(cloudCoverage, cloudCoverage + 0.1, cloudNoise);

                // Combine layers
                float3 finalColor = lerp(surfaceColor, float3(1.0), clouds * 0.7);
                finalColor = lerp(finalColor, atmosphereColor, atmosphereStrength);

                // Fresnel effect
                float fresnelStrength = pow(1.0 - NdotV, 5.0) * 0.5;
                finalColor = lerp(finalColor, atmosphereColor, fresnelStrength);

                // Specular highlight
                float3 sunDir = normalize(float3(1.0, 0.5, -1.0));
                float3 reflectDir = reflect(-sunDir, normal);
                float spec = pow(max(dot(viewDir, reflectDir), 0.0), 32.0);
                float3 specular = float3(1.0, 0.98, 0.9) * spec * 0.5;
                finalColor += specular;

                return float4(finalColor, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
