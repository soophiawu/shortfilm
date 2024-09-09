Shader "Custom/NebulaShader"
{
    Properties
    {
        _CameraPos ("Camera Position", Vector) = (0, 0, 0, 0)
        _TimeValue ("Time Value", Float) = 0.0
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0

            // Vertex Shader
            struct appdata_t
            {
                float3 position : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 fragPos : TEXCOORD1;
            };

            uniform float4 _CameraPos;
            uniform float _TimeValue;  // Renamed to avoid conflict with Unity's built-in _Time

            float4x4 _Model;
            float4x4 _View;
            float4x4 _Projection;

            v2f vert(appdata_t v)
            {
                v2f o;
                o.fragPos = mul(_Model, float4(v.position, 1.0)).xyz;
                o.uv = v.uv;
                o.pos = mul(_Projection, mul(_View, float4(o.fragPos, 1.0)));
                return o;
            }

            // Noise functions
            float3 mod289(float3 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
            float4 mod289(float4 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
            float4 permute(float4 x) { return mod289(((x * 34.0) + 1.0) * x); }
            float4 taylorInvSqrt(float4 r) { return 1.79284291400159 - 0.85373472095314 * r; }

            float snoise(float3 v)
            {
                const float2 C = float2(1.0 / 6.0, 1.0 / 3.0);
                const float4 D = float4(0.0, 0.5, 1.0, 2.0);

                float3 i = floor(v + dot(v, C.yy));
                float3 x0 = v - i + dot(i, C.xxx);

                float3 g = step(x0.yzx, x0.xyz);
                float3 l = 1.0 - g;
                float3 i1 = min(g.xyz, l.zxy);
                float3 i2 = max(g.xyz, l.zxy);

                float3 x1 = x0 - i1 + C.xxx;
                float3 x2 = x0 - i2 + C.yyy;
                float3 x3 = x0 - D.yyy;

                i = mod289(i);
                float4 p = permute(permute(permute(
                          i.z + float4(0.0, i1.z, i2.z, 1.0))
                        + i.y + float4(0.0, i1.y, i2.y, 1.0))
                        + i.x + float4(0.0, i1.x, i2.x, 1.0));

                float n_ = 0.142857142857;
                float3 ns = n_ * D.wyz - D.xzx;

                float4 j = p - 49.0 * floor(p * ns.z * ns.z);

                float4 x_ = floor(j * ns.z);
                float4 y_ = floor(j - 7.0 * x_);

                float4 x = x_ * ns.x + ns.yyyy;
                float4 y = y_ * ns.x + ns.yyyy;
                float4 h = 1.0 - abs(x) - abs(y);

                float4 b0 = float4(x.xy, y.xy);
                float4 b1 = float4(x.zw, y.zw);

                float4 s0 = floor(b0) * 2.0 + 1.0;
                float4 s1 = floor(b1) * 2.0 + 1.0;
                float4 sh = -step(h, float4(0.0));

                float4 a0 = b0.xzyw + s0.xzyw * sh.xxyy;
                float4 a1 = b1.xzyw + s1.xzyw * sh.zzww;

                float3 p0 = float3(a0.xy, h.x);
                float3 p1 = float3(a0.zw, h.y);
                float3 p2 = float3(a1.xy, h.z);
                float3 p3 = float3(a1.zw, h.w);

                float4 norm = taylorInvSqrt(float4(dot(p0, p0), dot(p1, p1), dot(p2, p2), dot(p3, p3)));
                p0 *= norm.x;
                p1 *= norm.y;
                p2 *= norm.z;
                p3 *= norm.w;

                float4 m = max(0.6 - float4(dot(x0, x0), dot(x1, x1), dot(x2, x2), dot(x3, x3)), 0.0);
                m = m * m;
                return 42.0 * dot(m * m, float4(dot(p0, x0), dot(p1, x1), dot(p2, x2), dot(p3, x3)));
            }

            float4 frag(v2f i) : SV_Target
            {
                float3 color = float3(0.0);
                float scale = 2.0;
                
                // Multiple layers of noise
                for (int j = 0; j < 5; j++)
                {
                    float noise = snoise(float3(i.uv * scale, _TimeValue * 0.1)) * 0.5 + 0.5;
                    color += float3(noise * 0.2, noise * 0.1, noise * 0.3) / float(j + 1);
                    scale *= 2.0;
                }
                
                // Add depth and perspective
                float depth = length(i.fragPos - _CameraPos.xyz);
                color *= 1.0 / (1.0 + depth * 0.1);
                
                // Add stars
                float2 starCoord = i.uv * 1000.0;
                float2 starId = floor(starCoord);
                float2 starLocal = frac(starCoord) - 0.5;
                float starRandom = frac(sin(dot(starId, float2(12.9898, 78.233))) * 43758.5453);
                float star = 1.0 - step(starRandom, 0.998);
                star *= 1.0 - length(starLocal) * 2.0;
                color += float3(1.0) * max(star, 0.0) * 5.0;
                
                return float4(color, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
