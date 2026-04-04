Shader "Unlit/HLSL_Shader_1"//�ļ�����+�ļ���
{
    SubShader//���㣬Ƭ��shader����Ҫ��һ��Pass
    {
        Pass{
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            //���������������ɫ�����Ͷ�Ҫ��д

            //��CG��ͬ����HLSL�������ݲ���ʹ��in out��һ��ʹ�ýṹ�崫������
            struct attributes//����ṹ��
            {
                //float3 positionOS : POSITION;//����ģ�Ϳռ�λ��//�����ǿ����Զ���ģ�������һ������ͨ��//һ����˵position������ά����
                float2 uv : TEXCOORD0;//��0��uv����
                float3 normal : NORMAL;//����
                
                float4 col : COLOR0;
                float2 objPos : POSITION;
            };

            struct varyings//��������ṹ��
            {
                float4 positionCS : SV_POSITION;//�������ƬԪ��дҲ���ᱻ����
                float2 uv : TEXCOORD0;
                float3 normalWS : TEXCOORD1;//����ռ䷨��
                
                float4 color : COLOR0;
            };
            //�������岻ͬ��ͬ���͵Ĳ���Ҳ�ɻ���������԰�һ����ά����posֱ�Ӹ�����ɫ
            varyings vert(attribute input)//Ҫ����λ��
            {
                varyings output;//����ƬԪshader
                

                output.uv = input.uv;
                output.normalWS = TransformObjectToWorldNormal(input.normal);

                output.positionCS = float4(input.objPos,0,1);
                output.color = float4(0,1,0,1);
                return output;  
            }
            float4 frag(varyings input) : SV_Target//Ҫ������ɫ//������壬���Ǹ���GPU�������Ҫ��������
            {
                retrun float4(0,0,1,1);
            }


            ENDHLSL
        }
        //关于注释的问题：以后一定要统一中文格式，如果打开时中文是乱码，千万不要保存
        //即使是写注释，也要commit
        
        }
    }

