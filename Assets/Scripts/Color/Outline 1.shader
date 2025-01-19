Shader "Hidden/GlowWithTexture" {
    Properties {
        _MainTex ("Texture", 2D) = "white" { }
        _GlowColor ("Glow Color", Color) = (1, 1, 1, 1)
        _GlowIntensity ("Glow Intensity", Range(0, 10)) = 2
        [NoScaleOffset] _GlowTex ("Glow Texture", 2D) = "white" { }

        _DistortTex ("Distortion Tex", 2D) = "white" { }
        _DistortAmount ("Distortion Amount", Range(0, 2)) = 2
        _DistortTexXSpeed ("Distort Tex X Speed", Range(-50, 50)) = 0
        _DistortTexYSpeed ("Distort Tex Y Speed", Range(-50, 50)) = -5

        _MainTex2 ("Additional Texture", 2D) = "white" { }
        _MainTex2XSpeed ("MainTex2 X Speed", Range(-50, 50)) = 0
        _MainTex2YSpeed ("MainTex2 Y Speed", Range(-50, 50)) = 0
    }
    SubShader {
        Tags { "Queue" = "Transparent" }
        Blend SrcAlpha OneMinusSrcAlpha

        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            sampler2D _GlowTex;
            fixed4 _GlowColor;
            float _GlowIntensity;

            sampler2D _DistortTex;
            float4 _DistortTex_ST;
            float _DistortTexXSpeed, _DistortTexYSpeed, _DistortAmount;

            sampler2D _MainTex2;
            float _MainTex2XSpeed, _MainTex2YSpeed;

            struct appdata {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                fixed4 color : COLOR;
            };

            struct v2f {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float2 uvOutDistTex : TEXCOORD1;
                fixed4 color : COLOR;
            };

            v2f vert(appdata v) {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.uvOutDistTex = TRANSFORM_TEX(v.uv, _DistortTex);
                o.color = v.color;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target {
                // 基礎火焰效果
                fixed4 col = tex2D(_MainTex, i.uv);

                i.uvOutDistTex.x += (_Time * _DistortTexXSpeed) % 1;
                i.uvOutDistTex.y += (_Time * _DistortTexYSpeed) % 1;
                float outDistortAmnt = (tex2D(_DistortTex, i.uvOutDistTex).r - 0.5) * 0.2 * _DistortAmount;
                float2 destUv = i.uv;
                destUv.x += outDistortAmnt;
                destUv.y += outDistortAmnt;
                float4 noiseCol = tex2D(_DistortTex, destUv);

                fixed4 emission = tex2D(_GlowTex, i.uv);
                emission.rgb *= emission.a * col.a * _GlowIntensity * _GlowColor;
                col.rgb += emission.rgb * noiseCol;

                // 添加額外的紋理效果
                float2 additionalUv = i.uv;
                additionalUv.x += (_Time * _MainTex2XSpeed) % 1;
                additionalUv.y += (_Time * _MainTex2YSpeed) % 1;

                fixed4 additionalTex = tex2D(_MainTex2, additionalUv);

                // 融合效果
                col.rgb = lerp(col.rgb, additionalTex.rgb, additionalTex.a); // 根據透明度進行混合

                return col;
            }
            ENDCG
        }
    }
}
