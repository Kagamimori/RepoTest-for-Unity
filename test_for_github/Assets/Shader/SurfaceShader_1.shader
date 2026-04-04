Shader "Custom/NewSurfaceShader"
{
    Properties//在面板中显示
    {
        _Color ("Color", Color) = (1,1,1,1)//名字在引号里
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5//指高光
        _Metallic ("Metallic", Range(0,1)) = 0.0
    }
    SubShader//SubShader可以写多几个，如果第一个不适配，就可以运行写一个，都不行就执行fallback（surface shader没有pass通道）
    {
        Tags { "RenderType"="Opaque" "queue"="transparent" }//不透明以及，指定渲染序列
        LOD 200
        
        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows alpha//这是表面着色器的特征，包括函数名称，光照模型和其他设置,这里的各种设置来自于配置文件

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;//2d纹理变量

        struct Input
        {
            float2 uv_MainTex;//uv是必须加的，后面也是对应了一个属性（这里的变量类型要结合图形学算法理解）
        };

        half _Glossiness;//浮点值
        half _Metallic;
        fixed4 _Color;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)//两个参数，都是结构体，后面的那个可以在配置文件中寻找到使用的方法
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;//获取纹理，并在现在文件里复制
            o.Albedo = c.rgb;
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
