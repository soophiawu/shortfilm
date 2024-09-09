Shader "Custom/LitBioluminescenceShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _GlowColor ("Glow Color", Color) = (0.0, 1.0, 0.8, 1)
        _GlowIntensity ("Glow Intensity", Range(0, 5)) = 2.0
        _Glossiness ("Glossiness", Range(0, 1)) = 0.5
        _Metallic ("Metallic", Range(0, 1)) = 0.0
        _TimeScale ("Time Scale", Range(0.1, 10)) = 1.0
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 200

        Pass
        {
            Name "FORWARD"
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct appdata_t
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float3 normal : NORMAL;
            };

            sampler2D _MainTex;
            float4 _GlowColor;
            float _GlowIntensity;
            float _Glossiness;
            float _Metallic;
            float _TimeScale;

            v2f vert (appdata_t v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.normal = mul((float3x3)unity_ObjectToWorld, v.vertex.xyz);
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                // Sample the main texture
                half4 baseColor = tex2D(_MainTex, i.uv);
                
                // Lighting calculation
                half3 normal = normalize(i.normal);
                half3 lightDir = normalize(UnityWorldSpaceLightDir(normal));  // Direction of light
                half diff = max(dot(normal, lightDir), 0.0);
                half4 lighting = diff * _LightColor0;
                
                // Bioluminescent glow effect
                float time = _Time.y * _TimeScale;
                half glow = sin(time * 5.0) * _GlowIntensity;
                half4 glowColor = _GlowColor * glow;

                // Combine base color with lighting and glow
                half4 col = baseColor * lighting + glowColor;
                return col;
            }
            ENDCG
        }
    }
    FallBack "Standard"
}
