Shader "Unlit/HLSL_Shader_11"
{
    properties
    {
        _MainColor("MainColor",color) = (1,1,1,1)
        _SpecularColor("SpecularColor",color) = (1,1,1,1)
        _Metal("Metal",Range(0,32)) = 12
    }
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
            #include "AutoLight.cginc"  

            
            half4 _MainColor;
            half4 _SpecularColor;
            float _Metal;

            struct v2f
            {
                half4 col : TEXCOORD0;
                float4 positionCS : SV_POSITION;
                float3 N : TEXCOORD1;
                //float3 V : TEXCOORD2;
                float4 vertex : TEXCOORD2;
                float4 WorldPos : TEXCOORD3;
            };

            v2f vert (appdata_base v)//使用自带的传入数据，自带法线信息
            {
                v2f o;
            
                o.positionCS = UnityObjectToClipPos(v.vertex);
                
                //漫反射光
                //o.N = UnityObjectToWorldNormal(v.normal);
                //o.V = normalize(_WorldSpaceLightPos0); // 局限版本

                o.N = v.normal;
                o.vertex = v.vertex;//这个传过去之后就是裁剪空间的顶点坐标

                o.WorldPos = mul(unity_ObjectToWorld,v.vertex);
               
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                // Diffuse
                float3 N = UnityObjectToWorldNormal(i.N);
                float3 L = normalize(UnityWorldSpaceLightDir(i.vertex));
                float4 col = UNITY_LIGHTMODEL_AMBIENT;

                // d = saturate(dot(i.N,i.L));
                float d = saturate(dot(N,L));
                col += _LightColor0 * d * _MainColor;

                // Specular
                float3 view = normalize(UnityWorldSpaceViewDir(i.vertex));
                float3 R = dot(L,N) * 2 * N - L;

                col += _SpecularColor * pow(saturate(dot(R,view)),_Metal);

                // Point Light
                float3 Wpos = mul(unity_ObjectToWorld,i.WorldPos.xyz);
                col.rgb += Shade4PointLights(unity_4LightPosX0,unity_4LightPosY0,unity_4LightPosZ0,
                unity_LightColor[0].rgb,unity_LightColor[1].rgb,unity_LightColor[2].rgb,unity_LightColor[3].rgb,
                unity_4LightAtten0,
                Wpos,N);
                
                return col ;
            }
            ENDHLSL
        }
    }
}
