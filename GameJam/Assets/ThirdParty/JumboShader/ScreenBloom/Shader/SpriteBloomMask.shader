﻿Shader "Yile/SpriteBloomMask" {
	Properties{
		_MainTex("MainTex", 2D) = "white" {}
		
	}

	Category{
		Tags { "Queue" = "Transparent"  "RenderType" = "Transparent" "Glowable" = "True" }

		Blend SrcAlpha OneMinusSrcAlpha

		SubShader {
			Pass{
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag

				#include "UnityCG.cginc"

					struct v2f {
					float4 pos : SV_POSITION;
					float2 uv : TEXCOORD0;
					float4 color : COLOR;
 
				};

				sampler2D _MainTex;
				float4 _MainTex_ST;
				
				v2f vert(appdata_full v) {
					v2f o;
					o.pos = UnityObjectToClipPos(v.vertex);
					o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
					o.color = v.color;
					return o;
				}

	
				fixed4 frag(v2f i) : SV_Target{
					fixed4 c = tex2D(_MainTex, i.uv)*i.color;
					return c;
				}
				ENDCG
			}
		}
	}
}
