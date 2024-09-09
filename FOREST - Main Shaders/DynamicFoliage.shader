Shader "Custom/DynamicFoliage" {
    Properties {
        _MainTex ("Diffuse Map", 2D) = "white" {}
        _NormalMap ("Normal Map", 2D) = "bump" {}
        _RoughnessMap ("Roughness Map", 2D) = "white" {}
        _AOMap ("Ambient Occlusion Map", 2D) = "white" {}
        _WindStrength ("Wind Strength", Float) = 0.1
        _WindSpeed ("Wind Speed", Float) = 2.0
        _WindDirection ("Wind Direction", Vector) = (1, 0, 0.5, 0)
    }
    SubShader {
        Tags {"RenderType"="Opaque"}
        LOD 100

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows vertex:vert addshadow
        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _NormalMap;
        sampler2D _RoughnessMap;
        sampler2D _AOMap;

        float _WindStrength;
        float _WindSpeed;
        float4 _WindDirection;

        struct Input {
            float2 uv_MainTex;
            float3 worldPos;
        };

        void vert(inout appdata_full v) {
            float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
            float windEffect = sin(_Time.y * _WindSpeed + worldPos.x * 0.5 + worldPos.z * 0.3) * _WindStrength;
            float3 windOffset = normalize(_WindDirection.xyz) * windEffect * smoothstep(0, 1, v.vertex.y / 10.0);
            v.vertex.xyz += windOffset;
        }

        void surf (Input IN, inout SurfaceOutputStandard o) {
            fixed4 c = tex2D(_MainTex, IN.uv_MainTex);
            o.Albedo = c.rgb;
            o.Normal = UnpackNormal(tex2D(_NormalMap, IN.uv_MainTex));
            
            // Since Roughness isn't directly available, map it to Smoothness (1 - roughness)
            float roughness = tex2D(_RoughnessMap, IN.uv_MainTex).r;
            o.Smoothness = 1.0 - roughness; // Convert roughness to smoothness
            
            o.Occlusion = tex2D(_AOMap, IN.uv_MainTex).r;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
