Shader "Custom/FogEffect"
{
    Properties
    {
        _SceneTexture ("Scene Texture", 2D) = "white" {}
        _DepthTexture ("Depth Texture", 2D) = "black" {}
        _LightPos ("Light Position", Vector) = (1, 1, 1, 0)
        _CameraPos ("Camera Position", Vector) = (0, 0, 0, 0)
        _Density ("Fog Density", Float) = 0.5
        _Decay ("Fog Decay", Float) = 0.95
        _Exposure ("Fog Exposure", Float) = 0.3
        _Weight ("Fog Weight", Float) = 5.65 
    }

    SubShader
    {
        Tags { "Queue" = "Overlay" }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 4.0
            #include "UnityCG.cginc"

            struct appdata
            {
                float3 pos : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 clipSpacePos : TEXCOORD1;
            };

            // Uniforms
            uniform float4x4 _Model;
            uniform float4x4 _View;
            uniform float4x4 _Projection;
            uniform float4x4 _InvProjection;
            uniform float4x4 _InvView;
            uniform float3 _CameraPos;
            uniform float3 _LightPos;
            uniform sampler2D _SceneTexture;
            uniform sampler2D _DepthTexture;
            uniform float _Density;
            uniform float _Decay;
            uniform float _Exposure;
            uniform float _Weight; 

            const int NUM_SAMPLES = 100;

            v2f vert(appdata v)
            {
                v2f o;
                o.uv = v.uv;
                o.clipSpacePos = mul(_Projection * _View * _Model, float4(v.pos, 1.0));
                o.pos = o.clipSpacePos;
                return o;
            }

            float3 worldPosFromDepth(float depth, float2 texCoords)
            {
                float z = depth * 2.0 - 1.0;
                float4 clipSpacePosition = float4(texCoords * 2.0 - 1.0, z, 1.0);
                float4 viewSpacePosition = mul(_InvProjection, clipSpacePosition);
                viewSpacePosition /= viewSpacePosition.w;
                float4 worldSpacePosition = mul(_InvView, viewSpacePosition);
                return worldSpacePosition.xyz;
            }

            float4 frag(v2f i) : SV_Target
            {
                float2 texCoord = i.uv;
                float3 sceneColor = tex2D(_SceneTexture, texCoord).rgb;
                float depth = tex2D(_DepthTexture, texCoord).r;

                float3 worldPos = worldPosFromDepth(depth, texCoord);
                float3 rayVector = worldPos - _CameraPos;
                float rayLength = length(rayVector);
                float3 rayDir = rayVector / rayLength;

                float4 lightProjected = mul(_Projection * _View, float4(_LightPos, 1.0));
                float2 lightScreenPos = (lightProjected.xy / lightProjected.w) * 0.5 + 0.5;

                float2 deltaTexCoord = (texCoord - lightScreenPos) / float(NUM_SAMPLES);
                float2 currentTexCoord = texCoord;

                float3 accumFog = float3(0.0, 0.0, 0.0);
                float illuminationDecay = 1.0;

                for (int i = 0; i < NUM_SAMPLES; i++)
                {
                    currentTexCoord -= deltaTexCoord;

                    float sampleDepth = tex2D(_DepthTexture, currentTexCoord).r;
                    float3 sampleWorldPos = worldPosFromDepth(sampleDepth, currentTexCoord);
                    float sampleDist = distance(_CameraPos, sampleWorldPos);

                    if (sampleDist < rayLength)
                    {
                        float3 lightDir = normalize(_LightPos - sampleWorldPos);
                        float dotProd = max(dot(rayDir, lightDir), 0.0);

                        float3 sampleFog = dotProd * _Weight * illuminationDecay * _Density;
                        accumFog += sampleFog;
                    }

                    illuminationDecay *= _Decay;
                }

                float3 fogColor = accumFog * _Exposure;
                float3 finalColor = sceneColor + fogColor;

                // Apply a simple tonemapping
                finalColor = finalColor / (finalColor + float3(1.0, 1.0, 1.0));
                finalColor = pow(finalColor, float3(1.0 / 2.2, 1.0 / 2.2, 1.0 / 2.2)); // Gamma correction

                return float4(finalColor, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
