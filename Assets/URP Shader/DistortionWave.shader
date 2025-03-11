Shader "Custom/DistortionWave"
{
    Properties
    {
        _MainTex ("Base Texture", 2D) = "white" {} // 主要貼圖（GrabPass 擷取的畫面）
        _DistortionTex ("Distortion Texture", 2D) = "black" {} // 扭曲波紋貼圖
        _DistortionStrength ("Distortion Strength", Range(0, 0.1)) = 0.02 // 扭曲強度
    }

    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" }

        GrabPass { "_GrabTexture" } // 擷取當前畫面

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _GrabTexture; // 讀取擷取的畫面
            sampler2D _DistortionTex; // 讀取扭曲紋理
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
                
                // 計算畫面空間 UV
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
                // 取得波紋紋理的影響
                float2 distortion = tex2D(_DistortionTex, i.uv).rg * 2.0 - 1.0;
                distortion *= _DistortionStrength;

                // 應用扭曲到畫面擷取貼圖的 UV
                float2 grabUV = i.grabUV.xy / i.grabUV.w + distortion;

                // 擷取扭曲後的畫面
                fixed4 color = tex2D(_GrabTexture, grabUV);
                return color;
            }
            ENDCG
        }
    }
}
