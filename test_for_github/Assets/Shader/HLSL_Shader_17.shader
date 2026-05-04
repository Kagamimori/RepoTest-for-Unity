// Upgrade NOTE: replaced tex2D unity_Lightmap with UNITY_SAMPLE_TEX2D

Shader "Unlit/HLSL_Shader_17"
{
    properties
    {
        _MainTex("MainTex",2D) = ""{}
        _A("A",Range(0,0.06)) = 0.02
        _F("F",Range(1,20)) = 10
        _R("R",Range(0,1)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
      
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "UnityLightingCommon.cginc"  // 如果有用到其他光照变量

            sampler2D _MainTex;

            float4 _MainTex_ST; // 自动挡
            float _A;
            float _F;
            float _R;

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                
            };

            v2f vert (appdata_full v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                           
                o.uv = TRANSFORM_TEX(v.texcoord,_MainTex); // 直接应用平铺和平移

                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                //i.uv += _A * sin(i.uv * 3.14 * _F + _Time.y); // 纵横
                // if(distance(i.uv,float2(0.5,0.5)) < _R) // 可以省略
                i.uv += i.uv * _A * saturate((1-distance(i.uv,float2(0.5,0.5)) / _R)) * sin(- _F * 3.14 * saturate(distance(i.uv,float2(0.5,0.5))) + _Time.y);

                half4 col = tex2D(_MainTex,i.uv,float2(0.01,0.01),float2(0.01,0.01));
                
                return col;
            }
            ENDCG
        }
    }
}
