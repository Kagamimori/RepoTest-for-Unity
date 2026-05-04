Shader "Unlit/HLSL_Shader_15"
{
    Properties
    {
        _MainColor ("Main Color", Color) = (1,0,0,1)
        _SecondColor ("Second Color", Color) = (0,0,1,1)
        _Center ("Center",Range(-0.51 , 0.51)) = 0.2
        _Fill ("Fill",Range(0,0.1)) = 0
    }

    SubShader
    {
        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            half4 _MainColor;
            half4 _SecondColor;
            float _Center;
            float _Fill;

            struct v2f
            {
                float4 pos : SV_POSITION;
                float ColorGap : TEXCOORD0;
            };

            v2f vert (appdata_base v)
            {
                v2f o;
               
                o.pos = UnityObjectToClipPos(v.vertex);
                
                o.ColorGap = v.vertex.y;// 在这里GPU会自动给不同的ColorGap插值赋值，达到精确的效果

                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                // if(i.ColorGap <= _Center)
                // {
                //     float a = (i.ColorGap - _Center- _Fill) / 0.1;
                //     if(i.ColorGap <= _Center-_Fill)
                //     return float4( _MainColor);
                //     else
                //     return float4((a * _MainColor.xyz + (1-a) * _SecondColor.xyz),1);

                // }
                // if(i.ColorGap > _Center)
                // {
                //     float b = (i.ColorGap - _Center + _Fill) / 0.1;
                //     if(i.ColorGap > _Center- _Fill)
                //     return float4( _SecondColor);
                //     else
                //     return float4(((1-b) * _MainColor.xyz + b * _SecondColor.xyz),1);

                // }

                // 事实上可以使用非判断的方式直接给值，详情见笔记本

                return float4(1,1,1,1);
            }
            ENDHLSL
        }
    }
}