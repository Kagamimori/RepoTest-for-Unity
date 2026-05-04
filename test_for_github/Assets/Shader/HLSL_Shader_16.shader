// Upgrade NOTE: replaced tex2D unity_Lightmap with UNITY_SAMPLE_TEX2D

Shader "Unlit/HLSL_Shader_16"
{
    properties
    {
        _MainTex("MainTex",2D) = ""{}
        
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
      
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "UnityLightingCommon.cginc"  // 如果有用到其他光照变量

            
            // float x1;
            // float y1;
            // float x2;
            // float y2;

            sampler2D _MainTex;

          
            float4 _MainTex_ST; // 自动挡

            float4 _unity_LightmapST;

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float2 LightUV : TEXCOORD1;
            };

            v2f vert (appdata_full v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                
                // o.uv = v.texcoord.xy; // 手动写法
                
                // o.uv.x *= x1;
                // o.uv.y *= y1;
                // o.uv.x += x2;
                // o.uv.y += y2;

                // o.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.wz;

                o.uv = TRANSFORM_TEX(v.texcoord,_MainTex); // 直接应用平铺和平移

                o.LightUV = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.wz; // 光照不行,v.texcoord1.xy需要用光照贴图专属的数据
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                half4 lmTex = UNITY_SAMPLE_TEX2D(unity_Lightmap, i.LightUV);  // 先采样
                half3 lm = DecodeLightmap(lmTex);                    // 再解码
                half4 col = tex2D(_MainTex,i.uv);
                col.xyz *= lm * 2;
                return col;
            }
            ENDCG
        }
    }
}
