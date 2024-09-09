Shader "Custom/AbstractPatternLit"
{
    Properties
    {
        _SwirlColor ("Swirl Color", Color) = (1, 0.5, 0, 1)  
        _SwirlSpeed ("Swirl Speed", Float) = 1.0             
        _SwirlDensity ("Swirl Density", Float) = 5.0         
        _GlowIntensity ("Glow Intensity", Range(0, 5)) = 1.0 // Controls the strength of the emission
        _MainTex ("Texture", 2D) = "white" {}                
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows

        sampler2D _MainTex;
        float4 _SwirlColor;
        float _SwirlSpeed;
        float _SwirlDensity;
        float _GlowIntensity;

        struct Input
        {
            float2 uv_MainTex;
        };

        half4 GenerateSwirlPattern(float2 uv, float time)
        {
            float angle = atan2(uv.y - 0.5, uv.x - 0.5);
            float radius = length(uv - 0.5);
            float swirl = sin(angle * _SwirlDensity + time * _SwirlSpeed + radius * 10.0);
            float3 color = _SwirlColor.rgb * (0.5 + 0.5 * swirl);
            return half4(color, 1);
        }

        void surf(Input IN, inout SurfaceOutputStandard o)
        {
            float time = _Time.y;
            half4 swirlPattern = GenerateSwirlPattern(IN.uv_MainTex, time);
            o.Albedo = swirlPattern.rgb;
            o.Emission = swirlPattern.rgb * _GlowIntensity; // Add glow effect by scaling the swirl color
        }
        ENDCG
    }
    FallBack "Diffuse"
}
