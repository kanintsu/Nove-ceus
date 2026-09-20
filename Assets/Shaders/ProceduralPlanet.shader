Shader "NoveCeus/ProceduralPlanet"
{
    Properties
    {
        _OceanDeep ("Ocean Deep", Color) = (0.005,0.05,0.12,1)
        _OceanShallow ("Ocean Shallow", Color) = (0.02,0.35,0.48,1)
        _LandLow ("Land Low", Color) = (0.08,0.24,0.12,1)
        _LandHigh ("Land High", Color) = (0.34,0.28,0.15,1)
        _Rock ("Rock", Color) = (0.28,0.25,0.23,1)
        _Water ("Water", Range(0,1)) = 0.71
        _Temperature ("Temperature", Range(-100,250)) = 16
        _Life ("Life", Range(0,1)) = 0.18
        _Civilization ("Civilization", Range(0,1)) = 0.04
        _Seed ("Seed", Float) = 9137
        _SunDir ("Sun Direction", Vector) = (0.5,0.6,-0.2,0)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry" }
        LOD 250
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            #include "UnityCG.cginc"

            fixed4 _OceanDeep, _OceanShallow, _LandLow, _LandHigh, _Rock;
            float _Water, _Temperature, _Life, _Civilization, _Seed;
            float4 _SunDir;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 objPos : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
                float3 worldPos : TEXCOORD2;
            };

            float hash31(float3 p)
            {
                p = frac(p * 0.1031);
                p += dot(p, p.yzx + 33.33);
                return frac((p.x + p.y) * p.z);
            }

            float noise3(float3 p)
            {
                float3 i = floor(p);
                float3 f = frac(p);
                f = f * f * (3.0 - 2.0 * f);

                float n000 = hash31(i + float3(0,0,0));
                float n100 = hash31(i + float3(1,0,0));
                float n010 = hash31(i + float3(0,1,0));
                float n110 = hash31(i + float3(1,1,0));
                float n001 = hash31(i + float3(0,0,1));
                float n101 = hash31(i + float3(1,0,1));
                float n011 = hash31(i + float3(0,1,1));
                float n111 = hash31(i + float3(1,1,1));

                float nx00 = lerp(n000, n100, f.x);
                float nx10 = lerp(n010, n110, f.x);
                float nx01 = lerp(n001, n101, f.x);
                float nx11 = lerp(n011, n111, f.x);
                float nxy0 = lerp(nx00, nx10, f.y);
                float nxy1 = lerp(nx01, nx11, f.y);
                return lerp(nxy0, nxy1, f.z);
            }

            float fbm(float3 p)
            {
                float v = 0.0;
                float a = 0.5;
                [unroll] for (int k = 0; k < 5; k++)
                {
                    v += noise3(p) * a;
                    p = p * 2.03 + float3(17.1, 9.2, 13.7);
                    a *= 0.5;
                }
                return v;
            }

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.objPos = v.vertex.xyz;
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float3 p = normalize(i.objPos);
                float seedShift = frac(_Seed * 0.000123) * 11.0;
                float baseN = fbm(p * 2.8 + seedShift);
                float detailN = fbm(p * 8.4 + seedShift * 0.37);
                float ridges = abs(fbm(p * 13.0 + 2.7) - 0.5) * 2.0;
                float terrain = baseN * 0.78 + detailN * 0.28 - ridges * 0.08;

                float seaLevel = lerp(0.67, 0.47, _Water);
                float coast = smoothstep(seaLevel - 0.025, seaLevel + 0.03, terrain);
                float landMask = smoothstep(seaLevel, seaLevel + 0.035, terrain);

                float latitude = abs(p.y);
                float heat = saturate((_Temperature + 35.0) / 115.0);
                float ice = smoothstep(0.72 - heat * 0.18, 0.94 - heat * 0.05, latitude);
                ice *= 0.35 + 0.65 * smoothstep(seaLevel - 0.08, seaLevel + 0.1, terrain);

                float depth = saturate((seaLevel - terrain) * 7.0);
                float3 ocean = lerp(_OceanShallow.rgb, _OceanDeep.rgb, depth);

                float altitude = saturate((terrain - seaLevel) * 5.0);
                float moisture = saturate(_Water * 1.25 + detailN * 0.35 - 0.25);
                float veg = saturate(_Life * 1.55 * moisture * (1.0 - altitude));
                float3 landBase = lerp(_LandLow.rgb, _LandHigh.rgb, altitude);
                float3 fertile = lerp(float3(0.05,0.16,0.08), float3(0.18,0.42,0.12), detailN);
                float3 land = lerp(landBase, fertile, veg);
                land = lerp(land, _Rock.rgb, smoothstep(0.58, 0.9, altitude));

                float lavaHeat = saturate((_Temperature - 55.0) / 150.0);
                float lavaCrack = smoothstep(0.82, 0.92, fbm(p * 19.0 + 5.0)) * lavaHeat * landMask;
                land = lerp(land, float3(1.35,0.18,0.015), lavaCrack);

                float3 albedo = lerp(ocean, land, coast);
                albedo = lerp(albedo, float3(0.82,0.9,0.96), ice);

                float3 n = normalize(i.worldNormal);
                float3 l = normalize(_SunDir.xyz);
                float ndl = dot(n, l);
                float daylight = saturate(ndl * 0.78 + 0.28);
                float rim = pow(1.0 - saturate(dot(n, normalize(_WorldSpaceCameraPos - i.worldPos))), 3.0);
                float3 lit = albedo * (0.22 + daylight * 0.92);
                lit += float3(0.04,0.11,0.22) * rim * 0.55;

                float cityPattern = fbm(p * 42.0 + seedShift * 2.0);
                float city = smoothstep(0.72, 0.9, cityPattern) * landMask * _Civilization;
                float night = saturate(-ndl * 2.5);
                lit += float3(1.5,0.76,0.18) * city * night * 2.2;

                return fixed4(lit, 1);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}