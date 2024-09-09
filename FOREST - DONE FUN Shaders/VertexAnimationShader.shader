Shader "Custom/VertexAnimationShader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _AnimationSpeed ("Animation Speed", Range(0,10)) = 1
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata_t
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 pos : POSITION;
            };

            float _AnimationSpeed;

            v2f vert (appdata_t v)
            {
                v2f o;
                float t = _Time.y * _AnimationSpeed;
                v.vertex.y += sin(t + v.vertex.x) * 0.5;
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                return half4(1,1,1,1);
            }
            ENDCG
        }
    }
}
