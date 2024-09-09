Shader "Custom/AdvancedForestGround"
{
    Properties
    {
        _BaseTex ("Base Texture", 2D) = "white" {}
        _MossTex ("Moss Texture", 2D) = "white" {}
        _DirtTex ("Dirt Texture", 2D) = "white" {}
        _NormalMap ("Normal Map", 2D) = "bump" {}
        _SpecMap ("Specular Map", 2D) = "white" {}
        _Detail ("Detail Factor", Range(0, 1)) = 0.5
        _ShadowTex ("Shadow Texture", 2D) = "white" {}
        _Roughness ("Roughness", Range(0, 1)) = 0.5
        _Metallic ("Metallic", Range(0, 1)) = 0.0
        _AmbientOcclusion ("Ambient Occlusion", 2D) = "white" {}
        _WindStrength ("Wind Strength", Range(0, 1)) = 0.5
        _TimeFactor ("Time Factor", Range(0, 10)) = 1.0
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 400

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 5.0

            struct appdata_t
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float4 shadowCoord : TEXCOORD1;
                float4 worldPos : TEXCOORD2;
            };

            sampler2D _BaseTex;
            sampler2D _MossTex;
            sampler2D _DirtTex;
            sampler2D _NormalMap;
            sampler2D _SpecMap;
            sampler2D _ShadowTex;
            sampler2D _AmbientOcclusion;
            float _Detail;
            float _Roughness;
            float _Metallic;
            float _WindStrength;
            float _TimeFactor;

            float4x4 _ObjectToWorld;

            v2f vert(appdata_t v)
            {
                v2f o;
                float4 worldPos = mul(_ObjectToWorld, v.vertex);
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.normal = mul((float3x3)_ObjectToWorld, v.normal);
                o.shadowCoord = mul(UNITY_MATRIX_VP, float4(worldPos.xyz, 1.0));
                o.worldPos = worldPos;

                return o;
            }

            half4 frag(v2f i) : SV_Target
            {
                half4 baseColor = tex2D(_BaseTex, i.uv);
                half4 mossColor = tex2D(_MossTex, i.uv);
                half4 dirtColor = tex2D(_DirtTex, i.uv);
                half4 shadowColor = tex2D(_ShadowTex, i.shadowCoord.xy);
                half4 aoColor = tex2D(_AmbientOcclusion, i.uv);

                // Compute wind effect
                float wind = sin(_TimeFactor * _WindStrength + i.worldPos.x * 0.1) * 0.1;
                half4 windColor = lerp(baseColor, baseColor * (1.0 - wind), wind);

                // Blend textures based on detail factor
                half4 blendedColor = lerp(windColor, mossColor, _Detail) * lerp(1.0, dirtColor, _Detail);

                // Apply ambient occlusion and shadow
                blendedColor *= shadowColor * aoColor;

                // Apply PBR-like metallic and roughness
                half spec = tex2D(_SpecMap, i.uv).r * (1.0 - _Roughness);
                half4 metallicColor = half4(1.0, 1.0, 1.0, _Metallic);
                blendedColor = lerp(blendedColor, metallicColor, spec);

                return blendedColor;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
