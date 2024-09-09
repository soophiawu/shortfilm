Shader "Custom/LitWaveShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _WaveHeight ("Wave Height", Range(0, 1)) = 0.1
        _WaveSpeed ("Wave Speed", Range(0, 2)) = 1.0
        _Glossiness ("Glossiness", Range(0, 1)) = 0.5
        _Metallic ("Metallic", Range(0, 1)) = 0.0
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
            #include "Lighting.cginc"

            struct appdata_t
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            sampler2D _MainTex;
            float _WaveHeight;
            float _WaveSpeed;
            float _Glossiness;
            float _Metallic;

            v2f vert (appdata_t v)
            {
                v2f o;
                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                float3 worldNormal = mul((float3x3)unity_ObjectToWorld, v.vertex.xyz);
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                
                // Apply wave effect to the vertex position
                worldPos.y += sin(_Time.y * _WaveSpeed + v.uv.x * 10.0) * _WaveHeight;
                
                // Transform the modified world position back to object space
                o.pos = UnityObjectToClipPos(float4(worldPos, 1.0));
                o.normal = worldNormal;
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                // Sample the texture
                half4 baseColor = tex2D(_MainTex, i.uv);

                // Lighting calculation
                half3 normal = normalize(i.normal);
                half3 lightDir = normalize(UnityWorldSpaceLightDir(i.normal));  // Direction of light
                half diff = max(dot(normal, lightDir), 0.0);
                half4 lighting = diff * _LightColor0;

                // Combine texture color with lighting
                half4 col = baseColor * lighting;
                return col;
            }
            ENDCG
        }
    }
    FallBack "Standard"
}
