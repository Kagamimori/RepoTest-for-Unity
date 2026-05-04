Shader "Custom/Surface_Shader_1"
{
    Properties
    {
        _MainColor ("Main Color", Color) = (1,0,0,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0

    
        _SecondColor ("Second Color", Color) = (0,0,1,1)
        _Center ("Center",Range(-0.6 , 0.6)) = 0.2
        _Fill ("Fill",Range(0,0.15)) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows vertex:vert

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
            float x;
        };

        half _Glossiness;
        half _Metallic;
        half4 _MainColor;
        half4 _SecondColor;
        float _Center;
        float _Fill;


        void vert (inout appdata_full v,out Input o)
        {
           UNITY_INITIALIZE_OUTPUT(Input, o);
            o.x = v.vertex.x;
        }

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex);
            o.Albedo = c.rgb; // 在这里基础色就好了
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;

            float a = IN.x - _Center;
            float b = abs(a);
            float c1 = a/b; // 上还是下

            float d = saturate(b / _Fill); // 占了多少

            float e = c1 * d; // 与方向有关的,占了多少
            float f = (e + 1) / 2;//管一下范围

            o.Albedo *= lerp(_MainColor,_SecondColor,f);
        }
        ENDCG
    }
    FallBack "Diffuse"
}
