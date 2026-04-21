Shader "Unlit/HLSL_Shader_8"
{
    SubShader
    {
        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
             
                float4 vertex : POSITION;
            };

            struct v2f
            {
                half4 col : TEXCOORD0;
                float4 positionCS : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                // float angle = length(v.vertex) * _SinTime.w;
                // float4x4 m_Rotaion = 
                // {
                //     float4(cos(angle),0,sin(angle),0),
                //     float4(0,1,0,0),
                //     float4(-sin(angle),0,cos(angle),0),
                //     float4(0,0,0,1)
                // };

                //我们已知旋转实际上只改变了vertex的x和z值，那我们完全可以单拎出来简化运算（从方法整体来看，适量简化运算，或者拆开矩阵，是常用的优化方案）
                // float x = cos(angle) * v.vertex.x + sin(angle) * v.vertex.z;
                // float z = -sin(angle) * v.vertex.x + cos(angle) * v.vertex.z;
                // v.vertex.x = x;
                // v.vertex.z = z;

                //注意旋转矩阵是可以先入为主的
                //float4 v2 = mul(m_Rotaion,v.vertex);
                // o.positionCS = UnityObjectToClipPos(v2);

                float angle = v.vertex.z + _Time.y;
                float x_sin = v.vertex.x * (sin(angle)/8 + 0.5f);//随时间缩放x轴上的值
                v.vertex.x = x_sin;
                o.positionCS = UnityObjectToClipPos(v.vertex);

                o.col = float4(0,1,1,1);
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
