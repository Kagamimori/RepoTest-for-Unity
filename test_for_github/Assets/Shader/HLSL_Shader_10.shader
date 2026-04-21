Shader "Unlit/HLSL_Shader_10"
{
    SubShader
    {
        
        Pass
        {
            Tags{"LightMode" = "ForwardBase"}//注意光照模式“LightMode”tag和渲染路径“Rendering Path”的设置

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            

            struct v2f
            {
                half4 col : TEXCOORD0;
                float4 positionCS : SV_POSITION;
            };

            v2f vert (appdata_base v)//使用自带的传入数据，自带法线信息
            {
                v2f o;
            
                o.positionCS = UnityObjectToClipPos(v.vertex);
                float3 normalWS = normalize(mul(v.normal, (float3x3)unity_WorldToObject));//可以用3x3因为法线是向量，它的[4，4]是0
                //把法线也要换到世界坐标系

                float3 N = normalWS;
                float3 L = normalize(_WorldSpaceLightPos0);

                float d = saturate(dot(N,L));//注意小写

                o.col = _LightColor0 * d;
                //目前的方法只能使用平行光，当我们研究点光时，可以看看不同光照路径里面的内置方法
                float3 Wpos = mul(unity_ObjectToWorld,v.vertex.xyz);
                o.col.rgb += Shade4PointLights(unity_4LightPosX0,unity_4LightPosY0,unity_4LightPosZ0,
                unity_LightColor[0].rgb,unity_LightColor[1].rgb,unity_LightColor[2].rgb,unity_LightColor[3].rgb,
                unity_4LightAtten0,
                Wpos,N);
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                
                return i.col;
            }
            ENDHLSL
        }
    }
}
