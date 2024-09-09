Shader "Custom/AtmosphericScattering"
{
    Properties
    {
        _SunDirection ("Sun Direction", Vector) = (0, 1, 0, 0)
        _SunColor ("Sun Color", Color) = (1, 1, 1, 1)
        _PlanetRadius ("Planet Radius", Float) = 6371000
        _AtmosphereHeight ("Atmosphere Height", Float) = 80000
        _RayleighScatteringCoeff ("Rayleigh Scattering Coefficient", Vector) = (5.5e-6, 13.0e-6, 22.4e-6, 0)
        _MieScatteringCoeff ("Mie Scattering Coefficient", Float) = 21e-6
    }

    SubShader
    {
        Tags { "Queue" = "Transparent", "RenderType" = "Transparent" }
        LOD 100

        CGPROGRAM
        #pragma surface surf Lambert alpha
        #pragma target 3.0

        #define PI 3.14159265359

        float4 _SunDirection;
        float4 _SunColor;
        float _PlanetRadius;
        float _AtmosphereHeight;
        float4 _RayleighScatteringCoeff;
        float _MieScatteringCoeff;

        struct Input
        {
            float3 viewDir;
            float3 worldPos;
        };

        float phaseRayleigh(float cosTheta)
        {
            return 3.0 / (16.0 * PI) * (1.0 + cosTheta * cosTheta);
        }

        float phaseMie(float cosTheta)
        {
            float g = 0.76;
            float g2 = g * g;
            return 3.0 / (8.0 * PI) * ((1.0 - g2) * (1.0 + cosTheta * cosTheta)) /
                   (pow(1.0 + g2 - 2.0 * g * cosTheta, 1.5) * (2.0 + g2));
        }

        float3 computeScattering(float3 start, float3 dir, float maxDist, float3 sunDir)
        {
            float cosTheta = dot(dir, sunDir);
            float rayleighPhase = phaseRayleigh(cosTheta);
            float miePhase = phaseMie(cosTheta);
            float3 totalRayleigh = _RayleighScatteringCoeff.rgb * rayleighPhase;
            float3 totalMie = _MieScatteringCoeff * miePhase;
            return _SunColor.rgb * (totalRayleigh + totalMie);
        }

        void surf(Input IN, inout SurfaceOutput o)
        {
            float3 viewDir = normalize(IN.viewDir);
            float3 worldPos = IN.worldPos;
            float3 scattering = computeScattering(worldPos, viewDir, 1000000, normalize(_SunDirection.xyz));
            
            o.Emission = 1.0 - exp(-scattering * 0.5);
            o.Emission = pow(o.Emission, 1.0 / 2.2); // Gamma correction
            o.Alpha = 1.0;
        }
        ENDCG
    }

    FallBack "Diffuse"
}
