Shader "Custom/CelShader"
{
    Properties
    {
        _Color ("Base Color", Color) = (1,1,1,1)
        _BaseTexture ("Texture", 2D) = "white" {}
        _OutlineColor ("Outline Color", Color) = (0,0,0,1)
        _OutlineWidth ("Outline Width", Range(0.001, 0.1)) = 0.02
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 200

        Pass
        {
            Name "BASE"
            ZWrite On
            ZTest LEqual
            Cull Back

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
                float4 pos : POSITION;
                float4 color : COLOR;
                float2 uv : TEXCOORD0;
            };

            sampler2D _BaseTexture;
            float4 _Color;

            v2f vert(appdata_t v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.color = float4(1, 1, 1, 1); // Default white color
                o.uv = v.uv;
                return o;
            }

            half4 frag(v2f i) : SV_Target
            {
                half4 texColor = tex2D(_BaseTexture, i.uv);
                half3 color = texColor.rgb * _Color.rgb;
                
                // Simple cel shading effect
                half3 normal = normalize(i.color.rgb);
                half3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                half diff = dot(normal, lightDir);
                
                // Apply simple threshold for cel shading
                diff = step(0.5, diff);
                
                return half4(color * diff, texColor.a);
            }
            ENDCG
        }

        // Outline pass
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
