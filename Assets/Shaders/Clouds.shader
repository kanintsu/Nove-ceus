Shader "NoveCeus/Clouds"
{
    Properties
    {
        _Color ("Cloud Color", Color) = (0.93,0.97,1,1)
        _Coverage ("Coverage", Range(0,1)) = 0.52
        _Seed ("Seed", Float) = 9137
    }
    SubShader
    {
        Tags { "Queue"="Transparent+5" "RenderType"="Transparent" }
        Cull Back
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            #include "UnityCG.cginc"

            fixed4 _Color;
            float _Coverage, _Seed;

            struct appdata { float4 vertex:POSITION; float3 normal:NORMAL; };
            struct v2f { float4 pos:SV_POSITION; float3 objPos:TEXCOORD0; float3 worldNormal:TEXCOORD1; };

            float hash31(float3 p)
            {
                p = frac(p * 0.1031);
                p += dot(p, p.yzx + 31.32);
                return frac((p.x + p.y) * p.z);
            }

            float noise3(float3 p)
            {
                float3 i=floor(p), f=frac(p);
                f=f*f*(3.0-2.0*f);
                float a=hash31(i);
                float b=hash31(i+float3(1,0,0));
                float c=hash31(i+float3(0,1,0));
                float d=hash31(i+float3(1,1,0));
                float e=hash31(i+float3(0,0,1));
                float f1=hash31(i+float3(1,0,1));
                float g=hash31(i+float3(0,1,1));
                float h=hash31(i+float3(1,1,1));
                return lerp(lerp(lerp(a,b,f.x),lerp(c,d,f.x),f.y),lerp(lerp(e,f1,f.x),lerp(g,h,f.x),f.y),f.z);
            }

            float fbm(float3 p)
            {
                float v=0,a=.5;
                [unroll] for(int k=0;k<4;k++){ v+=noise3(p)*a; p=p*2.07+7.1; a*=.5; }
                return v;
            }

            v2f vert(appdata v)
            {
                v2f o;
                o.pos=UnityObjectToClipPos(v.vertex);
                o.objPos=v.vertex.xyz;
                o.worldNormal=UnityObjectToWorldNormal(v.normal);
                return o;
            }

            fixed4 frag(v2f i):SV_Target
            {
                float3 p=normalize(i.objPos);
                float seedShift=frac(_Seed*.00017)*9.0;
                float n=fbm(p*4.7+seedShift);
                float alpha=smoothstep(0.48+_Coverage*0.16,0.78,n);
                float light=saturate(dot(normalize(i.worldNormal),normalize(float3(.45,.72,-.32)))*.5+.55);
                return fixed4(_Color.rgb*(.62+light*.55), alpha*.74);
            }
            ENDCG
        }
    }
}