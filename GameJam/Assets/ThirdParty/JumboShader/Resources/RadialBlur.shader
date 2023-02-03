Shader "Jumbo/Effect/RadialBlur"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_Samples("Samples", Range(4, 32)) = 16
		_NoiseTex("Texture",2D) = "white"{}
		_NoiseStrength("Noise Strength",Range(0,1)) = 0.5
		_NoiseSpeed("Noise Speed",Vector) = (0,1,0,0)
		_EffectAmount("Effect amount", Range(0, 2)) = 1
		_AdditionalColor("AdditionalColor", Color) = (1,1,1,1)
		_Brightness("Brightness",Range(0,1)) = 0
		_Transparency("Transparency",Range(0,1)) = 0
		_CenterX("Center X", float) = 0.5
		_CenterY("Center Y", float) = 0.5
		_Radius("Radius", Range(0,1.5)) = 0.1
	}
		SubShader
		{
			Tags{ "Queue" = "Transparent" "RenderType" = "Opaque" }
			Cull Off
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha
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
					float2 uv : TEXCOORD0;
					float2 uv2 : TEXCOORD1;
					float4 vertex : SV_POSITION;
				};

				v2f vert(appdata v)
				{
					v2f o;
					o.vertex = UnityObjectToClipPos(v.vertex);
					o.uv = v.uv;
					o.uv2 = v.uv - 0.5;
					return o;
				}

				sampler2D _MainTex;
				sampler2D _NoiseTex;
				float _Samples;
				float _EffectAmount;
				float _CenterX;
				float _CenterY;
				float _Radius;
				float _Brightness;
				float _Transparency;
				float _NoiseStrength;
				fixed4 _AdditionalColor;
				float4 _NoiseSpeed;

				fixed4 frag(v2f i) : SV_Target
				{
					fixed4 col = fixed4(0, 0, 0, 0);

					float2 dist = i.uv - float2(_CenterX, _CenterY);
					for (int x = 0; x < _Samples; x++) {
						float scale = 1 - _EffectAmount * (x / _Samples)* (saturate(length(dist) / _Radius));
						fixed4 effect = tex2D(_MainTex, dist * scale + float2(_CenterX, _CenterY));
						fixed4 noise = tex2D(_NoiseTex, dist * scale + (_NoiseSpeed.xy*_Time.x));
						fixed4 extraColor = _AdditionalColor * (1 + _Brightness + (noise.r *(_NoiseStrength)));
						effect *= fixed4(extraColor.r, extraColor.g, extraColor.b, 1);
						effect.a *= (1 - _Transparency);
						col += effect;
				}
				col /= _Samples;
				return col;
			}
			ENDCG
		}
		}
}