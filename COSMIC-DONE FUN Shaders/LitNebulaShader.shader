Shader "Custom/LitNebulaShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _NebulaColor1 ("Nebula Color 1", Color) = (1, 0, 0, 1)
        _NebulaColor2 ("Nebula Color 2", Color) = (0, 0, 1, 1)
        _NoiseScale ("Noise Scale", Range(0.1, 10.0)) = 1.0
        _NebulaIntensity ("Nebula Intensity", Range(0.0, 2.0)) = 1.0
        _Speed ("Speed", Range(0.0, 1.0)) = 0.1
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 200

        Pass
        {
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
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
            };

            float _NoiseScale;
            float _NebulaIntensity;
            float _Speed;
            float4 _NebulaColor1;
            float4 _NebulaColor2;

            // Simplex noise function for more organic patterns
            float PerlinNoise(float2 uv)
            {
                // Using a combination of Perlin noise for a smoother effect
                float noise1 = (sin(uv.x * 10.0 + _Time.y * _Speed) * 0.5 + 0.5);
                float noise2 = (sin(uv.y * 10.0 + _Time.y * _Speed) * 0.5 + 0.5);
                return (noise1 + noise2) * 0.5;
            }

            // Cloud-like blending function
            float CloudPattern(float2 uv)
            {
                float noise = PerlinNoise(uv * _NoiseScale);
                return smoothstep(0.3, 0.7, noise);
            }

            v2f vert (appdata_t v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                float cloud = CloudPattern(i.uv);
                half4 col = lerp(_NebulaColor1, _NebulaColor2, cloud) * _NebulaIntensity;
                return col;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
