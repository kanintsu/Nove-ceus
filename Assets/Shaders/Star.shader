Shader "NoveCeus/Star"
{
    Properties
    {
        _ColorA ("Core", Color) = (1,0.92,0.62,1)
        _ColorB ("Edge", Color) = (1,0.35,0.05,1)
        _Pulse ("Pulse", Range(0,2)) = 1
    }
    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" }
        ZWrite Off
        Blend SrcAlpha One
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            fixed4 _ColorA,_ColorB;
            float _Pulse;
            struct appdata{float4 vertex:POSITION;float3 normal:NORMAL;};
            struct v2f{float4 pos:SV_POSITION;float3 n:TEXCOORD0;float3 wp:TEXCOORD1;};
            v2f vert(appdata v){v2f o;o.pos=UnityObjectToClipPos(v.vertex);o.n=UnityObjectToWorldNormal(v.normal);o.wp=mul(unity_ObjectToWorld,v.vertex).xyz;return o;}
            fixed4 frag(v2f i):SV_Target
            {
                float3 vd=normalize(_WorldSpaceCameraPos-i.wp);
                float facing=saturate(dot(normalize(i.n),vd));
                float rim=pow(1-facing,1.8);
                float flicker=.88+.12*sin(_Time.y*2.7+i.wp.x*8+i.wp.y*5);
                float3 c=lerp(_ColorA.rgb,_ColorB.rgb,rim)*flicker*_Pulse;
                return fixed4(c,0.92);
            }
            ENDCG
        }
    }
}