Shader "Unlit/HLSL_Shader_12"//这是一个和老版本混乱了的废版
{
    properties
    {
        _MainColor("MainColor",color) = (1,1,1,1)
        _SpecularColor("SpecularColor",color) = (1,1,1,1)
        _Metal("Metal",Range(0,32)) = 12
    }
    SubShader
    {
        // Pass
        // {
        //     Tags{"LightMode" = "ShadowCaster"}
        // }
        Pass
        {
            Tags{"LightMode" = "ForwardBase"}//注意光照模式“LightMode”tag和渲染路径“Rendering Path”的设置
            

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwbase

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

                LIGHTING_COORDS(0,1) //使用了一个老版本的对点光源的投影支持的宏定义，本质上获得了后面计算阴影的需要的参数的存储，在后面的宏上面会被用上
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

                TRANSFER_VERTEX_TO_FRAGMENT(o);
               TRANSFER_SHADOW(o);
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
                
                // Shadows PointLight
                float atten = LIGHT_ATTENUATION(i);
                col.rgb *= atten;

                return col ;
            }
            ENDHLSL
        }

//===================================================================================================================================//

        //混合时环境光
        Pass
        {
            Tags{"LightMode" = "ForwardAdd"}//注意光照模式“LightMode”tag和渲染路径“Rendering Path”的设置
            blend one one// 混合

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwadd_fullshadows

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

                LIGHTING_COORDS(0,1) //使用了一个老版本的对点光源的投影支持的宏定义，本质上获得了后面计算阴影的需要的参数的存储，在后面的宏上面会被用上
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

                TRANSFER_VERTEX_TO_FRAGMENT(o);
               
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                // Diffuse
                float3 N = UnityObjectToWorldNormal(i.N);
                float3 L = normalize(UnityWorldSpaceLightDir(i.vertex));
                

                // d = saturate(dot(i.N,i.L));
                float d = saturate(dot(N,L));
                float4 col = _LightColor0 * d * _MainColor;

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
                
                // Shadows PointLight
                float atten = LIGHT_ATTENUATION(i);
                col.rgb *= atten;

                return col ;
            }
            ENDHLSL
        }
    }
}
// 学习路径（由浅入深，建议按顺序来）
// 先把 Unity 内置的 “Lit” 模板吃透
// 打开内置的 UnityStandardCore.cginc，或者下载 Built-in Shaders 源码，逐行看 ForwardBase 的宏是怎么包裹的。用 multi_compile 编译后，在 Frame Debugger 里看每个 Pass 干了什么。

// 动手实现一个“最小完整光照”
// 就写昨天我们一步步纠正的那个：带漫反射、高光、阴影接收、多光源叠加的 Shader。
// 目标不是完美，是跑通整个流程。你会在这个过程中把坐标空间、Pass 逻辑、宏定义彻底弄明白。

// 啃经典光照模型

// Lambert / Blinn-Phong（你已经在做了）

// PBR 核心：Cook-Torrance 的 BRDF（理解 NDF、Fresnel、Geometry 三个项）

// 环境光照：球谐光照、反射探针的原理

// 阴影：Shadow Mapping 的基本原理，PCF 软阴影

// 看图形学大牛的书和演讲

// 《Real-Time Rendering》第4版

// LearnOpenGL.com 的 PBR 章节

// SIGGRAPH 公开课，Advancements in Real-Time Rendering



//  如果我想深入学习光照系统，对渲染有什么收益？应该如何学习？
// 收益
// 排错能力质变：看到物体莫名发黑、多光源错乱、阴影断崖，能一眼定位是 Pass 缺失、Blend 错误、还是矩阵空间不对。

// 自定义风格的可能：可以写出三渲二、皮肤 SSS、毛发光照等不依赖标准 PBR 的效果。

// 性能优化的抓手：知道什么时候该剪变体，什么时候该用烘焙，什么时候可以把逐像素改成逐顶点。

// 跨引擎迁移力：Unity、UE、自研引擎底层光照数学是共通的，学透了一通百通