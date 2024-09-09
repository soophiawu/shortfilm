Shader "Custom/VertexGlowShader"
{
    Properties
    {
        _MainColor ("Main Color", Color) = (1,1,1,1)
        _GlowColor ("Glow Color", Color) = (1,1,1,1)
        _GlowIntensity ("Glow Intensity", Range(0,10)) = 1
        _GlowSize ("Glow Size", Range(0,10)) = 1
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 200

        // Base Pass
        Pass
        {
            Name "BASE"
            ZWrite On
            ZTest LEqual
            Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata_t
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : POSITION;
                float4 color : COLOR;
            };

            float4 _MainColor;
            float4 _GlowColor;
            float _GlowIntensity;
            float _GlowSize;

            v2f vert (appdata_t v)
            {
                v2f o;
                // Expand vertices for glow effect
                float3 expandedVertex = v.vertex.xyz + (v.normal * _GlowSize);
                o.pos = UnityObjectToClipPos(float4(expandedVertex, 1.0));
                o.color = _MainColor;
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                // Combine main color with glow effect
                half4 col = i.color;
                half4 glow = _GlowColor * _GlowIntensity;
                col.rgb += glow.rgb;
                return col;
            }
            ENDCG
        }

        // Glow Pass
        Pass
        {
            Name "GLOW"
            ZWrite Off
            ZTest Always
            Blend SrcAlpha OnePlusSrcAlpha
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata_t
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : POSITION;
            };

            float4 _GlowColor;
            float _GlowSize;

            v2f vert (appdata_t v)
            {
                v2f o;
                // Expand vertices for glow effect
                float3 expandedVertex = v.vertex.xyz + (v.normal * _GlowSize);
                o.pos = UnityObjectToClipPos(float4(expandedVertex, 1.0));
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                // Apply glow color and intensity
                half4 col = _GlowColor;
                col.a *= _GlowSize; // Adjust alpha for better glow spread
                return col;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
