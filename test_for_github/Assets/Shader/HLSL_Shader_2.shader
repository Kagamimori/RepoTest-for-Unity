Shader "Unlit/HLSL_Shader_2"
{
    SubShader{
        Pass{
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define AAA float4(0,1,0,1);//定义的宏定义可以直接在下面代用

            //typedef float4 color;//类型可以自定义

            struct attributes{
                float2 objPos:POSITION;
            };

            struct varyings{
                float4 positionCS : SV_POSITION; //顶点位置
                float4 color:COLOR;
            };

            varyings vert (attributes input){
                varyings output;
                output.positionCS = float4(input.objPos,0,1);//在图形学里，一切都是数据

                return output;
            }

            float4 frag (varyings input) : SV_Target {
                varyings output;

                float r = 1;
                float g = 0;
                float b = 0;
                float a = 1;
                //fixed已经half取代，都是指低精度，经常用于颜色（fixed是8+1的字节，实际上三维的rgb已经足够形成色板）
                //profile是指这个语言的功能标准，与功能和设备兼容有关
                input.color = float4 (r,g,b,a);
                bool bl = false;
                output.color = bl? input.color : float4(0,1,0,1);//三目的使用示例

                float2 fl2 = float2(1,1);
                float4 fl = float4 (fl2.yx,0,1);
                //这里使用了swizzle操作，灵活控制数据,xyzw,rgba
                output.color = fl;

                //关于矩阵
                float2x4 M2x4 = {fl,
                                 {1,1,1,1}};
                output.color = M2x4[1];//这里指使用第二行

                //关于数组
                float arr[4] = {1,0.5,0.5,1};
                output.color = float4(arr[0],arr[1],arr[2],arr[3]);

                return output.color;

            }

            ENDHLSL
        }
    }
    
}
