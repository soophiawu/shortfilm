Shader "Custom/LitWaterDistortionShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Distortion ("Distortion Strength", Range(0, 1)) = 0.1
        _TimeScale ("Time Scale", Range(0.1, 2.0)) = 1.0
        _Glossiness ("Glossiness", Range(0, 1)) = 0.5
        _Metallic ("Metallic", Range(0, 1)) = 0.0
    }
    SubShader
    {
        Tags { "RenderType" = "Transparent" }
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
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float3 normal : NORMAL;
            };

            sampler2D _MainTex;
            float _Distortion;
            float _TimeScale;
            float _Glossiness;
            float _Metallic;

            v2f vert (appdata_t v)
            {
                v2f o;
                float time = _TimeScale * _Time.y;
                float distortion = sin(v.uv.y * 10 + time) * _Distortion;
                float2 uvDistorted = v.uv + float2(distortion, distortion);

                // Calculate the world position with distortion
                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = uvDistorted;
                o.normal = mul((float3x3)unity_ObjectToWorld, v.vertex.xyz);
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                // Sample the texture
                half4 baseColor = tex2D(_MainTex, i.uv);

                // Lighting calculation
                half3 normal = normalize(i.normal);
                half3 lightDir = normalize(UnityWorldSpaceLightDir(normal));  // Direction of light
                half diff = max(dot(normal, lightDir), 0.0);
                half4 lighting = diff * _LightColor0;

                // Combine texture color with lighting
                half4 col = baseColor * lighting;
                col.rgb = lerp(col.rgb, _LightColor0.rgb, 0.5);  // Adjust brightness if needed
                return col;
            }
            ENDCG
        }
    }
    FallBack "Standard"
}
