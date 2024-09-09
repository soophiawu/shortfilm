Shader "Custom/LightScatteringShader"
{
    Properties
    {
        _Color ("Base Color", Color) = (1,1,1,1)
        _SpecularColor ("Specular Color", Color) = (1,1,1,1)
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _RimColor ("Rim Color", Color) = (1,1,1,1)
        _RimPower ("Rim Power", Range(1.0, 8.0)) = 4.0
        _MainTex ("Texture", 2D) = "white" {}
        _OrbitColor1 ("Orbit Color 1", Color) = (1, 0, 0, 1)
        _OrbitColor2 ("Orbit Color 2", Color) = (0, 1, 0, 1)
        _OrbitSpeed ("Orbit Speed", Float) = 1.0
        _NoiseScale ("Noise Scale", Float) = 0.5
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 200

        Pass
        {
            Name "FORWARD"
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata_t
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
                float3 viewDir : TEXCOORD1;
                float3 worldNormal : TEXCOORD2;
                float3 worldPos : TEXCOORD3;
            };

            sampler2D _MainTex;
            float4 _Color;
            float4 _SpecularColor;
            float _Glossiness;
            float _Metallic;
            float4 _RimColor;
            float _RimPower;
            float4 _OrbitColor1;
            float4 _OrbitColor2;
            float _OrbitSpeed;
            float _NoiseScale;

            v2f vert (appdata_t v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.viewDir = normalize(WorldSpaceViewDir(v.vertex));
                o.normal = v.normal;
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }

            // Function to create organic movement
            float noise(float3 pos)
            {
                return frac(sin(dot(pos, float3(12.9898, 78.233, 45.164))) * 43758.5453);
            }

            half4 frag (v2f i) : SV_Target
            {
                // Sample the main texture with a fallback if no texture is applied
                half4 texColor = tex2D(_MainTex, i.uv);
                if (texColor.a == 0)
                {
                    texColor = half4(1, 1, 1, 1); // Default to white if no texture is applied
                }

                // Compute the diffuse light
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                float diff = max(0, dot(i.worldNormal, lightDir));

                // Calculate specular reflection
                float3 reflectDir = reflect(-lightDir, i.worldNormal);
                float spec = pow(max(0, dot(i.viewDir, reflectDir)), _Glossiness * 128.0) * _Metallic;
                half4 specular = _SpecularColor * spec;

                // Rim lighting to highlight the edges
                float rim = pow(1.0 - saturate(dot(i.viewDir, i.worldNormal)), _RimPower);
                half4 rimLighting = _RimColor * rim;

                // Orbiting colors using noise and time
                float noiseValue = noise(i.worldPos * _NoiseScale + _Time.y * _OrbitSpeed);
                half4 orbitColor = lerp(_OrbitColor1, _OrbitColor2, noiseValue);

                // Combine color with texture, diffuse, specular, rim lighting, and orbiting colors
                half4 col = texColor * _Color * (diff + rimLighting) + specular + orbitColor;

                return col;
            }
            ENDCG
        }
    }
    FallBack "Standard"
}
