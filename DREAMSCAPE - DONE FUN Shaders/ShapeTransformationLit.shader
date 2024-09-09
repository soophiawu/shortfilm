Shader "Custom/ShapeTransformationLit"
{
    Properties
    {
        _MorphSpeed ("Morph Speed", Float) = 1.0
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows vertex:vert

        sampler2D _MainTex;
        float _MorphSpeed;

        struct Input
        {
            float2 uv_MainTex;
        };

        void vert (inout appdata_full v)
        {
            float offset = sin(_Time.y * _MorphSpeed + v.vertex.x) * 0.1;
            v.vertex.xyz += float3(0, offset, 0);
        }

        void surf(Input IN, inout SurfaceOutputStandard o)
        {
            o.Albedo = 1; // Simple white color with lighting
        }
        ENDCG
    }
    FallBack "Diffuse"
}
