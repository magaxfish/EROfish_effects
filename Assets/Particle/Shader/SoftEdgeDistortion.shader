Shader "URP/2D/SoftEdgeDistortion"
{
    Properties
    {
        // 可選：主圖(不繪製，可當色調或當成另一層遮罩使用)
        _MainTex ("Main (optional)", 2D) = "white" {}

        // 扭曲噪波/法線圖 (灰階或法線皆可，取RG來偏移)
        _DistortionTex ("Distortion Texture", 2D) = "gray" {}
        _DistortionAmount ("Distortion Amount", Range(0, 2)) = 0.8
        _ScrollSpeedX ("Scroll Speed X", Range(-2, 2)) = 0.1
        _ScrollSpeedY ("Scroll Speed Y", Range(-2, 2)) = 0.0

        // 柔邊遮罩(中心白、邊緣黑；灰階控制透明過渡)
        _MaskTex ("Edge Mask (White=show, Black=hide)", 2D) = "white" {}
        _MaskStrength ("Mask Strength", Range(0, 2)) = 1.0
        _GlobalAlpha ("Global Alpha", Range(0,1)) = 0.6

        //（可選）把扭曲後顏色再微調
        _TintColor ("Tint (optional)", Color) = (1,1,1,1)
    }

    SubShader
    {
        Tags{
            "Queue"="Transparent"
            "RenderType"="Transparent"
            "IgnoreProjector"="True"
            "RenderPipeline"="UniversalPipeline"
        }

        Pass
        {
            Name "SoftEdgeDistortion"
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            Cull Off

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // 需要抓螢幕色
            #pragma multi_compile _ _SCREEN_SPACE_OCCLUSION
            // URP 宏
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            // 宣告屬性
            TEXTURE2D(_MainTex);              SAMPLER(sampler_MainTex);
            float4 _MainTex_ST;

            TEXTURE2D(_DistortionTex);        SAMPLER(sampler_DistortionTex);
            float4 _DistortionTex_ST;
            float  _DistortionAmount;
            float  _ScrollSpeedX;
            float  _ScrollSpeedY;

            TEXTURE2D(_MaskTex);              SAMPLER(sampler_MaskTex);
            float4 _MaskTex_ST;
            float  _MaskStrength;
            float  _GlobalAlpha;
            float4 _TintColor;

            // 由 URP 提供的螢幕顏色(需在 URP Asset 勾選 Opaque Texture)
            TEXTURE2D(_CameraOpaqueTexture);  SAMPLER(sampler_CameraOpaqueTexture);

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv         : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv         : TEXCOORD0;
                float2 uvMask     : TEXCOORD1;
                float2 uvDist     : TEXCOORD2;
                float2 screenUV   : TEXCOORD3;
            };

            // 將 Object 空間轉到裁切空間，並算出螢幕UV(0~1)
            Varyings vert (Attributes v)
            {
                Varyings o;
                o.positionCS = TransformObjectToHClip(v.positionOS.xyz);

                o.uv      = TRANSFORM_TEX(v.uv, _MainTex);
                o.uvMask  = TRANSFORM_TEX(v.uv, _MaskTex);
                o.uvDist  = TRANSFORM_TEX(v.uv, _DistortionTex);

                // 轉成螢幕座標UV
                float2 ndc = o.positionCS.xy / o.positionCS.w;   // -1~1
                float2 uv  = ndc * 0.5f + 0.5f;                  // 0~1
                #if UNITY_UV_STARTS_AT_TOP
                    uv.y = 1.0 - uv.y;
                #endif
                o.screenUV = uv;
                return o;
            }

            float4 frag (Varyings i) : SV_Target
            {
                // 1) 取螢幕顏色
                float4 sceneCol = SAMPLE_TEXTURE2D(_CameraOpaqueTexture, sampler_CameraOpaqueTexture, i.screenUV);

                // 2) 取扭曲貼圖，RG 當偏移向量(-0.5~0.5)，可加捲動
                float2 scroll = float2(_ScrollSpeedX, _ScrollSpeedY) * _Time.y;
                float2 distUV = i.uvDist + scroll;
                float2 dist   = SAMPLE_TEXTURE2D(_DistortionTex, sampler_DistortionTex, distUV).rg;
                dist = (dist * 2.0 - 1.0) * _DistortionAmount;

                // 3) 用偏移後的 UV 重新取樣螢幕顏色
                float2 warpedUV = i.screenUV + dist / _ScreenParams.xy; // 依畫面尺寸做小幅度偏移
                float4 warpedCol = SAMPLE_TEXTURE2D(_CameraOpaqueTexture, sampler_CameraOpaqueTexture, saturated(warpedUV));

                // 4) 邊緣遮罩（中心白、邊緣黑）
                float mask = SAMPLE_TEXTURE2D(_MaskTex, sampler_MaskTex, i.uvMask).a;
                mask = pow(mask, _MaskStrength);

                // 5) 最終混合：把扭曲後的顏色與原場景混合
                //    這樣不會變亮，只是把該區域看起來被折射
                float alpha = saturate(mask * _GlobalAlpha);
                float4 color = lerp(sceneCol, warpedCol, alpha);

                // 可選：再做一點Tint
                color.rgb *= _TintColor.rgb;

                // 輸出
                color.a = max(alpha, 0.0001); // 讓 Blend 有效
                return color;
            }
            ENDHLSL
        }
    }
    FallBack Off
}
