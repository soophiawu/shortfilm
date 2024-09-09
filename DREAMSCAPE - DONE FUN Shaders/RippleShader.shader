Shader "Custom/CartoonWaterShader"
{
    Properties
    {
        _BaseColor ("Base Color", Color) = (0,0,1,1)
        _RippleColor ("Ripple Color", Color) = (0,1,1,1)
        _RippleSpeed ("Ripple Speed", Float) = 1.0
        _RippleStrength ("Ripple Strength", Float) = 0.5
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 200

        Pass
        {
            Name "WATER"
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata_t
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : POSITION;
                float2 uv : TEXCOORD0;
            };

            sampler2D _MainTex;
            float4 _BaseColor;
            float4 _RippleColor;
            float _RippleSpeed;
            float _RippleStrength;

            v2f vert(appdata_t v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            half4 frag(v2f i) : SV_Target
            {
                float2 uv = i.uv;
                float ripple = sin((uv.x + uv.y) * 10.0 + _Time.y * _RippleSpeed) * _RippleStrength;
                half4 baseColor = tex2D(_MainTex, uv + ripple);
                return lerp(baseColor, _RippleColor, ripple);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
