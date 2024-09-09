Shader "Custom/TerrainTessellation" {
    Properties {
        _MainTex ("Diffuse Map", 2D) = "white" {}
        _NormalMap ("Normal Map", 2D) = "bump" {}
        _HeightMap ("Height Map", 2D) = "black" {}
        _RoughnessMap ("Roughness Map", 2D) = "white" {}
        _HeightScale ("Height Scale", Float) = 0.1
        _TessellationFactor ("Tessellation Factor", Range(1, 64)) = 8
    }
    SubShader {
        Tags {"RenderType"="Opaque"}
        LOD 300

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows vertex:vert tessellate:tessFixed addshadow
        #pragma target 5.0

        #include "Tessellation.cginc"

        sampler2D _MainTex;
        sampler2D _NormalMap;
        sampler2D _HeightMap;
        sampler2D _RoughnessMap;
        float _HeightScale;
        float _TessellationFactor;

        struct Input {
            float2 uv_MainTex;
        };

        struct appdata {
            float4 vertex : POSITION;
            float4 tangent : TANGENT;
            float3 normal : NORMAL;
            float2 texcoord : TEXCOORD0;
        };

        float4 tessFixed() {
            return _TessellationFactor;
        }

        void vert(inout appdata v) {
            float height = tex2Dlod(_HeightMap, float4(v.texcoord.xy, 0, 0)).r;
            v.vertex.y += height * _HeightScale;
        }

        void surf(Input IN, inout SurfaceOutputStandard o) {
            fixed4 c = tex2D(_MainTex, IN.uv_MainTex);
            o.Albedo = c.rgb;
            o.Normal = UnpackNormal(tex2D(_NormalMap, IN.uv_MainTex));
            o.Smoothness = tex2D(_RoughnessMap, IN.uv_MainTex).r;  
        }
        ENDCG
    }
    FallBack "Diffuse"
}
