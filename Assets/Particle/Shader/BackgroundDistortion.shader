Shader "Custom/BackgroundDistortion"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}    // ⬅️補上這行！！
        _DistortionStrength ("Distortion Strength", Range(0, 0.1)) = 0.02
        _DistortionSpeed ("Distortion Speed", Range(0,5)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        GrabPass { }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float2 grabUV : TEXCOORD1;
            };

            sampler2D _GrabTexture;
            sampler2D _MainTex;   // ⬅️補上這個，SpriteRenderer才能認
            float _DistortionStrength;
            float _DistortionSpeed;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.grabUV = ComputeGrabScreenPos(o.vertex).xy;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 offset = float2(
                    sin(i.uv.y * 30 + _Time.y * _DistortionSpeed),
                    cos(i.uv.x * 30 + _Time.y * _DistortionSpeed)
                ) * _DistortionStrength;

                fixed4 col = tex2D(_GrabTexture, i.grabUV + offset);
                col.a = 1; // 保持不透明
                return col;
            }
            ENDCG
        }
    }
}
