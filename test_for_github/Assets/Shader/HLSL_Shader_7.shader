Shader "Unlit/HLSL_Shader_7"
{
     properties
        {
            _r("r",Range(0,5)) = 1
            _OX("d",Range(-5,5)) = 0
            // _PropertyName ("Inspector显示名称", 类型) = 默认值  (不需要";")(使用的时候也要加_)
        }
    SubShader
    {
       
        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            //include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"//这个是URP的路径
            //关于使用纯HLSL写built_in管线，有时需要注意文件引用和函数区别

            float4x4 mvp;
            float dis;
            float a;
            float _r;//属性命名注意规范
            float _OX;//可以把这一个理解成一个在x轴上的点

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                half4 col : TEXCOORD0;
                //COLOR 语义通常是用于片段着色器输出。顶点着色器向片段着色器传递自定义数据时，规范的做法是使用 TEXCOORDn 语义
                float4 positionCS : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;//注意，此时的坐标是在模型坐标系的语境下的，我们可以把它转化到世界坐标先
                float2 xz = worldPos.xz;
                float d = _r - length(xz - float2(_OX,0));
                d = d < 0 ? 0 : d;//防止负的区域变成负高
                float h = 1;
                float4 upPos = float4(v.vertex.x,h * d,v.vertex.z,v.vertex.w);

                v2f o;

                //顶点变换

                o.positionCS = UnityObjectToClipPos(upPos);// 这里是封装好的,注意此时已经在w分量里储存了深度信息和透视的信息，但是此时还没有归一化
                //o.positionCS = mul(mvp,v.vertex);//分清左右

                // if(v.vertex.x > 0)//基于顶点的颜色处理，需要知道物体的大致顶点范围
                //    o.col = half4(1,0,0,1);
                // else
                //    o.col = half4(0,0,1,1);//中间会有自动的插值计算



                // float4 wPos = mul(unity_ObjectToWorld,v.vertex);

                // if(wPos.x > 0)//基于顶点的颜色处理，需要知道物体的大致顶点范围
                //    o.col = half4(_SinTime.w / 2 + 0.5,0,0,1);//_SinTime 的四个分量分别对应不同频率的正弦波（时间变量）,做出呼吸感
                // else
                //    o.col = half4(0,0,1,1);



                //关于转化为屏幕坐标（模拟到NDC空间）
                float x = o.positionCS.x / o.positionCS.w;
                //if(x <= -1)//根据屏幕坐标来改变颜色
                //if( x > dis && x < dis + a)//密集顶点颜色的处理会比较消耗性能，这里告诉我们可以动态编辑顶点颜色
                //o.col = half4(1,0,0,1);
                // else if(x > 1)
                // o.col = half4(0,0,1,1);
                //else
                //o.col = half4(x/2 + 0.5,x/2 + 0.5,x/2 + 0.5,1);//x不仅可以用于判断，还能直接给颜色赋值

                o.col = half4(upPos.y,upPos.y,upPos.y,1);
                return o;
            }

            half4 frag (v2f i) : SV_TARGET//不要怀疑SV_TARGET，它是正确的，别搞成COLOR了
            {
                
                return i.col;
            }
            ENDHLSL
        }
    }
}
