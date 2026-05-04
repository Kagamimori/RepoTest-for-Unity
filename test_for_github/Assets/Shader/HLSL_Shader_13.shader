Shader "Unlit/HLSL_Shader_13"
{
    Properties
    {
        _MainColor ("Main Color", Color) = (1,1,1,1)
        _SpecularColor ("Specular Color", Color) = (1,1,1,1)
        _Metal ("Gloss", Range(1, 256)) = 32
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        // ============ 主光照通道：方向光 + 阴影 + 前4个点光 ============
        Pass
        {
            Tags { "LightMode" = "ForwardBase" }
            Blend One Zero

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            half4 _MainColor;
            half4 _SpecularColor;
            half _Metal;

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldPos    : TEXCOORD1;
                SHADOW_COORDS(2)
            };

            v2f vert (appdata_base v)
            {
                v2f o;
                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = worldPos;
                TRANSFER_SHADOW(o);//注意文档里面用的是a，说明用的是结构体
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                float3 N = normalize(i.worldNormal);
                float3 L = normalize(_WorldSpaceLightPos0.xyz);
                float3 V = normalize(_WorldSpaceCameraPos - i.worldPos);

                UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);//计算了衰减

                half NdotL = saturate(dot(N, L));
                half4 diffuse = _LightColor0 * _MainColor * NdotL * atten;

                float3 R = reflect(-L, N);
                half RdotV = saturate(dot(R, V));
                half4 specular = _LightColor0 * _SpecularColor * pow(RdotV, _Metal) * atten;

                half4 ambient = UNITY_LIGHTMODEL_AMBIENT;

                half4 pointLightContrib = half4(0,0,0,0);
                #ifdef VERTEXLIGHT_ON
                pointLightContrib.rgb = Shade4PointLights(
                    unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
                    unity_LightColor[0].rgb, unity_LightColor[1].rgb,
                    unity_LightColor[2].rgb, unity_LightColor[3].rgb,
                    unity_4LightAtten0,
                    i.worldPos, N
                );
                #endif

                half4 col = ambient + diffuse + specular + pointLightContrib;
                return col;
            }
            ENDHLSL
        }

        // ============ 额外像素光源通道（含阴影）============
        Pass
        {
            Tags { "LightMode" = "ForwardAdd" }
            Blend One One

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // 改用 fwdadd_fullshadows 以支持点光源/聚光灯阴影
            #pragma multi_compile_fwdadd_fullshadows

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            half4 _MainColor;
            half4 _SpecularColor;
            half _Metal;

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldPos    : TEXCOORD1;
                SHADOW_COORDS(2)
            };

            v2f vert (appdata_base v)
            {
                v2f o;
                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = worldPos;
                TRANSFER_SHADOW(o);
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                float3 N = normalize(i.worldNormal);
                float3 L = normalize(_WorldSpaceLightPos0.xyz - i.worldPos * _WorldSpaceLightPos0.w);
                float3 V = normalize(_WorldSpaceCameraPos - i.worldPos);

                UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);

                half NdotL = saturate(dot(N, L));
                half4 diffuse = _LightColor0 * _MainColor * NdotL * atten;

                float3 R = reflect(-L, N);
                half RdotV = saturate(dot(R, V));
                half4 specular = _LightColor0 * _SpecularColor * pow(RdotV, _Metal) * atten;

                return diffuse + specular;
            }
            ENDHLSL
        }

        // 阴影投射
        UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"
    }
}