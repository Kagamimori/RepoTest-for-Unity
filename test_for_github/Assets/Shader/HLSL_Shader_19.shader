Shader "Unlit/HLSL_Shader_19"
{
    properties
    {
        _MainCol("MainCol",color) = (1,1,1,1)
        
    }
    SubShader
    {
        tags{"queue" = "transparent"}
        
        Pass
        {
            zwrite on
            ztest less

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            half4 _MainCol;

            struct v2f
            {
                float4 positionCS : SV_POSITION;
                float4 vertex : TEXCOORD0;
            };

            v2f vert (appdata_base v)
            {
                v2f o;
                o.positionCS = UnityObjectToClipPos(v.vertex);
                
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                half4 col = half4(_MainCol.rgb,1);
                return col;
            }
            ENDHLSL
        }
        Pass
        {
            blend srcalpha oneminussrcalpha
            
            zwrite on // 让自己先不写入
            ztest greater

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            half4 _MainCol;

            struct v2f
            {
                float4 positionCS : SV_POSITION;
                float4 vertex : TEXCOORD0;
               
            };

            v2f vert (appdata_base v)
            {
                
                v2f o;
                o.positionCS = UnityObjectToClipPos(v.vertex);
                
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                half4 col = half4(_MainCol.rgb,0.6);
                return col;
            }
            ENDHLSL
        }
    }
}
// 推荐使用方案2（Stencil Buffer），它能实现这样的效果：

// 第一个物体正常半透明渲染

// 第二个物体被第一个遮挡的部分以更透明的效果显示

// 保持正确的深度关系和渲染顺序