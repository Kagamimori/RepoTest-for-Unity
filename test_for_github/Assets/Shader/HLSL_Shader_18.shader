// Upgrade NOTE: replaced tex2D unity_Lightmap with UNITY_SAMPLE_TEX2D

Shader "Unlit/HLSL_Shader_18"
{
    properties
    {
       _MainTex("MainTex",2D) = ""{}
       _SecondTex("SecondTex",2D) = ""{}
       _F("F",range(1,10)) = 2
       _A("A",range(0,0.1)) = 0.01
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
      
        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "UnityLightingCommon.cginc"  // 如果有用到其他光照变量

            Texture2D _MainTex;
            SamplerState sampler_MainTex;  // HLSL 需要显式采样器
            Texture2D _SecondTex;
            SamplerState sampler_SecondTex;

            float _F;
            float _A;


            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                
            };

            v2f vert (appdata_full v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);

                o.uv = v.texcoord;
                           
                return o;
            }

            half4 frag (v2f i) : SV_Target // 思路：先给主，负的给周期和非周期偏移，用单通道给色
            {
                half4 col = _MainTex.Sample(sampler_MainTex,i.uv);
                float offset = _A * sin(_F * i.uv + _Time.x * 2);

                float2 uv_x = i.uv +  offset;
                uv_x.y += 0.1;
                half4 col_x = _SecondTex.Sample(sampler_SecondTex,uv_x);
                col.rgb *= col_x.b *2; // 可以乘二防止过暗


                float2 uv_y = i.uv -  0.8 * offset;
                uv_y.y += 0.1;
                half4 col_y = _SecondTex.Sample(sampler_SecondTex,uv_y);
                col.rgb *= col_y.b ;

                // half4 col = (col_x + col_y) / 2; // 如果是叠加记得除回来
                
                return col;
            }
            ENDHLSL
        }
    }
}
