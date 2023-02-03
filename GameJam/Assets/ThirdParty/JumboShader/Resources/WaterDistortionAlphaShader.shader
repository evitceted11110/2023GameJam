// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Jumbo/Effect/WaterDistortionAlpha" {
    Properties {
        _MainTex ("Main texture", 2D) = "white" {}
        _NoiseTex ("Noise texture", 2D) = "grey" {}
        _Mitigation ("Distortion mitigation", Range(1, 30)) = 1
        _SpeedX("Speed along X", Range(0, 5)) = 1
        _SpeedY("Speed along Y", Range(0, 5)) = 1
    }
 
    SubShader {
        Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha
        LOD 100
 
        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
 
            sampler2D _MainTex;
            sampler2D _NoiseTex;
            float _SpeedX;
            float _SpeedY;
            float _Mitigation;
			
			struct appdata {
				float4 vertex : POSITION;
				fixed4 color : COLOR;
				float2 uv : TEXCOORD0;
			}; 

            struct v2f {
                half4 pos : SV_POSITION;
                half2 uv : TEXCOORD0;
				fixed4 color : COLOR;
            };
 
            fixed4 _MainTex_ST;
 
            v2f vert(appdata v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.color = v.color;
                return o;
            }
 
            half4 frag(v2f i) : COLOR {
                half2 uv = i.uv;
                half noiseVal = tex2D(_NoiseTex, uv).r;
                uv.x = uv.x + noiseVal * sin(_Time.y * _SpeedX) / _Mitigation;
                uv.y = uv.y + noiseVal * sin(_Time.y * _SpeedY) / _Mitigation;
                return tex2D(_MainTex, uv) * i.color;
            }
 
            ENDCG
        }
    }
    FallBack "Diffuse"
}