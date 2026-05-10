Shader "Unlit/HLSL_Practice_1"
{
    // 测试1.1 实现漫反射、高光反射、逐顶点/逐像素光照	Lambert, Half Lambert, Phong, Blinn-Phong,并带上多光源支持
    
    Properties 
    {
        _MainTex("Texture",2D) = "white"{}
        _DiffuseColor("DiffuseColor",Color) = (0.9,1,0.9,1)
        _DiffuseIntensity("DiffuseIntensity",float) = 1
        _Gloss("Gloss",Range(1, 256)) = 1
        _SpecularCol("SpecularColor",Color) = (1,1,1,1)

        [KeywordEnum(Vertex, Fragment)] _CalcMode("Calc Mode", Float) = 1 
        [KeywordEnum(Lambert, Half, Phong, BlinnPhong)] _LightModel("Light Model", Float) = 0
    }
    
    SubShader
    {
        Pass
        {
            Tags { "LightMode" = "ForwardBase" }
            
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #pragma multi_compile_fwdbase
            #pragma multi_compile _CALCMODE_VERTEX _CALCMODE_FRAGMENT
            #pragma multi_compile _LIGHTMODEL_LAMBERT _LIGHTMODEL_HALF _LIGHTMODEL_PHONG _LIGHTMODEL_BLINNPHONG
            
            #include "UnityCG.cginc"
            #include "Lighting.cginc" 
            #include "AutoLight.cginc" //

            float _LightModel; 
            
            float4 _DiffuseColor;
            float _DiffuseIntensity;

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float _Gloss;
            float4 _SpecularCol;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD1;
                float2 uv : TEXCOORD0;
                float3 worldPos : TEXCOORD2;

                #if defined(_CALCMODE_VERTEX)
                    float3 diffuseLight : TEXCOORD3;
                    float3 specularLight : TEXCOORD4;
                #endif

                SHADOW_COORDS(5)       // 宏：光照衰减坐标
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);

                UNITY_TRANSFER_SHADOW(o, o.uv); 

                #if defined(_CALCMODE_VERTEX)
                    //（半）兰伯特
                    float3 N = normalize(o.worldNormal);
                    float3 L = normalize(_WorldSpaceLightPos0.xyz);

                    float NdotL = saturate(dot(N, L));

                    float dot_Diffuse = 0;
                    #if defined(_LIGHTMODEL_LAMBERT)
                        dot_Diffuse = NdotL;
                    #elif defined(_LIGHTMODEL_HALF)
                        dot_Diffuse = pow((NdotL * 0.5 + 0.5),2);
                    #endif

                    float3 diffuse = _LightColor0.rgb * _DiffuseColor.rgb * dot_Diffuse * _DiffuseIntensity;


                    // 高光（Phong/Blinn-Phong）
                    float3 V = normalize(UnityWorldSpaceViewDir(o.worldPos));

                    float3 specular = float3(0,0,0); // 高光结果
                    #if defined(_LIGHTMODEL_PHONG) || defined(_LIGHTMODEL_BLINNPHONG)
                        float dot_Spec = 0;
                        #if defined(_LIGHTMODEL_PHONG)
                            float3 R = reflect(-L,N);
                            float RdotV = saturate(dot(R,V));
                            dot_Spec = RdotV;
                        #elif defined(_LIGHTMODEL_BLINNPHONG)
                            float3 H = normalize(L+V);
                            float NdotH = saturate(dot(N,H));          
                            dot_Spec = NdotH;
                        #endif

                        float spec = pow(dot_Spec,_Gloss) * NdotL;
                        specular = _LightColor0.rgb * spec * _SpecularCol.rgb;
                    #endif
                    
                    // 删除了冗余的 spec/specular 计算，已包含在上述 if 块内

                    float3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;
                    o.diffuseLight = diffuse + ambient;
                    o.specularLight = specular;
                #endif

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 texColor = tex2D(_MainTex, i.uv);

                #if defined(_CALCMODE_VERTEX)
                    UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
                    float3 finalCol = (texColor.rgb * i.diffuseLight + i.specularLight) * atten;
                    return fixed4(finalCol, texColor.a);
                #elif defined(_CALCMODE_FRAGMENT)
                    float3 N = normalize(i.worldNormal);
                    float3 L = normalize(UnityWorldSpaceLightDir(i.worldPos)); // 宏：自动处理方向光/点光源/聚光灯的光线方向

                    float NdotL = saturate(dot(N, L));

                    float dot_Diffuse = NdotL; // 默认为 Lambert
                    #if defined(_LIGHTMODEL_LAMBERT)
                        // dot_Diffuse 已赋值
                    #elif defined(_LIGHTMODEL_HALF)
                        dot_Diffuse = pow((NdotL * 0.5 + 0.5),2);
                    #endif

                    float3 diffuse = _LightColor0.rgb * _DiffuseColor.rgb * dot_Diffuse * _DiffuseIntensity;


                    // 高光（Phong/Blinn-Phong）
                    float3 V = normalize(UnityWorldSpaceViewDir(i.worldPos));

                    float3 specular = float3(0,0,0); // 高光结果
                    #if defined(_LIGHTMODEL_PHONG) || defined(_LIGHTMODEL_BLINNPHONG)
                        float dot_Spec = 0;
                        #if defined(_LIGHTMODEL_PHONG)
                            float3 R = reflect(-L,N);
                            float RdotV = saturate(dot(R,V));
                            dot_Spec = RdotV;
                        #elif defined(_LIGHTMODEL_BLINNPHONG)
                            float3 H = normalize(L+V);
                            float NdotH = saturate(dot(N,H));          
                            dot_Spec = NdotH;
                        #endif

                        float spec = pow(dot_Spec,_Gloss) * NdotL;
                        specular = _LightColor0.rgb * spec * _SpecularCol.rgb; 
                    #endif

                    float3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;
                   
                    // 宏：光照衰减（自动处理点光源距离衰减/聚光灯角度衰减）
                    UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos); // 只保留一次调用

                    float3 finalCol = (texColor.rgb * (diffuse + ambient) + specular) * atten;

                    return fixed4(finalCol, texColor.a);
                #endif
            }
            ENDHLSL
        }


        Pass
        {
            Tags { "LightMode" = "ForwardAdd" }     
            Blend One One //        
            ZTest LEqual // z等于的时候也可以通过                   
            
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile _LIGHTMODEL_LAMBERT _LIGHTMODEL_HALF _LIGHTMODEL_PHONG _LIGHTMODEL_BLINNPHONG
            #pragma multi_compile _CALCMODE_VERTEX _CALCMODE_FRAGMENT
            #pragma multi_compile_fwdadd_fullshadows // 多光源变体
            
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc" // 用于光照衰减

            float4 _DiffuseColor;
            float _DiffuseIntensity;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Gloss;
            float4 _SpecularCol;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD1;
                float2 uv : TEXCOORD0;
                float3 worldPos : TEXCOORD2;

                #if defined(_CALCMODE_VERTEX)
                    float3 diffuseLight : TEXCOORD3;
                    float3 specularLight : TEXCOORD4;
                #endif

                SHADOW_COORDS(5)       // 宏：光照衰减坐标
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);

                UNITY_TRANSFER_SHADOW(o, o.uv); // 改用 UNITY_TRANSFER_SHADOW 并传入 o.uv

                #if defined(_CALCMODE_VERTEX)
                    //（半）兰伯特
                    float3 N = normalize(o.worldNormal); 
                    float3 L = normalize(UnityWorldSpaceLightDir(o.worldPos)); 

                    float NdotL = saturate(dot(N, L));

                    float dot_Diffuse = NdotL;
                    #if defined(_LIGHTMODEL_LAMBERT)
                        // dot_Diffuse 已赋值
                    #elif defined(_LIGHTMODEL_HALF)
                        dot_Diffuse = pow((NdotL * 0.5 + 0.5),2);
                    #endif

                    float3 diffuse = _LightColor0.rgb * _DiffuseColor.rgb * dot_Diffuse * _DiffuseIntensity;


                    // 高光（Phong/Blinn-Phong）
                    float3 V = normalize(UnityWorldSpaceViewDir(o.worldPos));

                    float3 specular = float3(0,0,0);
                    #if defined(_LIGHTMODEL_PHONG) || defined(_LIGHTMODEL_BLINNPHONG)
                        float dot_Spec = 0;
                        #if defined(_LIGHTMODEL_PHONG)
                            float3 R = reflect(-L,N);
                            float RdotV = saturate(dot(R,V));
                            dot_Spec = RdotV;
                        #elif defined(_LIGHTMODEL_BLINNPHONG)
                            float3 H = normalize(L+V);
                            float NdotH = saturate(dot(N,H));          
                            dot_Spec = NdotH;
                        #endif

                        float spec = pow(dot_Spec,_Gloss) * NdotL;
                        specular = _LightColor0.rgb * spec * _SpecularCol.rgb; 
                    #endif
                    o.diffuseLight = diffuse; 
                    o.specularLight = specular;
                #endif

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 texColor = tex2D(_MainTex, i.uv);

                #if defined(_CALCMODE_VERTEX)
                    UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
                    float3 finalCol = (texColor.rgb * i.diffuseLight + i.specularLight) * atten;
                    return fixed4(finalCol, 0);
                #elif defined(_CALCMODE_FRAGMENT)
                    float3 N = normalize(i.worldNormal);
                    float3 L = normalize(UnityWorldSpaceLightDir(i.worldPos)); // 宏：自动处理方向光/点光源/聚光灯的光线方向

                    float NdotL = saturate(dot(N, L));

                    float dot_Diffuse = NdotL;
                    #if defined(_LIGHTMODEL_LAMBERT)
                        // 已赋值
                    #elif defined(_LIGHTMODEL_HALF)
                        dot_Diffuse = pow((NdotL * 0.5 + 0.5),2);
                    #endif

                    float3 diffuse = _LightColor0.rgb * _DiffuseColor.rgb * dot_Diffuse * _DiffuseIntensity;


                    // 高光（Phong/Blinn-Phong）
                    float3 V = normalize(UnityWorldSpaceViewDir(i.worldPos));

                    float3 specular = float3(0,0,0);
                    #if defined(_LIGHTMODEL_PHONG) || defined(_LIGHTMODEL_BLINNPHONG)
                        float dot_Spec = 0;
                        #if defined(_LIGHTMODEL_PHONG)
                            float3 R = reflect(-L,N);
                            float RdotV = saturate(dot(R,V));
                            dot_Spec = RdotV;
                        #elif defined(_LIGHTMODEL_BLINNPHONG)
                            float3 H = normalize(L+V);
                            float NdotH = saturate(dot(N,H));          
                            dot_Spec = NdotH;
                        #endif

                        float spec = pow(dot_Spec,_Gloss) * NdotL;
                        specular = _LightColor0.rgb * spec * _SpecularCol.rgb;
                    #endif

                    // 宏：光照衰减（自动处理点光源距离衰减/聚光灯角度衰减）
                    UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos); // 只调用一次，避免 lightCoord 重定义

                    float3 finalCol = (texColor.rgb * diffuse + specular) * atten; // 不叠加 ambient

                    return fixed4(finalCol, 0); // blend只加数据，不要重复加alpha
                #endif
            }
            ENDHLSL
        }
    }
}