Shader "Unlit/HLSL_Shader_3"
{
    SubShader
    {
        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Assets/Shader/sbin.hlsl"

            struct attributes{
                float2 objPos:POSITION;

            };

            struct varyings{
                float4 pos:POSITION;
                half4 color:COLOR;

            };

            varyings vert(attributes input){
                varyings output;
                //int i = 0;
                //switch(i)//支持但不建议使用

                output.pos = float4(input.objPos,0,1);//可以嵌套使用，当然损耗也会增加
                float arr[] = {0.4,0.6};
                float a = Func(arr);

                if(output.pos.x < 0 && output.pos.y < 0){
                    output.color = float4(a,0,0,1);
                }
                else if(output.pos.x < 0){
                    output.color = float4(0,1,0,1);
                }
                else if(output.pos.y < 0){
                    output.color = float4(1,1,0,1);
                }
                 else{
                    output.color = float4(0,0,1,1);
                }
           
                return output; 

            }

             half4 frag(varyings input): SV_Target{
                return input.color;


            }
            //关于另外申明的函数，必须要有提前申明或前项申明
            //需要注意的是，HLSL函数传值默认都是值传递，也就是说改变参数只会改变副本
            //如果使用了inout这种，就是引用传递，它变我也变
            //函数也可以传数组 函数里的变量需要初始化


            ENDHLSL
        }
    }
}
//for while if switch都支持 但是最好按规范使用
//如果循环过多，分支过于复杂，就会报错

/*
[unroll] / [loop] —— 必须掌握的高频操作
这是唯一一个如果不写，就极大概率导致编译报错或直接渲染错误的属性。

常规场景：在 Shader 里写 for (int i = 0; i < _LightCount; i++)。
结论：凡是循环次数依赖 uniform 变量或纹理采样次数较多时，
加 [unroll] 或 [loop] 是强制的语法要求，不是可选项。


[flatten] / [branch] —— 可选的中低频优化操作
对于大部分移动端或 PC 端的普通光照 Shader，很多开发者其实不常手动写这两个属性
只有在分析工具（如 RenderDoc、Xcode Metal Debugger）告诉你这里因为线程发散导致瓶颈时
才需要手动加 [flatten] 或 [branch] 来强制纠正编译器。
*/

//一直忘记的东西：结构体分号 结构体前缀 return