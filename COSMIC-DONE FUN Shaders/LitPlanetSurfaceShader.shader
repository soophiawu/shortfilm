Shader "Custom/LitPlanetSurfaceShader"
{
    Properties
    {
        _MainTex ("Base Texture", 2D) = "white" {}
        _DetailTex ("Detail Texture", 2D) = "white" {}
        _SurfaceScale ("Surface Scale", Range(0.1, 10)) = 1.0
        _NoiseScale ("Noise Scale", Range(0.1, 10)) = 1.0
        _TimeSpeed ("Time Speed", Range(0.1, 5)) = 1.0
        _DetailStrength ("Detail Strength", Range(0, 1)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 200

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata_t
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            sampler2D _MainTex;
            sampler2D _DetailTex;
            float _SurfaceScale;
            float _NoiseScale;
            float _TimeSpeed;
            float _DetailStrength;

            // Function to generate surface offset based on UV and time
            float3 GenerateSurfaceOffset(float2 uv, float time)
            {
                float noise = sin(uv.x * _NoiseScale + time) * sin(uv.y * _NoiseScale + time) * 0.5 + 0.5;
                return float3(0, noise * _SurfaceScale, 0);
            }

            v2f vert (appdata_t v)
            {
                v2f o;
                float time = _Time.y * _TimeSpeed;
                float3 offset = GenerateSurfaceOffset(v.uv, time);

                // Convert float3 offset to float4
                float4 offset4 = float4(offset, 0.0f); // Create float4 from float3 by setting w to 0
                float4 expandedVertex = v.vertex + offset4;
                o.pos = UnityObjectToClipPos(expandedVertex);
                o.uv = v.uv;

                // Transform normal to world space
                o.normal = mul((float4)v.normal, unity_WorldToObject).xyz;
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                float detail = tex2D(_DetailTex, i.uv).r * _DetailStrength;
                half4 baseColor = tex2D(_MainTex, i.uv + detail * 0.05);
                half4 finalColor = baseColor * (1.0 + detail); // Enhance color with detail
                return finalColor;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
