Shader "Custom/SimplifiedHolographicShader"
{
    Properties
    {
        _MainColor ("Main Color", Color) = (1,1,1,1)
        _Glossiness ("Glossiness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.5
        _DetailMap ("Detail Map", 2D) = "white" {}
        _ReflectionTex ("Reflection Texture", 2D) = "black" {}
        _RefractionTex ("Refraction Texture", 2D) = "black" {}
        _NoiseTex ("Noise Texture", 2D) = "black" {}
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
            #pragma target 2.0 // Use Shader Model 2.0 for better compatibility

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
                float3 worldPos : TEXCOORD1;
                float3 normal : TEXCOORD2;
            };

            half4 _MainColor;
            float _Glossiness;
            float _Metallic;
            sampler2D _DetailMap;
            sampler2D _ReflectionTex;
            sampler2D _RefractionTex;
            sampler2D _NoiseTex;

            v2f vert(appdata_t v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.normal = mul((float3x3)unity_WorldToObject, v.normal);
                return o;
            }

            half4 frag(v2f i) : SV_Target
            {
                // Basic holographic effect
                half4 baseColor = tex2D(_DetailMap, i.uv) * _MainColor;

                // Reflection and refraction
                half3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);
                half3 reflectDir = reflect(-viewDir, i.normal);
                half4 reflectionColor = tex2D(_ReflectionTex, reflectDir.xy);
                half4 refractionColor = tex2D(_RefractionTex, i.uv);

                // Noise effect
                half noise = tex2D(_NoiseTex, i.uv * 5.0 + _Time.y * 0.1).r; // Use built-in _Time.y
                baseColor.rgb += noise * 0.2;

                // Combine colors
                half4 finalColor = baseColor;
                finalColor.rgb += reflectionColor.rgb * 0.2;
                finalColor.rgb += refractionColor.rgb * 0.3;

                // Adjust glossiness and metallic
                finalColor.rgb *= (1.0 - _Glossiness) * _Metallic;

                return finalColor;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
