Shader "Custom/LitStarFieldUniformTwinklingShader"
{
    Properties
    {
        _StarColor ("Star Color", Color) = (1, 1, 1, 1)
        _StarSize ("Star Size", Range(0.0, 0.5)) = 0.1
        _Density ("Density", Range(0.0, 10.0)) = 1.0
        _NoiseScale ("Noise Scale", Range(0.0, 10.0)) = 1.0
        _Brightness ("Brightness", Range(0.0, 5.0)) = 1.0
        _TwinkleSpeed ("Twinkle Speed", Range(0.1, 5.0)) = 1.0
        _TwinkleIntensity ("Twinkle Intensity", Range(0.0, 1.0)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType" = "Transparent" }
        LOD 200

        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            // Function to generate Perlin noise
            float PerlinNoise(float2 uv)
            {
                return frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
            }

            struct appdata_t
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            float4 _StarColor;
            float _StarSize;
            float _Density;
            float _NoiseScale;
            float _Brightness;
            float _TwinkleSpeed;
            float _TwinkleIntensity;

            v2f vert (appdata_t v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.vertex.xy * 0.5 + 0.5; // Normalize UV coordinates
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                float2 uv = i.uv * _Density;
                float noise = PerlinNoise(uv * _NoiseScale);

                // Create a unique seed for each star
                float seed = dot(uv, float2(12.9898, 78.233)) * 43758.5453;
                float twinkle = (sin(seed + _Time.y * _TwinkleSpeed) * 0.5 + 0.5) * _TwinkleIntensity;

                // Calculate star visibility and ensure even distribution
                float dist = length(uv - 0.5); // Distance from center
                float star = smoothstep(_StarSize, _StarSize * 0.5, noise);
                float visibility = star * (twinkle + 0.1); // Add minimum brightness

                // Combine star color and visibility
                half4 col = _StarColor * visibility;
                col.a = visibility; // Set alpha based on visibility
                return col;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
