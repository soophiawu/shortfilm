Shader "Custom/ColorPulsationLit"
{
    Properties
    {
        _BaseColor ("Base Color", Color) = (1, 1, 1, 1)
        _PulseSpeed ("Pulse Speed", Float) = 1.0
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows

        sampler2D _MainTex;
        float4 _BaseColor;
        float _PulseSpeed;

        struct Input
        {
            float2 uv_MainTex;
        };

        void surf(Input IN, inout SurfaceOutputStandard o)
        {
            float pulse = abs(sin(_Time.y * _PulseSpeed));
            o.Albedo = _BaseColor.rgb * pulse;
            o.Emission = _BaseColor.rgb * pulse * 0.5;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
