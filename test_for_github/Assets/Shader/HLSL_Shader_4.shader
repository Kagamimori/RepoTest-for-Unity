Shader "Unlit/HLSL_Shader_4"//函数
{
    
    SubShader
    {

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
           
            struct attributes
            {
                float4 vertex :POSITION;
                
            };

            struct varyings
            {
                float4 pos: SV_POSITION;
                half4 color:COLOR;
                
            };
            
            varyings vert (attributes input)
            {
                varyings output;
                output.pos = UnityObjectToClipPos(input.vertex);

                return output;
            }

            half4 frag (varyings input) : SV_Target
            { 
                
                return half4(0,0,0,1);
            }
            ENDHLSL
        }
    }
}
//函数包含 数学函数 几何函数 纹理函数 导数函数
/*
* 数学与通用计算
涵盖基础运算、幂指对、取整与范围限制等。常用的包括：绝对值 abs、幂运算 pow、指数 exp/exp2、对数 log/log2、向上/下取整 ceil/floor、四舍五入 round、取小数部分 frac、限制范围 clamp、钳制到0-1 saturate、线性插值 lerp、符号判断 sign、求较大/小值 max/min 等 。

三角函数
全部以弧度制计算。基础的有 sin、cos、tan，以及对应的反三角函数 asin、acos、atan。此外还有 sincos 可同时获得正弦和余弦值 。

向量与矩阵运算
这是3D图形学中最重要的部分。关键函数有：点乘 dot、叉乘 cross、向量长度 length、归一化 normalize、距离 distance、反射 reflect、折射 refract，以及矩阵乘法 mul 和转置 transpose 。

纹理采样
用于从纹理中读取颜色数据。按纹理维度分为 tex1D、tex2D、tex3D 和立方体贴图 texCUBE 系列。每个系列下还有带偏差 (bias)、梯度 (grad)、指定LOD (lod) 或投影 (proj) 的变体，功能非常灵活 。

偏导数（仅像素着色器）
用于获取某个变量在屏幕空间像素间的变化率，是实现纹理过滤、边缘检测等高级效果的基础。主要函数有 ddx（水平变化率）和 ddy（垂直变化率）。

逻辑与判断
all 检查所有分量是否非零，any 检查是否有分量非零，isfinite/isinf/isnan 判断浮点数的数值类型。clip 函数比较特殊，如果参数小于0则直接丢弃当前像素，常用于Alpha裁剪 。

原子操作与内存屏障
主要用于计算着色器（Compute Shader），保证多线程并行操作同一块内存时的数据安全。例如原子加法 InterlockedAdd 和各种内存屏障 AllMemoryBarrier、GroupMemoryBarrier 。
*/