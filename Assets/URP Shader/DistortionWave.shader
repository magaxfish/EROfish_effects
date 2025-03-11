Shader "Custom/DistortionWave"
{
    Properties
    {
        _MainTex ("Base Texture", 2D) = "white" {} // �D�n�K�ϡ]GrabPass �^�����e���^
        _DistortionTex ("Distortion Texture", 2D) = "black" {} // �ᦱ�i���K��
        _DistortionStrength ("Distortion Strength", Range(0, 0.1)) = 0.02 // �ᦱ�j��
    }

    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" }

        GrabPass { "_GrabTexture" } // �^����e�e��

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _GrabTexture; // Ū���^�����e��
            sampler2D _DistortionTex; // Ū���ᦱ���z
            float _DistortionStrength;

            struct appdata_t
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 grabUV : TEXCOORD1;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata_t v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                
                // �p��e���Ŷ� UV
                #if UNITY_UV_STARTS_AT_TOP
                    o.grabUV = ComputeGrabScreenPos(o.vertex);
                #else
                    o.grabUV = ComputeGrabScreenPos(o.vertex);
                    o.grabUV.y = 1 - o.grabUV.y;
                #endif

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // ���o�i�����z���v�T
                float2 distortion = tex2D(_DistortionTex, i.uv).rg * 2.0 - 1.0;
                distortion *= _DistortionStrength;

                // ���Χᦱ��e���^���K�Ϫ� UV
                float2 grabUV = i.grabUV.xy / i.grabUV.w + distortion;

                // �^���ᦱ�᪺�e��
                fixed4 color = tex2D(_GrabTexture, grabUV);
                return color;
            }
            ENDCG
        }
    }
}
