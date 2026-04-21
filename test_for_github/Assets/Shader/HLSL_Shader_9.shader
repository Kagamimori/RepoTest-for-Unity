Shader "Unlit/HLSL_Shader_9"
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
                //横波叠加
                 v.vertex.y += 0.2 * sin(v.vertex.x *v.vertex.z + _Time.y);
                 v.vertex.y += 0.2 * sin(v.vertex.x -v.vertex.z + _Time.y);
                 v.vertex.y += 0.2 * sin(v.vertex.x +v.vertex.z + _Time.y);
                 
                //圆形波
                //v.vertex.y += 0.1 * sin(-length(v.vertex.xz) * 2 + _Time.w);//记得取反
                o.positionCS = UnityObjectToClipPos(v.vertex);

                o.col = float4(v.vertex.y,0.9,1,1);
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
