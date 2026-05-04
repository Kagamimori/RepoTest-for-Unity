Shader "Unlit/HLSL_Shader_14"
{
    properties
    {
        _Scale("Scale",float) = 0.5
        _Outer("Outer",range(0,1)) = 0.2
        
    }
    SubShader
    {
        tags{"queue" = "transparent"}//transparent指透明专属的渲染编号，会在比较晚的时间渲染
        Pass// 扩大加向内衰减
        {
            
            blend srcalpha oneminussrcalpha
            //最终颜色 = SrcAlpha × 当前片段颜色 + (1 - SrcAlpha) × 背景已有颜色
            zwrite off
            ZTest Always

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            
            float _Scale;
            float _Outer;

            struct v2f
            {
                float4 positionCS : SV_POSITION;
                float4 vertex : TEXCOORD0;
                float4 normal : TEXCOORD1;
            };

            v2f vert (appdata_base v)
            {
                v.vertex.xyz += v.normal * _Outer; // 沿法线扩大
                v2f o;
                o.positionCS = UnityObjectToClipPos(v.vertex);
                o.vertex = mul(unity_ObjectToWorld,v.vertex);
                o.normal = mul(unity_ObjectToWorld,v.normal);
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                float3 V = normalize(UnityWorldSpaceViewDir(i.vertex.xyz));
                float3 N = normalize(i.normal.xyz);
                half3 col3 = (1,1,1);
                half4 col4 = half4(1,1,1,1);
                float a =  pow( saturate(dot(V,N)), _Scale);
                //return half4(col,1 * a) ;//在这里，这个a也会影响alpha通道，实际上就形成了“水”的效果
                return col4 * a ;//在这里，这个a也会影响alpha通道，实际上就形成了“水”的效果
            }
            ENDHLSL
        }

        Pass// 减去未扩大的完整图形
        {
            BlendOp RevSub, RevSub
            Blend dstalpha One, dstalpha One

            ZTest Always        // 强制通过深度测试，无论如何都画
   
            zwrite off

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            
            

            struct v2f
            {
                float4 positionCS : SV_POSITION;
                
            };

            v2f vert (appdata_base v)
            {
                
                v2f o;
                o.positionCS = UnityObjectToClipPos(v.vertex);
                
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
               
                half4 col4 = half4(1,1,1,1);
               
                return col4 ;
            }
            ENDHLSL
        }

        Pass
        {
            
            blend srcalpha oneminussrcalpha
            
            zwrite off
            ZTest Always

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            
            float _Scale;
            

            struct v2f
            {
                float4 positionCS : SV_POSITION;
                float4 vertex : TEXCOORD0;
                float4 normal : TEXCOORD1;
            };

            v2f vert (appdata_base v)
            {
                
                v2f o;
                o.positionCS = UnityObjectToClipPos(v.vertex);
                o.vertex = mul(unity_ObjectToWorld,v.vertex);
                o.normal = mul(unity_ObjectToWorld,v.normal);
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                float3 V = normalize(UnityWorldSpaceViewDir(i.vertex.xyz));
                float3 N = normalize(i.normal.xyz);
                half4 col4 = (1,1,1,1);
                float a = 1 - pow( saturate(dot(V,N)), _Scale);
                return col4 * a;
            }
            ENDHLSL
        }//由于多pass叠加的局限性，并不能做到中心的完全透明，但事实上我们可以用纯叠加，并且使用外围顶点和原来顶点的距离来实施衰减
    }
}
// //如果我把法线，视向量的转位放在顶点函数中，然后在片段级函数里计算点积和颜色这些东西，那么出来的效果是片段级的还是顶点级的
// 效果是片段级的（逐像素的）。

// 关键：效果级别由“颜色在哪里算出来”决定，不由“向量在哪里变换”决定
// 你的方案是：

// text
// 顶点着色器：
//   把法线变换到世界空间  →  worldNormal
//   计算世界空间视线方向   →  viewDir

// 片段着色器：
//   插值后的 worldNormal 和 viewDir
//   → normalize → dot → pow → 颜色
// 这里的核心光照计算（dot、pow、最终颜色混合）全部发生在片段着色器。

// 虽然法线和视线在顶点阶段已经变换了空间，但它们在传往片段着色器的过程中经历了重心插值——每个像素拿到的都是该三角形三个顶点值的加权平均，然后片段着色器对插值后的向量进行 normalize 才能真正用于光照。

