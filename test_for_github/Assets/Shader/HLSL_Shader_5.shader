Shader "Unlit/HLSL_Shader_5"
{
     properties//属性的使用
    {
        _MainColor("Main Color",color) = (1,1,1,1)
    }
    SubShader
    {
        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"
            #include "Assets/Shader/sbin.hlsl"

            //结构体可以复制到别个文件里再引用
            half4 _MainColor;//属性使用
            float4 _SecondColor;//用uniform脚本关联，是来自cpu的外部数据，但是现在可以省略uniform
            
            //语义输出不能有重复
            
            struct v2f
            {
                half4 col :COLOR;//
                float4 pos : SV_POSITION; 
            };

           

            v2f vert (appdata v)//我们也可以使用官方提供的结构体
            {
                v2f o;
                o.pos = float4(v.objPos,0,1);
                o.col = v.color;
                return o;
            }

            half4 frag (v2f i) : SV_Target//后面讲了：返回值需要在这个位置加语义
            {
                // float arr[] = {0.1,0.9};
                // i.col.y = Func(arr);

                //return i.col;
                return _MainColor * _SecondColor;// 混合颜色
            }
            ENDHLSL
        }
    }
}
