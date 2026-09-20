Shader "NoveCeus/Atmosphere"
{
    Properties
    {
        _Color ("Atmosphere Color", Color) = (0.1,0.65,1,1)
        _Intensity ("Intensity", Range(0,4)) = 1.8
    }
    SubShader
    {
        Tags { "Queue"="Transparent+20" "RenderType"="Transparent" }
        Cull Front
        ZWrite Off
        Blend SrcAlpha One

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0
            #include "UnityCG.cginc"

            fixed4 _Color;
            float _Intensity;

            struct appdata { float4 vertex:POSITION; float3 normal:NORMAL; };
            struct v2f { float4 pos:SV_POSITION; float3 worldNormal:TEXCOORD0; float3 worldPos:TEXCOORD1; };

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);
                float fresnel = pow(1.0 - saturate(dot(normalize(i.worldNormal), viewDir)), 2.7);
                float a = saturate(fresnel * 0.68 * _Intensity);
                return fixed4(_Color.rgb * (0.5 + fresnel * _Intensity), a);
            }
            ENDCG
        }
    }
}