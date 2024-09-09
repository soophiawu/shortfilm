Shader "Custom/PatchworkShader"
{
    Properties
    {
        _MainColor ("Main Color", Color) = (1,1,1,1)
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _PatchSize ("Patch Size", Range(0.1, 10.0)) = 1.0
        _ColorVariation ("Color Variation", Range(0, 1)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard

        struct Input
        {
            float3 worldPos; // World position of each fragment
        };

        half4 _MainColor;
        float _Glossiness;
        float _Metallic;
        float _PatchSize;
        float _ColorVariation;

        // Random color generation based on cell position
        half3 randomColor(float2 pos)
        {
            float n = frac(sin(dot(pos, float2(12.9898, 78.233))) * 43758.5453);
            return lerp(_MainColor.rgb, half3(n, frac(n * 2.0), frac(n * 3.0)), _ColorVariation);
        }

        void surf(Input IN, inout SurfaceOutputStandard o)
        {
            // Calculate grid cell position
            float2 cellPos = floor(IN.worldPos.xz / _PatchSize);

            // Generate a random color based on the cell position
            half3 patchColor = randomColor(cellPos);

            // Apply the patch color
            o.Albedo = patchColor;
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
