Shader "Unlit/HLSL_Shader_6"
{
    SubShader
    {
        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            //include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
            //关于使用纯HLSL写built_in管线，有时需要注意文件引用和函数区别

            float4x4 mvp;

            struct appdata
            {
             
                float4 vertex : POSITION;
            };

            struct v2f
            {
                
                float4 positionCS : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                //o.positionCS = UnityObjectToClipPos(v.vertex);// 这里是封装好的
                o.positionCS = mul(mvp,v.vertex);//分清左右
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                
                return half4(1,1,1,1);
            }
            ENDHLSL
        }
    }
}
