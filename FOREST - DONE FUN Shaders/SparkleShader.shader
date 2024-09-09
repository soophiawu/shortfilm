Shader "Custom/SparkleShader"
{
    Properties
    {
        _MainColor ("Main Color", Color) = (0.5, 0.8, 0.2, 1) // Base color for glass
        _EdgeColor ("Edge Color", Color) = (0, 0, 0, 1)       // Color for the lead lines
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _VoronoiScale ("Voronoi Scale", Float) = 10.0         // Scale of Voronoi cells
        _EdgeThickness ("Edge Thickness", Range(0.0, 1.0)) = 0.1 // Thickness of the dark edges
        _ColorVariation ("Color Variation", Range(0, 1)) = 0.5 // Variation in cell colors
        _GlowIntensity ("Glow Intensity", Range(0, 5)) = 2.0  // Intensity of the glow effect
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard

        struct Input
        {
            float3 worldPos;  // World position of the fragment
        };

        half4 _MainColor;
        half4 _EdgeColor;
        float _Glossiness;
        float _Metallic;
        float _VoronoiScale;
        float _EdgeThickness;
        float _ColorVariation;
        float _GlowIntensity;

        // Voronoi noise function for stained glass effect
        float voronoi(float2 uv, out float3 cellColor)
        {
            uv *= _VoronoiScale;
            float2 p = floor(uv);
            float2 f = frac(uv);
            float res = 8.0;
            float3 bestColor = float3(0,0,0);

            for (int j=-1; j<=1; j++)
            {
                for (int i=-1; i<=1; i++)
                {
                    float2 b = float2(i, j);
                    float2 r = b + frac(sin(dot(p + b, float2(127.1, 311.7))) * 43758.5453);
                    float d = length(f - r);
                    if (d < res)
                    {
                        res = d;
                        bestColor = float3(frac(sin(dot(p + b, float2(12.9898, 78.233))) * 43758.5453),
                                           frac(sin(dot(p + b, float2(93.9898, 67.345))) * 43758.5453),
                                           frac(sin(dot(p + b, float2(50.222, 12.345))) * 43758.5453));
                    }
                }
            }

            cellColor = bestColor * _ColorVariation + _MainColor.rgb * (1.0 - _ColorVariation);
            return res;
        }

        void surf(Input IN, inout SurfaceOutputStandard o)
        {
            // Generate Voronoi pattern and get cell color
            float3 cellColor;
            float cellDistance = voronoi(IN.worldPos.xz, cellColor);

            // Darken edges to create stained glass effect
            float edgeFactor = smoothstep(0.0, _EdgeThickness, cellDistance);

            // Apply base color and edge darkening
            o.Albedo = lerp(_EdgeColor.rgb, cellColor, edgeFactor);
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;

            // Add glow to the glass segments
            float glowAmount = _GlowIntensity * (1.0 - edgeFactor); // Glow strongest away from edges
            o.Emission = cellColor * glowAmount; // Emissive color based on cell color and intensity
        }
        ENDCG
    }
    FallBack "Diffuse"
}
