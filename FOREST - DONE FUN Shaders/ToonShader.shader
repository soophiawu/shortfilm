Shader "Custom/CartoonHandDrawnShader"
{
    Properties
    {
        _OutlineColor ("Outline Color", Color) = (0,0,0,1)
        _OutlineWidth ("Outline Width", Range(0.001, 0.1)) = 0.02
        _LightThreshold ("Light Threshold", Range(0, 1)) = 0.2
        _Smoothness ("Smoothness", Range(0, 1)) = 0.5
        _BaseTexture ("Base Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 200

        // Pass for base rendering
        Pass
        {
            Name "BASE"
            ZWrite On
            ZTest LEqual
            Cull Back

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata_t
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            sampler2D _BaseTexture;
            float _OutlineWidth;
            float4 _OutlineColor;
            float _LightThreshold;

            v2f vert(appdata_t v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.normal = mul((float3x3)unity_WorldToObject, v.normal);
                o.uv = v.uv;
                return o;
            }

            half4 frag(v2f i) : SV_Target
            {
                // Sample texture color
                half4 texColor = tex2D(_BaseTexture, i.uv);

                // Calculate lighting for cell shading
                half3 normal = normalize(i.normal);
                half3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                half dotProd = dot(normal, lightDir);
                half shade = saturate((dotProd - _LightThreshold) * 10.0);

                // Apply texture color and shading
                half4 color = texColor * shade;

                // Ensure color is not too dark
                color.rgb = max(color.rgb, 0.1); // Adjust this value as needed

                return color;
            }
            ENDCG
        }

        // Pass for outline rendering
        Pass
        {
            Name "OUTLINE"
            ZWrite Off
            ZTest LEqual
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Front

            CGPROGRAM
            #pragma vertex vertOutline
            #pragma fragment fragOutline

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

            float _OutlineWidth;
            float4 _OutlineColor;

            v2f vertOutline(appdata_t v)
            {
                v2f o;
                float3 offset = v.normal * _OutlineWidth;
                o.pos = UnityObjectToClipPos(v.vertex + float4(offset, 0));
                return o;
            }

            half4 fragOutline(v2f i) : SV_Target
            {
                return half4(_OutlineColor.rgb, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
